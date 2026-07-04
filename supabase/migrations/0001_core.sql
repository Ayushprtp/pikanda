-- Pikanda core: users, groups, members, helpers
create extension if not exists pgcrypto;

-- ============ users (profile, mirrors auth.users) ============
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  display_name text,
  avatar_url text,
  fcm_token text,
  phone_number text,
  created_at timestamptz not null default now()
);

-- ============ groups ============
create or replace function public.gen_invite_code() returns text
language sql volatile as $$
  select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789',
    (floor(random()*32)::int)+1, 1), '') from generate_series(1,6)
$$;

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text unique not null default public.gen_invite_code(),
  created_by uuid references public.users(id) on delete set null,
  theme_config jsonb not null default '{"primary_color":"#FF6B6B","accent_color":"#FFE66D","font_style":"rounded"}',
  xp int not null default 0,
  level int not null default 1,
  level_name text not null default 'Strangers',
  mood_alert_enabled boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  role_name text not null,
  is_admin boolean not null default false,
  joined_at timestamptz not null default now(),
  unique(group_id, user_id)
);
create index if not exists idx_group_members_user on public.group_members(user_id);
create index if not exists idx_group_members_group on public.group_members(group_id);

-- ============ last known locations (distance widget) ============
create table if not exists public.user_locations (
  user_id uuid primary key references public.users(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  updated_at timestamptz not null default now()
);

-- ============ helper functions ============
create or replace function public.is_group_member(gid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from group_members where group_id = gid and user_id = auth.uid());
$$;

create or replace function public.is_group_admin(gid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from group_members
    where group_id = gid and user_id = auth.uid() and is_admin);
$$;

create or replace function public.shares_group_with(uid uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from group_members a
    join group_members b on a.group_id = b.group_id
    where a.user_id = auth.uid() and b.user_id = uid);
$$;

-- ============ auto-provision profile on signup ============
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.users (id, username, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8)),
    coalesce(new.raw_user_meta_data->>'display_name', new.raw_user_meta_data->>'username')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============ group creation / join RPCs ============
create or replace function public.create_group(p_name text, p_role_name text)
returns public.groups
language plpgsql security definer set search_path = public as $$
declare g public.groups;
begin
  insert into groups (name, created_by) values (p_name, auth.uid()) returning * into g;
  insert into group_members (group_id, user_id, role_name, is_admin)
  values (g.id, auth.uid(), p_role_name, true);
  return g;
end;
$$;

create or replace function public.join_group(p_invite_code text, p_role_name text)
returns public.groups
language plpgsql security definer set search_path = public as $$
declare g public.groups;
begin
  select * into g from groups where invite_code = upper(trim(p_invite_code));
  if g.id is null then
    raise exception 'INVALID_INVITE_CODE';
  end if;
  insert into group_members (group_id, user_id, role_name, is_admin)
  values (g.id, auth.uid(), p_role_name, false)
  on conflict (group_id, user_id) do update set role_name = excluded.role_name;
  return g;
end;
$$;

-- ============ RLS ============
alter table public.users enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.user_locations enable row level security;

create policy users_select on public.users for select to authenticated
  using (id = auth.uid() or public.shares_group_with(id));
create policy users_update on public.users for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());
create policy users_insert on public.users for insert to authenticated
  with check (id = auth.uid());

create policy groups_select on public.groups for select to authenticated
  using (public.is_group_member(id));
create policy groups_update on public.groups for update to authenticated
  using (public.is_group_admin(id)) with check (public.is_group_admin(id));

create policy members_select on public.group_members for select to authenticated
  using (public.is_group_member(group_id));
create policy members_update on public.group_members for update to authenticated
  using (public.is_group_admin(group_id));
create policy members_delete on public.group_members for delete to authenticated
  using (public.is_group_admin(group_id) or user_id = auth.uid());

create policy locations_select on public.user_locations for select to authenticated
  using (user_id = auth.uid() or public.shares_group_with(user_id));
create policy locations_upsert on public.user_locations for insert to authenticated
  with check (user_id = auth.uid());
create policy locations_update on public.user_locations for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
