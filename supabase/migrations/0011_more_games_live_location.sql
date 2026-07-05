-- New game types + live location sharing

-- 1) expand game_sessions game_type check
alter table public.game_sessions drop constraint if exists game_sessions_game_type_check;
alter table public.game_sessions add constraint game_sessions_game_type_check
  check (game_type in ('tictactoe','rps','memory_match','tap_race','word_guess',
                       'connect4','reaction_duel'));

-- 2) live location fields on user_locations
alter table public.user_locations add column if not exists is_sharing boolean not null default false;
alter table public.user_locations add column if not exists sharing_until timestamptz;
alter table public.user_locations add column if not exists accuracy double precision;
alter table public.user_locations add column if not exists speed double precision;
alter table public.user_locations add column if not exists battery int;

-- upsert helper that stamps updated_at and sharing window
create or replace function public.update_my_location(
  p_lat double precision, p_lng double precision,
  p_sharing boolean default true,
  p_share_minutes int default 60,
  p_accuracy double precision default null,
  p_speed double precision default null,
  p_battery int default null)
returns void language sql security definer set search_path = public as $$
  insert into user_locations (user_id, lat, lng, is_sharing, sharing_until,
                              accuracy, speed, battery, updated_at)
  values (auth.uid(), p_lat, p_lng, p_sharing,
          case when p_sharing then now() + make_interval(mins => p_share_minutes) else null end,
          p_accuracy, p_speed, p_battery, now())
  on conflict (user_id) do update set
    lat = excluded.lat, lng = excluded.lng, is_sharing = excluded.is_sharing,
    sharing_until = excluded.sharing_until, accuracy = excluded.accuracy,
    speed = excluded.speed, battery = excluded.battery, updated_at = now();
$$;

-- 3) realtime for live distance
do $$
begin
  begin
    alter publication supabase_realtime add table public.user_locations;
  exception when duplicate_object then null; end;
end $$;
