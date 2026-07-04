-- Daily content, dares, vibe checks, daily questions, bucket list, countdowns
create table if not exists public.scheduled_messages (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  created_by uuid references public.users(id) on delete set null,
  message text not null,
  send_time time not null,
  recurrence text not null default 'daily' check (recurrence in ('daily','once')),
  is_active boolean not null default true,
  last_sent_on date,
  created_at timestamptz not null default now()
);

create table if not exists public.thought_of_day (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  created_by uuid references public.users(id) on delete set null,
  thought text not null,
  date date not null default (now() at time zone 'utc')::date,
  created_at timestamptz not null default now(),
  unique(group_id, date)
);

create table if not exists public.dares (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  created_by uuid references public.users(id) on delete set null,
  dare_text text not null,
  date date not null default (now() at time zone 'utc')::date,
  created_at timestamptz not null default now(),
  unique(group_id, date)
);

create table if not exists public.dare_completions (
  id uuid primary key default gen_random_uuid(),
  dare_id uuid not null references public.dares(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  completed_at timestamptz not null default now(),
  unique(dare_id, user_id)
);

-- maintain dare streak on completion
create or replace function public.on_dare_completed() returns trigger
language plpgsql security definer set search_path = public as $$
declare d record; s record; today date; gap int;
begin
  select * into d from dares where id = new.dare_id;
  today := d.date;
  insert into streaks (user_id, group_id) values (new.user_id, d.group_id)
    on conflict (user_id, group_id) do nothing;
  select * into s from streaks where user_id = new.user_id and group_id = d.group_id for update;
  if s.last_dare_date is null then
    update streaks set dare_streak = 1, longest_dare_streak = greatest(longest_dare_streak,1),
      last_dare_date = today, updated_at = now() where id = s.id;
  elsif s.last_dare_date < today then
    gap := today - s.last_dare_date;
    update streaks set
      dare_streak = case when gap = 1 then dare_streak + 1 else 1 end,
      longest_dare_streak = greatest(longest_dare_streak,
        case when gap = 1 then dare_streak + 1 else 1 end),
      last_dare_date = today, updated_at = now() where id = s.id;
  end if;
  return new;
end;
$$;
drop trigger if exists trg_dare_completed on public.dare_completions;
create trigger trg_dare_completed after insert on public.dare_completions
  for each row execute function public.on_dare_completed();

-- ============ vibe checks ============
create table if not exists public.vibe_checks (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  created_by uuid references public.users(id) on delete set null,
  expires_at timestamptz not null default now() + interval '1 hour',
  is_revealed boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.vibe_check_responses (
  id uuid primary key default gen_random_uuid(),
  vibe_check_id uuid not null references public.vibe_checks(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  mood text not null check (mood in ('happy','sad','neutral','angry','anxious','excited')),
  created_at timestamptz not null default now(),
  unique(vibe_check_id, user_id)
);

-- reveal when everyone answered
create or replace function public.maybe_reveal_vibe_check() returns trigger
language plpgsql security definer set search_path = public as $$
declare vc record; member_count int; response_count int;
begin
  select * into vc from vibe_checks where id = new.vibe_check_id;
  select count(*) into member_count from group_members where group_id = vc.group_id;
  select count(*) into response_count from vibe_check_responses where vibe_check_id = vc.id;
  if response_count >= member_count and not vc.is_revealed then
    update vibe_checks set is_revealed = true where id = vc.id;
    perform public.queue_notification(vc.group_id, null, null,
      '🎭 Vibe Check revealed!', 'Everyone answered — see your group vibe now',
      jsonb_build_object('type','vibe_check','vibe_check_id',vc.id,'group_id',vc.group_id));
  end if;
  return new;
end;
$$;
drop trigger if exists trg_vibe_response on public.vibe_check_responses;
create trigger trg_vibe_response after insert on public.vibe_check_responses
  for each row execute function public.maybe_reveal_vibe_check();

-- ============ vibe sync sessions ============
create table if not exists public.vibe_sync_sessions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  started_by uuid references public.users(id) on delete set null,
  song_id uuid references public.songs(id) on delete set null,
  song_url text not null,
  song_title text,
  starts_at timestamptz not null, -- everyone starts playback at this timestamp
  created_at timestamptz not null default now()
);

-- ============ daily question (mutual reveal) ============
create table if not exists public.daily_questions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  question text not null,
  date date not null default (now() at time zone 'utc')::date,
  created_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now(),
  unique(group_id, date)
);

create table if not exists public.daily_question_answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.daily_questions(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  answer text not null,
  created_at timestamptz not null default now(),
  unique(question_id, user_id)
);

-- Answers hidden until the viewer has answered too (enforced via RLS below)

-- ============ bucket list ============
create table if not exists public.bucket_list (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  title text not null,
  emoji text,
  is_done boolean not null default false,
  done_at timestamptz,
  created_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now()
);

-- ============ countdown events (birthdays, anniversaries) ============
create table if not exists public.countdown_events (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  title text not null,
  emoji text,
  event_date date not null,
  repeats_yearly boolean not null default true,
  created_by uuid references public.users(id) on delete set null,
  created_at timestamptz not null default now()
);

-- RLS
alter table public.scheduled_messages enable row level security;
alter table public.thought_of_day enable row level security;
alter table public.dares enable row level security;
alter table public.dare_completions enable row level security;
alter table public.vibe_checks enable row level security;
alter table public.vibe_check_responses enable row level security;
alter table public.vibe_sync_sessions enable row level security;
alter table public.daily_questions enable row level security;
alter table public.daily_question_answers enable row level security;
alter table public.bucket_list enable row level security;
alter table public.countdown_events enable row level security;

create policy sched_select on public.scheduled_messages for select to authenticated
  using (public.is_group_member(group_id));
create policy sched_write on public.scheduled_messages for insert to authenticated
  with check (public.is_group_admin(group_id));
create policy sched_update on public.scheduled_messages for update to authenticated
  using (public.is_group_admin(group_id));
create policy sched_delete on public.scheduled_messages for delete to authenticated
  using (public.is_group_admin(group_id));

create policy thought_select on public.thought_of_day for select to authenticated
  using (public.is_group_member(group_id));
create policy thought_write on public.thought_of_day for insert to authenticated
  with check (public.is_group_admin(group_id));
create policy thought_update on public.thought_of_day for update to authenticated
  using (public.is_group_admin(group_id));

create policy dares_select on public.dares for select to authenticated
  using (public.is_group_member(group_id));
create policy dares_write on public.dares for insert to authenticated
  with check (public.is_group_admin(group_id));
create policy dares_update on public.dares for update to authenticated
  using (public.is_group_admin(group_id));

create policy darec_select on public.dare_completions for select to authenticated
  using (exists(select 1 from dares d where d.id = dare_id and public.is_group_member(d.group_id)));
create policy darec_insert on public.dare_completions for insert to authenticated
  with check (user_id = auth.uid()
    and exists(select 1 from dares d where d.id = dare_id and public.is_group_member(d.group_id)));

create policy vibe_select on public.vibe_checks for select to authenticated
  using (public.is_group_member(group_id));
create policy vibe_insert on public.vibe_checks for insert to authenticated
  with check (public.is_group_admin(group_id));

create policy vibe_resp_select on public.vibe_check_responses for select to authenticated
  using (
    user_id = auth.uid() or
    exists(select 1 from vibe_checks vc where vc.id = vibe_check_id
      and public.is_group_member(vc.group_id) and vc.is_revealed)
  );
create policy vibe_resp_insert on public.vibe_check_responses for insert to authenticated
  with check (user_id = auth.uid()
    and exists(select 1 from vibe_checks vc where vc.id = vibe_check_id
      and public.is_group_member(vc.group_id)));

create policy vsync_select on public.vibe_sync_sessions for select to authenticated
  using (public.is_group_member(group_id));
create policy vsync_insert on public.vibe_sync_sessions for insert to authenticated
  with check (public.is_group_member(group_id) and started_by = auth.uid());

create policy dq_select on public.daily_questions for select to authenticated
  using (public.is_group_member(group_id));
create policy dq_insert on public.daily_questions for insert to authenticated
  with check (public.is_group_member(group_id));

create policy dqa_select on public.daily_question_answers for select to authenticated
  using (
    user_id = auth.uid() or
    exists(select 1 from daily_question_answers mine
      where mine.question_id = daily_question_answers.question_id and mine.user_id = auth.uid())
    and exists(select 1 from daily_questions q where q.id = question_id
      and public.is_group_member(q.group_id))
  );
create policy dqa_insert on public.daily_question_answers for insert to authenticated
  with check (user_id = auth.uid()
    and exists(select 1 from daily_questions q where q.id = question_id
      and public.is_group_member(q.group_id)));

create policy bucket_select on public.bucket_list for select to authenticated
  using (public.is_group_member(group_id));
create policy bucket_insert on public.bucket_list for insert to authenticated
  with check (public.is_group_member(group_id) and created_by = auth.uid());
create policy bucket_update on public.bucket_list for update to authenticated
  using (public.is_group_member(group_id));
create policy bucket_delete on public.bucket_list for delete to authenticated
  using (public.is_group_member(group_id));

create policy countdown_select on public.countdown_events for select to authenticated
  using (public.is_group_member(group_id));
create policy countdown_insert on public.countdown_events for insert to authenticated
  with check (public.is_group_member(group_id) and created_by = auth.uid());
create policy countdown_update on public.countdown_events for update to authenticated
  using (public.is_group_member(group_id));
create policy countdown_delete on public.countdown_events for delete to authenticated
  using (public.is_group_member(group_id));
