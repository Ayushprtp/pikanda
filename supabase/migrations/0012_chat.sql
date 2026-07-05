-- Group chat messages (live delivery also goes over Realtime Broadcast;
-- this table adds persistence + push notifications)
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  sender_id uuid not null references public.users(id) on delete cascade,
  content text not null check (char_length(content) <= 2000),
  created_at timestamptz not null default now()
);
create index if not exists idx_messages_group_time
  on public.messages(group_id, created_at desc);

alter table public.messages enable row level security;

create policy messages_select on public.messages for select to authenticated
  using (public.is_group_member(group_id));
create policy messages_insert on public.messages for insert to authenticated
  with check (sender_id = auth.uid() and public.is_group_member(group_id));

-- push notification for members who aren't in the app
create or replace function public.notify_on_message() returns trigger
language plpgsql security definer set search_path = public as $$
declare sender_name text;
begin
  select role_name into sender_name from group_members
    where group_id = new.group_id and user_id = new.sender_id;
  perform public.queue_notification(new.group_id, null, new.sender_id,
    coalesce(sender_name,'Someone'), left(new.content, 140),
    jsonb_build_object('type','chat','group_id',new.group_id));
  return new;
end;
$$;
drop trigger if exists trg_notify_message on public.messages;
create trigger trg_notify_message after insert on public.messages
  for each row execute function public.notify_on_message();

-- chat XP: +1 per message
create or replace function public.xp_on_message() returns trigger
language plpgsql security definer set search_path = public as $$
begin perform public.add_group_xp(new.group_id, 1); return new; end; $$;
drop trigger if exists trg_xp_message on public.messages;
create trigger trg_xp_message after insert on public.messages
  for each row execute function public.xp_on_message();

do $$
begin
  begin
    alter publication supabase_realtime add table public.messages;
  exception when duplicate_object then null; end;
end $$;
