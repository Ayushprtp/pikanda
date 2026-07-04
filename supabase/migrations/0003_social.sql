-- Zaps, reactions, voice notes, pokes, whispers, notification queue
create table if not exists public.zaps (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  sender_id uuid not null references public.users(id) on delete cascade,
  receiver_id uuid references public.users(id) on delete cascade, -- null = whole group
  image_url text,
  caption text,
  emoji text,
  doodle_data jsonb,
  seen boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_zaps_group_time on public.zaps(group_id, created_at desc);
create index if not exists idx_zaps_receiver on public.zaps(receiver_id, seen);

create table if not exists public.voice_notes (
  id uuid primary key default gen_random_uuid(),
  zap_id uuid not null references public.zaps(id) on delete cascade,
  storage_url text not null,
  duration_seconds int not null,
  created_at timestamptz not null default now()
);

create table if not exists public.zap_reactions (
  id uuid primary key default gen_random_uuid(),
  zap_id uuid not null references public.zaps(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  emoji text not null,
  created_at timestamptz not null default now(),
  unique(zap_id, user_id)
);

create table if not exists public.pokes (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  from_user uuid not null references public.users(id) on delete cascade,
  to_user uuid not null references public.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create index if not exists idx_pokes_group on public.pokes(group_id, created_at desc);

create table if not exists public.whispers (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  encrypted_sender_id text not null, -- AES encrypted client-side with group key
  message text not null,
  created_at timestamptz not null default now()
);

-- ============ notification queue (processed by send-fcm edge fn) ============
create table if not exists public.notification_queue (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references public.groups(id) on delete cascade,
  recipient_id uuid references public.users(id) on delete cascade, -- null = all group members
  exclude_user uuid,
  title text not null,
  body text not null,
  data jsonb not null default '{}',
  status text not null default 'pending' check (status in ('pending','sent','skipped','failed')),
  created_at timestamptz not null default now(),
  processed_at timestamptz
);
create index if not exists idx_notifq_pending on public.notification_queue(status) where status = 'pending';

create or replace function public.queue_notification(
  p_group uuid, p_recipient uuid, p_exclude uuid, p_title text, p_body text, p_data jsonb default '{}')
returns void language sql security definer set search_path = public as $$
  insert into notification_queue (group_id, recipient_id, exclude_user, title, body, data)
  values (p_group, p_recipient, p_exclude, p_title, p_body, coalesce(p_data,'{}'));
$$;

-- Auto-notify on zap / poke
create or replace function public.notify_on_zap() returns trigger
language plpgsql security definer set search_path = public as $$
declare sender_name text;
begin
  select role_name into sender_name from group_members
    where group_id = new.group_id and user_id = new.sender_id;
  perform public.queue_notification(new.group_id, new.receiver_id, new.sender_id,
    '⚡ New Zap!', coalesce(sender_name,'Someone') || ' sent a zap',
    jsonb_build_object('type','zap','zap_id',new.id,'group_id',new.group_id));
  return new;
end;
$$;
drop trigger if exists trg_notify_zap on public.zaps;
create trigger trg_notify_zap after insert on public.zaps
  for each row execute function public.notify_on_zap();

create or replace function public.notify_on_poke() returns trigger
language plpgsql security definer set search_path = public as $$
declare sender_name text;
begin
  select role_name into sender_name from group_members
    where group_id = new.group_id and user_id = new.from_user;
  perform public.queue_notification(new.group_id, new.to_user, null,
    '⚡ Poke!', coalesce(sender_name,'Someone') || ' poked you ⚡',
    jsonb_build_object('type','poke','group_id',new.group_id));
  return new;
end;
$$;
drop trigger if exists trg_notify_poke on public.pokes;
create trigger trg_notify_poke after insert on public.pokes
  for each row execute function public.notify_on_poke();

create or replace function public.notify_on_whisper() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform public.queue_notification(new.group_id, null, null,
    '🤍 Whisper', 'Someone in your group says: ' || left(new.message, 120),
    jsonb_build_object('type','whisper','group_id',new.group_id));
  return new;
end;
$$;
drop trigger if exists trg_notify_whisper on public.whispers;
create trigger trg_notify_whisper after insert on public.whispers
  for each row execute function public.notify_on_whisper();

create or replace function public.notify_on_reaction() returns trigger
language plpgsql security definer set search_path = public as $$
declare z record; reactor text;
begin
  select * into z from zaps where id = new.zap_id;
  select role_name into reactor from group_members
    where group_id = z.group_id and user_id = new.user_id;
  perform public.queue_notification(z.group_id, z.sender_id, new.user_id,
    'Reaction', coalesce(reactor,'Someone') || ' reacted ' || new.emoji || ' to your Zap',
    jsonb_build_object('type','zap_reaction','zap_id',z.id,'group_id',z.group_id));
  return new;
end;
$$;
drop trigger if exists trg_notify_reaction on public.zap_reactions;
create trigger trg_notify_reaction after insert on public.zap_reactions
  for each row execute function public.notify_on_reaction();

-- RLS
alter table public.zaps enable row level security;
alter table public.voice_notes enable row level security;
alter table public.zap_reactions enable row level security;
alter table public.pokes enable row level security;
alter table public.whispers enable row level security;
alter table public.notification_queue enable row level security;

create policy zaps_select on public.zaps for select to authenticated
  using (public.is_group_member(group_id));
create policy zaps_insert on public.zaps for insert to authenticated
  with check (sender_id = auth.uid() and public.is_group_member(group_id));
create policy zaps_update_seen on public.zaps for update to authenticated
  using (public.is_group_member(group_id));

create policy voice_select on public.voice_notes for select to authenticated
  using (exists(select 1 from zaps z where z.id = zap_id and public.is_group_member(z.group_id)));
create policy voice_insert on public.voice_notes for insert to authenticated
  with check (exists(select 1 from zaps z where z.id = zap_id and z.sender_id = auth.uid()));

create policy reactions_select on public.zap_reactions for select to authenticated
  using (exists(select 1 from zaps z where z.id = zap_id and public.is_group_member(z.group_id)));
create policy reactions_upsert on public.zap_reactions for insert to authenticated
  with check (user_id = auth.uid()
    and exists(select 1 from zaps z where z.id = zap_id and public.is_group_member(z.group_id)));
create policy reactions_update on public.zap_reactions for update to authenticated
  using (user_id = auth.uid());
create policy reactions_delete on public.zap_reactions for delete to authenticated
  using (user_id = auth.uid());

create policy pokes_select on public.pokes for select to authenticated
  using (public.is_group_member(group_id));
create policy pokes_insert on public.pokes for insert to authenticated
  with check (from_user = auth.uid() and public.is_group_member(group_id));

create policy whispers_select on public.whispers for select to authenticated
  using (public.is_group_member(group_id));
create policy whispers_insert on public.whispers for insert to authenticated
  with check (public.is_group_member(group_id));

-- queue is written via security-definer fns and read by service role only: no user policies.
