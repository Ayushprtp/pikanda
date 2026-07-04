-- Periodic maintenance functions + pg_cron schedules
create extension if not exists pg_cron;
create extension if not exists pg_net;

-- config used by cron to call the send-fcm edge function
insert into public.app_config (key, value) values
  ('edge_url', 'https://byjcsfdgeptejgsstbrb.supabase.co/functions/v1'),
  ('anon_key', '<anon key>'), -- replaced at apply time
  ('internal_secret', encode(gen_random_bytes(24),'hex'))
on conflict (key) do nothing;

-- ============ capsule unlocking ============
create or replace function public.unlock_capsules() returns void
language plpgsql security definer set search_path = public as $$
declare c record;
begin
  for c in select * from memory_capsules where not is_unlocked and unlock_at <= now() loop
    update memory_capsules set is_unlocked = true where id = c.id;
    perform public.queue_notification(c.group_id, null, null,
      '📦 A memory capsule unlocked!',
      coalesce('“' || c.title || '” is', 'A capsule from the past is') || ' ready to open',
      jsonb_build_object('type','capsule_unlocked','capsule_id',c.id,'group_id',c.group_id));
  end loop;
end;
$$;

-- ============ streak freeze replenish (Mondays) ============
create or replace function public.replenish_freeze_tokens() returns void
language sql security definer set search_path = public as $$
  update streaks set freeze_tokens = 1 where freeze_tokens < 1;
$$;

-- ============ scheduled morning/night messages ============
create or replace function public.process_scheduled_messages() returns void
language plpgsql security definer set search_path = public as $$
declare m record; today date := (now() at time zone 'utc')::date;
begin
  for m in
    select * from scheduled_messages
    where is_active
      and (last_sent_on is null or last_sent_on < today)
      and send_time <= (now() at time zone 'utc')::time
      and (now() at time zone 'utc')::time < send_time + interval '15 minutes'
  loop
    perform public.queue_notification(m.group_id, null, null,
      '🌅 Message of the day', m.message,
      jsonb_build_object('type','scheduled_message','group_id',m.group_id));
    update scheduled_messages
      set last_sent_on = today, is_active = (recurrence = 'daily')
      where id = m.id;
  end loop;
end;
$$;

-- ============ mood pattern alert (3+ consecutive low days → admins) ============
create or replace function public.mood_pattern_alert() returns void
language plpgsql security definer set search_path = public as $$
declare r record; admin_rec record;
begin
  for r in
    select gm.group_id, gm.user_id, gm.role_name
    from group_members gm
    join groups g on g.id = gm.group_id and g.mood_alert_enabled
    where (
      select count(distinct (m.logged_at at time zone 'utc')::date)
      from moods m
      where m.user_id = gm.user_id and m.group_id = gm.group_id
        and m.mood in ('sad','anxious')
        and m.logged_at > now() - interval '3 days'
    ) >= 3
  loop
    for admin_rec in select user_id from group_members
      where group_id = r.group_id and is_admin and user_id <> r.user_id loop
      perform public.queue_notification(r.group_id, admin_rec.user_id, null,
        '🐼 Check in on ' || r.role_name,
        r.role_name || ' seems low lately — maybe send them something nice',
        jsonb_build_object('type','mood_alert','group_id',r.group_id));
    end loop;
  end loop;
end;
$$;

-- ============ periodic badges ============
create or replace function public.award_periodic_badges() returns void
language plpgsql security definer set search_path = public as $$
begin
  -- 7 day streak
  insert into user_badges (user_id, group_id, badge_key)
  select user_id, group_id, 'seven_day_streak' from streaks where current_streak >= 7
  on conflict do nothing;
  -- dare devil: 7 dares completed
  insert into user_badges (user_id, group_id, badge_key)
  select dc.user_id, d.group_id, 'dare_devil'
  from dare_completions dc join dares d on d.id = dc.dare_id
  group by dc.user_id, d.group_id having count(*) >= 7
  on conflict do nothing;
  -- voice of the group: 10 voice zaps
  insert into user_badges (user_id, group_id, badge_key)
  select z.sender_id, z.group_id, 'voice_of_group'
  from voice_notes v join zaps z on z.id = v.zap_id
  group by z.sender_id, z.group_id having count(*) >= 10
  on conflict do nothing;
  -- always sunny: 30 distinct happy days
  insert into user_badges (user_id, group_id, badge_key)
  select user_id, group_id, 'always_sunny' from moods where mood = 'happy'
  group by user_id, group_id
  having count(distinct (logged_at at time zone 'utc')::date) >= 30
  on conflict do nothing;
  -- founding member: joined within 1 day of group creation
  insert into user_badges (user_id, group_id, badge_key)
  select gm.user_id, gm.group_id, 'founding_member'
  from group_members gm join groups g on g.id = gm.group_id
  where gm.joined_at < g.created_at + interval '1 day'
  on conflict do nothing;
end;
$$;

-- ============ monthly highlight (runs daily; acts on 1st for previous month) ============
create or replace function public.compute_monthly_highlights() returns void
language plpgsql security definer set search_path = public as $$
declare g record; prev_month date; top_zap uuid; active_day date; zap_count int;
begin
  if extract(day from now() at time zone 'utc') <> 1 then return; end if;
  prev_month := date_trunc('month', (now() at time zone 'utc')::date - 1)::date;
  for g in select id from groups loop
    select z.id into top_zap from zaps z
      left join zap_reactions r on r.zap_id = z.id
      where z.group_id = g.id
        and z.created_at >= prev_month and z.created_at < prev_month + interval '1 month'
      group by z.id order by count(r.id) desc, z.created_at desc limit 1;
    select (created_at at time zone 'utc')::date, count(*) into active_day, zap_count
      from zaps where group_id = g.id
        and created_at >= prev_month and created_at < prev_month + interval '1 month'
      group by 1 order by count(*) desc limit 1;
    if top_zap is not null or active_day is not null then
      insert into monthly_highlights (group_id, month, top_zap_id, most_active_day, summary)
      values (g.id, prev_month, top_zap, active_day,
              jsonb_build_object('busiest_day_zaps', coalesce(zap_count,0)))
      on conflict (group_id, month) do nothing;
      perform public.queue_notification(g.id, null, null,
        '🏆 Monthly Highlight!', 'Your group''s best moments of the month are in',
        jsonb_build_object('type','monthly_highlight','group_id',g.id));
    end if;
  end loop;
end;
$$;

-- ============ reveal expired vibe checks ============
create or replace function public.reveal_expired_vibe_checks() returns void
language plpgsql security definer set search_path = public as $$
declare vc record;
begin
  for vc in select * from vibe_checks where not is_revealed and expires_at <= now() loop
    update vibe_checks set is_revealed = true where id = vc.id;
    perform public.queue_notification(vc.group_id, null, null,
      '🎭 Vibe Check revealed!', 'Time''s up — see your group''s vibe',
      jsonb_build_object('type','vibe_check','vibe_check_id',vc.id,'group_id',vc.group_id));
  end loop;
end;
$$;

-- ============ notification queue → send-fcm edge function ============
create or replace function public.process_notification_queue() returns void
language plpgsql security definer set search_path = public as $$
declare cfg_url text; cfg_key text; cfg_secret text; pending int;
begin
  select count(*) into pending from notification_queue where status = 'pending';
  if pending = 0 then return; end if;
  select value into cfg_url from app_config where key = 'edge_url';
  select value into cfg_key from app_config where key = 'anon_key';
  select value into cfg_secret from app_config where key = 'internal_secret';
  perform net.http_post(
    url := cfg_url || '/send-fcm',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer ' || cfg_key,
      'x-internal-secret', cfg_secret),
    body := '{}'::jsonb,
    timeout_milliseconds := 8000);
end;
$$;

-- ============ schedules ============
select cron.schedule('process-notifications','* * * * *',
  $$select public.process_notification_queue()$$);
select cron.schedule('scheduled-messages','* * * * *',
  $$select public.process_scheduled_messages()$$);
select cron.schedule('reveal-vibe-checks','*/5 * * * *',
  $$select public.reveal_expired_vibe_checks()$$);
select cron.schedule('pet-decay','30 * * * *',
  $$select public.decay_pets()$$);
select cron.schedule('unlock-capsules','5 0 * * *',
  $$select public.unlock_capsules()$$);
select cron.schedule('mood-pattern-alert','0 18 * * *',
  $$select public.mood_pattern_alert()$$);
select cron.schedule('award-badges','15 0 * * *',
  $$select public.award_periodic_badges()$$);
select cron.schedule('monthly-highlights','25 0 * * *',
  $$select public.compute_monthly_highlights()$$);
select cron.schedule('replenish-freeze','10 0 * * 1',
  $$select public.replenish_freeze_tokens()$$);
