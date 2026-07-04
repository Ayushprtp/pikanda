// send-fcm: drains notification_queue and delivers pushes via FCM HTTP v1.
// Called by pg_cron (process_notification_queue) with x-internal-secret header.
// Requires app_config row 'fcm_service_account' = Firebase service account JSON.
// Without it, notifications are marked 'skipped' (app still works via realtime).
import { createClient } from "jsr:@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  return buf.buffer;
}

function b64url(data: Uint8Array | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  let bin = "";
  bytes.forEach((b) => (bin += String.fromCharCode(b)));
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

let cachedToken: { token: string; exp: number } | null = null;

async function getAccessToken(sa: { client_email: string; private_key: string }) {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.exp > now + 60) return cachedToken.token;

  const header = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = b64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const key = await crypto.subtle.importKey(
    "pkcs8", pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"],
  );
  const sig = new Uint8Array(await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(`${header}.${claims}`),
  ));
  const jwt = `${header}.${claims}.${b64url(sig)}`;

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=${encodeURIComponent("urn:ietf:params:oauth:grant-type:jwt-bearer")}&assertion=${jwt}`,
  });
  if (!res.ok) throw new Error(`token exchange failed: ${await res.text()}`);
  const json = await res.json();
  cachedToken = { token: json.access_token, exp: now + (json.expires_in ?? 3600) };
  return cachedToken.token;
}

async function resolveTokens(
  n: { group_id: string | null; recipient_id: string | null; exclude_user: string | null },
): Promise<string[]> {
  if (n.recipient_id) {
    const { data } = await supabase.from("users")
      .select("fcm_token").eq("id", n.recipient_id).single();
    return data?.fcm_token ? [data.fcm_token] : [];
  }
  if (!n.group_id) return [];
  const { data: members } = await supabase.from("group_members")
    .select("user_id").eq("group_id", n.group_id);
  const ids = (members ?? []).map((m) => m.user_id)
    .filter((id) => id !== n.exclude_user);
  if (ids.length === 0) return [];
  const { data: users } = await supabase.from("users")
    .select("fcm_token").in("id", ids).not("fcm_token", "is", null);
  return (users ?? []).map((u) => u.fcm_token as string);
}

Deno.serve(async (req: Request) => {
  const { data: secretRow } = await supabase.from("app_config")
    .select("value").eq("key", "internal_secret").single();
  if (!secretRow || req.headers.get("x-internal-secret") !== secretRow.value) {
    return new Response(JSON.stringify({ error: "forbidden" }), { status: 403 });
  }

  const { data: queue } = await supabase.from("notification_queue")
    .select("*").eq("status", "pending")
    .order("created_at", { ascending: true }).limit(50);
  if (!queue || queue.length === 0) {
    return new Response(JSON.stringify({ processed: 0 }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const { data: saRow } = await supabase.from("app_config")
    .select("value").eq("key", "fcm_service_account").maybeSingle();

  let sent = 0, skipped = 0, failed = 0;

  if (!saRow) {
    // FCM not configured yet: mark skipped so the queue doesn't grow forever.
    const ids = queue.map((q) => q.id);
    await supabase.from("notification_queue")
      .update({ status: "skipped", processed_at: new Date().toISOString() })
      .in("id", ids);
    return new Response(JSON.stringify({ processed: ids.length, skipped: ids.length }), {
      headers: { "Content-Type": "application/json" },
    });
  }

  const sa = JSON.parse(saRow.value);
  const accessToken = await getAccessToken(sa);
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;

  for (const n of queue) {
    try {
      const tokens = await resolveTokens(n);
      if (tokens.length === 0) {
        await supabase.from("notification_queue")
          .update({ status: "skipped", processed_at: new Date().toISOString() })
          .eq("id", n.id);
        skipped++;
        continue;
      }
      const dataPayload: Record<string, string> = {};
      for (const [k, v] of Object.entries(n.data ?? {})) dataPayload[k] = String(v);
      for (const token of tokens) {
        const res = await fetch(fcmUrl, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title: n.title, body: n.body },
              data: dataPayload,
              android: { priority: "HIGH" },
            },
          }),
        });
        if (res.status === 404 || res.status === 400) {
          // stale token: clear it so we stop retrying
          await supabase.from("users").update({ fcm_token: null })
            .eq("fcm_token", token);
        }
      }
      await supabase.from("notification_queue")
        .update({ status: "sent", processed_at: new Date().toISOString() })
        .eq("id", n.id);
      sent++;
    } catch (e) {
      console.error("notification failed", n.id, e);
      await supabase.from("notification_queue")
        .update({ status: "failed", processed_at: new Date().toISOString() })
        .eq("id", n.id);
      failed++;
    }
  }

  return new Response(JSON.stringify({ processed: queue.length, sent, skipped, failed }), {
    headers: { "Content-Type": "application/json" },
  });
});
