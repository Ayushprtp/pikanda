-- Memory capsules, monthly highlights, badges, group XP/levels
create table if not exists public.memory_capsules (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  created_by uuid references public.users(id) on delete set null,
  title text,
  content text,
  image_url text,
  unlock_at timestamptz not null default now() + interval '30 days',
  is_unlocked boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.monthly_highlights (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  month date not null,
  top_zap_id uuid references public.zaps(id) on delete set null,
  most_active_day date,
  summary jsonb,
  created_at timestamptz not null default now(),
  unique(group_id, month)
);

create table if not exists public.user_badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  badge_key text not null,
  earned_at timestamptz not null default now(),
  unique(user_id, group_id, badge_key)
);

-- ============ group XP + levels ============
create or replace function public.level_name_for(lvl int) returns text
language sql immutable as $$
  select case
    when lvl >= 10 then 'Soulmates'
    when lvl >= 8 then 'Inseparable'
    when lvl >= 5 then 'Besties'
    when lvl >= 3 then 'Good Friends'
    else 'Strangers' end;
$$;

create or replace function public.add_group_xp(gid uuid, amount int) returns void
language plpgsql security definer set search_path = public as $$
declare new_xp int; new_level int;
begin
  update groups set xp = xp + amount where id = gid returning xp into new_xp;
  new_level := 1 + floor(sqrt(new_xp / 50.0))::int; -- gentle curve: lvl2@50xp lvl5@800 lvl10@4050
  update groups set level = new_level, level_name = public.level_name_for(new_level)
  where id = gid and level <> new_level;
end;
$$;

create or replace function public.xp_on_zap() returns trigger
language plpgsql security definer set search_path = public as $$
begin perform public.add_group_xp(new.group_id, 5); return new; end; $$;
create or replace function public.xp_on_mood() returns trigger
language plpgsql security definer set search_path = public as $$
begin perform public.add_group_xp(new.group_id, 3); return new; end; $$;
create or replace function public.xp_on_dare() returns trigger
language plpgsql security definer set search_path = public as $$
declare gid uuid;
begin
  select group_id into gid from dares where id = new.dare_id;
  perform public.add_group_xp(gid, 10); return new;
end; $$;
create or replace function public.xp_on_vibe_response() returns trigger
language plpgsql security definer set search_path = public as $$
declare gid uuid;
begin
  select group_id into gid from vibe_checks where id = new.vibe_check_id;
  perform public.add_group_xp(gid, 5); return new;
end; $$;

drop trigger if exists trg_xp_zap on public.zaps;
create trigger trg_xp_zap after insert on public.zaps
  for each row execute function public.xp_on_zap();
drop trigger if exists trg_xp_mood on public.moods;
create trigger trg_xp_mood after insert on public.moods
  for each row execute function public.xp_on_mood();
drop trigger if exists trg_xp_dare on public.dare_completions;
create trigger trg_xp_dare after insert on public.dare_completions
  for each row execute function public.xp_on_dare();
drop trigger if exists trg_xp_vibe on public.vibe_check_responses;
create trigger trg_xp_vibe after insert on public.vibe_check_responses
  for each row execute function public.xp_on_vibe_response();

-- ============ instant badges (event-driven; periodic ones come from cron) ============
create or replace function public.award_badge(p_user uuid, p_group uuid, p_key text) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into user_badges (user_id, group_id, badge_key) values (p_user, p_group, p_key)
  on conflict do nothing;
  if found then
    perform public.queue_notification(p_group, p_user, null,
      '🏅 Badge earned!', 'You earned a new badge: ' || p_key,
      jsonb_build_object('type','badge','badge_key',p_key,'group_id',p_group));
  end if;
end;
$$;

create or replace function public.badge_on_zap() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform public.award_badge(new.sender_id, new.group_id, 'first_spark');
  return new;
end; $$;
drop trigger if exists trg_badge_zap on public.zaps;
create trigger trg_badge_zap after insert on public.zaps
  for each row execute function public.badge_on_zap();

create or replace function public.badge_on_capsule() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform public.award_badge(new.created_by, new.group_id, 'memory_keeper');
  return new;
end; $$;
drop trigger if exists trg_badge_capsule on public.memory_capsules;
create trigger trg_badge_capsule after insert on public.memory_capsules
  for each row execute function public.badge_on_capsule();

create or replace function public.badge_on_whisper() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  -- whisper is anonymous in-app; badge is awarded silently to the actual authed sender
  perform public.award_badge(auth.uid(), new.group_id, 'whisperer');
  return new;
end; $$;
drop trigger if exists trg_badge_whisper on public.whispers;
create trigger trg_badge_whisper after insert on public.whispers
  for each row execute function public.badge_on_whisper();

-- RLS
alter table public.memory_capsules enable row level security;
alter table public.monthly_highlights enable row level security;
alter table public.user_badges enable row level security;

-- capsule content hidden until unlocked (metadata visible for sealed-envelope UI)
create policy capsules_select on public.memory_capsules for select to authenticated
  using (public.is_group_member(group_id));
create policy capsules_insert on public.memory_capsules for insert to authenticated
  with check (public.is_group_member(group_id) and created_by = auth.uid());

create policy highlights_select on public.monthly_highlights for select to authenticated
  using (public.is_group_member(group_id));

create policy badges_select on public.user_badges for select to authenticated
  using (public.is_group_member(group_id));

-- Locked-capsule content protection: expose via view
create or replace view public.capsules_view
with (security_invoker = true) as
select id, group_id, created_by, unlock_at, is_unlocked, created_at,
  case when is_unlocked then title else null end as title,
  case when is_unlocked then content else null end as content,
  case when is_unlocked then image_url else null end as image_url
from public.memory_capsules;
