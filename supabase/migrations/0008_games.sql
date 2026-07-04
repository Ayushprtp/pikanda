-- Realtime multiplayer minigames
create table if not exists public.game_sessions (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  game_type text not null check (game_type in
    ('tictactoe','rps','memory_match','tap_race','word_guess')),
  status text not null default 'lobby' check (status in ('lobby','active','finished','cancelled')),
  created_by uuid references public.users(id) on delete set null,
  state jsonb not null default '{}',
  current_turn uuid references public.users(id) on delete set null,
  winner_id uuid references public.users(id) on delete set null,
  max_players int not null default 2,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_games_group on public.game_sessions(group_id, created_at desc);

create table if not exists public.game_players (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.game_sessions(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  player_index int not null,
  score int not null default 0,
  is_ready boolean not null default false,
  joined_at timestamptz not null default now(),
  unique(session_id, user_id),
  unique(session_id, player_index)
);

create table if not exists public.game_moves (
  id bigint generated always as identity primary key,
  session_id uuid not null references public.game_sessions(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  move jsonb not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_moves_session on public.game_moves(session_id, id);

-- ===== RPCs (atomic game flow) =====
create or replace function public.create_game(p_group uuid, p_type text, p_max_players int default 2)
returns public.game_sessions
language plpgsql security definer set search_path = public as $$
declare s public.game_sessions;
begin
  if not public.is_group_member(p_group) then raise exception 'NOT_A_MEMBER'; end if;
  insert into game_sessions (group_id, game_type, created_by, max_players)
  values (p_group, p_type, auth.uid(), p_max_players) returning * into s;
  insert into game_players (session_id, user_id, player_index, is_ready)
  values (s.id, auth.uid(), 0, true);
  perform public.queue_notification(p_group, null, auth.uid(),
    '🎮 Game on!', 'A ' || p_type || ' lobby is open — join now!',
    jsonb_build_object('type','game_invite','session_id',s.id,'group_id',p_group,
                       'game_type',p_type));
  return s;
end;
$$;

create or replace function public.join_game(p_session uuid)
returns public.game_players
language plpgsql security definer set search_path = public as $$
declare s public.game_sessions; p public.game_players; n int;
begin
  select * into s from game_sessions where id = p_session for update;
  if s.id is null or not public.is_group_member(s.group_id) then
    raise exception 'NOT_A_MEMBER';
  end if;
  if s.status <> 'lobby' then raise exception 'GAME_ALREADY_STARTED'; end if;
  select count(*) into n from game_players where session_id = p_session;
  if n >= s.max_players then raise exception 'GAME_FULL'; end if;
  insert into game_players (session_id, user_id, player_index, is_ready)
  values (p_session, auth.uid(), n, true)
  on conflict (session_id, user_id) do update set is_ready = true
  returning * into p;
  -- auto-start when full
  select count(*) into n from game_players where session_id = p_session;
  if n >= s.max_players then
    update game_sessions set status = 'active', updated_at = now(),
      current_turn = (select user_id from game_players
                      where session_id = p_session and player_index = 0)
    where id = p_session;
  end if;
  return p;
end;
$$;

create or replace function public.start_game(p_session uuid)
returns void language plpgsql security definer set search_path = public as $$
declare s public.game_sessions;
begin
  select * into s from game_sessions where id = p_session for update;
  if s.created_by <> auth.uid() then raise exception 'ONLY_HOST_CAN_START'; end if;
  update game_sessions set status = 'active', updated_at = now(),
    current_turn = (select user_id from game_players
                    where session_id = p_session and player_index = 0)
  where id = p_session and status = 'lobby';
end;
$$;

-- Append a move; optionally update shared state / pass turn / finish game
create or replace function public.submit_move(
  p_session uuid, p_move jsonb,
  p_new_state jsonb default null,
  p_next_turn uuid default null,
  p_finish boolean default false,
  p_winner uuid default null,
  p_scores jsonb default null) -- {"user_id": score}
returns void language plpgsql security definer set search_path = public as $$
declare s public.game_sessions; k text; v text;
begin
  select * into s from game_sessions where id = p_session for update;
  if s.id is null or not public.is_group_member(s.group_id) then
    raise exception 'NOT_A_MEMBER';
  end if;
  if s.status <> 'active' then raise exception 'GAME_NOT_ACTIVE'; end if;
  if not exists(select 1 from game_players where session_id = p_session and user_id = auth.uid()) then
    raise exception 'NOT_IN_GAME';
  end if;

  insert into game_moves (session_id, user_id, move) values (p_session, auth.uid(), p_move);

  update game_sessions set
    state = coalesce(p_new_state, state),
    current_turn = coalesce(p_next_turn, current_turn),
    status = case when p_finish then 'finished' else status end,
    winner_id = case when p_finish then p_winner else winner_id end,
    updated_at = now()
  where id = p_session;

  if p_scores is not null then
    for k, v in select * from jsonb_each_text(p_scores) loop
      update game_players set score = v::int
      where session_id = p_session and user_id = k::uuid;
    end loop;
  end if;

  if p_finish then
    perform public.add_group_xp(s.group_id, 8);
    if p_winner is not null then
      perform public.award_badge(p_winner, s.group_id, 'first_win');
    end if;
  end if;
end;
$$;

-- Leaderboard view
create or replace view public.game_leaderboard
with (security_invoker = true) as
select gs.group_id, gp.user_id,
  count(*) filter (where gs.winner_id = gp.user_id) as wins,
  count(*) as games_played,
  sum(gp.score) as total_score
from game_players gp
join game_sessions gs on gs.id = gp.session_id
where gs.status = 'finished'
group by gs.group_id, gp.user_id;

-- RLS
alter table public.game_sessions enable row level security;
alter table public.game_players enable row level security;
alter table public.game_moves enable row level security;

create policy games_select on public.game_sessions for select to authenticated
  using (public.is_group_member(group_id));
create policy gplayers_select on public.game_players for select to authenticated
  using (exists(select 1 from game_sessions s where s.id = session_id
    and public.is_group_member(s.group_id)));
create policy gmoves_select on public.game_moves for select to authenticated
  using (exists(select 1 from game_sessions s where s.id = session_id
    and public.is_group_member(s.group_id)));
-- writes go through RPCs only

-- ===== realtime publication =====
do $$
begin
  begin
    alter publication supabase_realtime add table public.game_sessions;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.game_players;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.game_moves;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.zaps;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.pokes;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.pets;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.vibe_checks;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.vibe_check_responses;
  exception when duplicate_object then null; end;
  begin
    alter publication supabase_realtime add table public.vibe_sync_sessions;
  exception when duplicate_object then null; end;
end $$;
