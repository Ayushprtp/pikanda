-- Moods, quotes, songs, custom mood labels, streaks
create table if not exists public.moods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  mood text not null check (mood in ('happy','sad','neutral','angry','anxious','excited')),
  logged_at timestamptz not null default now()
);
create index if not exists idx_moods_group_time on public.moods(group_id, logged_at desc);
create index if not exists idx_moods_user_time on public.moods(user_id, logged_at desc);

create table if not exists public.quotes (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade, -- null = global default
  mood text not null check (mood in ('happy','sad','neutral','angry','anxious','excited')),
  text text not null,
  added_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.songs (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade, -- null = global default
  mood text not null check (mood in ('happy','sad','neutral','angry','anxious','excited')),
  title text not null,
  artist text,
  url text not null,
  platform text not null check (platform in ('spotify','youtube')),
  added_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.group_mood_config (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade unique,
  config jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.streaks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  dare_streak int not null default 0,
  longest_dare_streak int not null default 0,
  last_dare_date date,
  last_checkin date,
  freeze_tokens int not null default 1,
  updated_at timestamptz not null default now(),
  unique(user_id, group_id)
);

-- Log a mood + maintain streak atomically. Returns the new streak row.
create or replace function public.log_mood(p_group uuid, p_mood text)
returns public.streaks
language plpgsql security definer set search_path = public as $$
declare
  s public.streaks;
  today date := (now() at time zone 'utc')::date;
  gap int;
begin
  if not public.is_group_member(p_group) then
    raise exception 'NOT_A_MEMBER';
  end if;

  insert into moods (user_id, group_id, mood) values (auth.uid(), p_group, p_mood);

  insert into streaks (user_id, group_id, current_streak, longest_streak, last_checkin)
  values (auth.uid(), p_group, 1, 1, today)
  on conflict (user_id, group_id) do nothing;

  select * into s from streaks where user_id = auth.uid() and group_id = p_group for update;

  if s.last_checkin is null then
    s.current_streak := 1;
  elsif s.last_checkin = today then
    -- already checked in today; no change
    null;
  else
    gap := today - s.last_checkin;
    if gap = 1 then
      s.current_streak := s.current_streak + 1;
    elsif gap = 2 and s.freeze_tokens > 0 then
      s.freeze_tokens := s.freeze_tokens - 1; -- freeze token saves the streak
      s.current_streak := s.current_streak + 1;
    else
      s.current_streak := 1;
    end if;
  end if;

  s.longest_streak := greatest(s.longest_streak, s.current_streak);
  update streaks set current_streak = s.current_streak,
    longest_streak = s.longest_streak, freeze_tokens = s.freeze_tokens,
    last_checkin = today, updated_at = now()
  where id = s.id returning * into s;
  return s;
end;
$$;

-- Random quote + song for a mood (group-specific with global fallback)
create or replace function public.pick_mood_content(p_group uuid, p_mood text)
returns table(quote_id uuid, quote_text text, song_id uuid, song_title text,
              song_artist text, song_url text, song_platform text)
language sql stable security definer set search_path = public as $$
  with q as (
    select id, text from quotes
    where mood = p_mood and (group_id = p_group or group_id is null)
    order by (group_id is null), random() limit 1
  ), sg as (
    select id, title, artist, url, platform from songs
    where mood = p_mood and (group_id = p_group or group_id is null)
    order by (group_id is null), random() limit 1
  )
  select q.id, q.text, sg.id, sg.title, sg.artist, sg.url, sg.platform
  from (select 1) one
  left join q on true left join sg on true;
$$;

-- RLS
alter table public.moods enable row level security;
alter table public.quotes enable row level security;
alter table public.songs enable row level security;
alter table public.group_mood_config enable row level security;
alter table public.streaks enable row level security;

create policy moods_select on public.moods for select to authenticated
  using (public.is_group_member(group_id));
create policy moods_insert on public.moods for insert to authenticated
  with check (user_id = auth.uid() and public.is_group_member(group_id));

create policy quotes_select on public.quotes for select to authenticated
  using (group_id is null or public.is_group_member(group_id));
create policy quotes_write on public.quotes for insert to authenticated
  with check (group_id is not null and public.is_group_admin(group_id) and added_by = auth.uid());
create policy quotes_delete on public.quotes for delete to authenticated
  using (group_id is not null and public.is_group_admin(group_id));

create policy songs_select on public.songs for select to authenticated
  using (group_id is null or public.is_group_member(group_id));
create policy songs_write on public.songs for insert to authenticated
  with check (group_id is not null and public.is_group_admin(group_id) and added_by = auth.uid());
create policy songs_delete on public.songs for delete to authenticated
  using (group_id is not null and public.is_group_admin(group_id));

create policy mood_config_select on public.group_mood_config for select to authenticated
  using (public.is_group_member(group_id));
create policy mood_config_upsert on public.group_mood_config for insert to authenticated
  with check (public.is_group_admin(group_id));
create policy mood_config_update on public.group_mood_config for update to authenticated
  using (public.is_group_admin(group_id));

create policy streaks_select on public.streaks for select to authenticated
  using (public.is_group_member(group_id));

-- Seed a few global quotes + songs per mood
insert into public.quotes (mood, text) values
 ('happy','Happiness looks good on you. Keep glowing. ✨'),
 ('happy','Collect this moment — it is one of the good ones. 🌻'),
 ('sad','Even the moon has phases. This one will pass too. 🌙'),
 ('sad','It is okay to not be okay. Your people are right here. 🤍'),
 ('neutral','A quiet day is still a day well lived. ☁️'),
 ('neutral','Slow days build strong souls. 🍃'),
 ('angry','Breathe in for four, out for six. You are bigger than this feeling. 🔥'),
 ('angry','Storms empty the sky so it can be blue again. ⛈️'),
 ('anxious','You have survived 100% of your worst days so far. 💛'),
 ('anxious','One step. Then the next. That is all a path is. 🐾'),
 ('excited','Bottle this energy — the world is not ready! ⚡'),
 ('excited','Big things start exactly like this. 🚀');
