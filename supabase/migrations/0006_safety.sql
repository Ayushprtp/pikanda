-- SafeZap: location events, safe codes, app config
create table if not exists public.location_events (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  sender_id uuid not null references public.users(id) on delete cascade,
  trigger_type text not null check (trigger_type in ('auto_24hr','secret_code','safe_word')),
  encrypted_coords text not null,
  is_live_gps boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists idx_location_events_group on public.location_events(group_id, created_at desc);

create table if not exists public.safe_codes (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade unique,
  code text not null, -- sha256 hashed client-side
  created_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now()
);

-- per-group AES key salt (key derived client-side from group_id + salt)
alter table public.groups add column if not exists aes_salt text not null default encode(gen_random_bytes(16),'hex');

-- server-side config for edge functions (service-role only)
create table if not exists public.app_config (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

alter table public.location_events enable row level security;
alter table public.safe_codes enable row level security;
alter table public.app_config enable row level security; -- no policies: service role only

create policy locevents_select on public.location_events for select to authenticated
  using (public.is_group_member(group_id));
create policy locevents_insert on public.location_events for insert to authenticated
  with check (sender_id = auth.uid() and public.is_group_member(group_id));

create policy safecodes_select on public.safe_codes for select to authenticated
  using (public.is_group_member(group_id));
create policy safecodes_insert on public.safe_codes for insert to authenticated
  with check (public.is_group_admin(group_id));
create policy safecodes_update on public.safe_codes for update to authenticated
  using (public.is_group_admin(group_id));

-- notify group on safety event
create or replace function public.notify_on_location_event() returns trigger
language plpgsql security definer set search_path = public as $$
declare sender_name text; label text;
begin
  select role_name into sender_name from group_members
    where group_id = new.group_id and user_id = new.sender_id;
  label := case new.trigger_type
    when 'safe_word' then '🚨 EMERGENCY'
    when 'secret_code' then '📍 Location requested'
    else '⏰ 24h check-in' end;
  perform public.queue_notification(new.group_id, null, new.sender_id,
    label, coalesce(sender_name,'A member') || ' shared their location — open the map',
    jsonb_build_object('type','safezap','event_id',new.id,'group_id',new.group_id,
                       'trigger',new.trigger_type));
  return new;
end;
$$;
drop trigger if exists trg_notify_locevent on public.location_events;
create trigger trg_notify_locevent after insert on public.location_events
  for each row execute function public.notify_on_location_event();
