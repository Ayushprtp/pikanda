-- Virtual group pets: everyone takes care of them together
create table if not exists public.pets (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  name text not null,
  species text not null check (species in ('panda','pika','bunny','cat','penguin','dragon')),
  stage text not null default 'egg' check (stage in ('egg','baby','teen','adult')),
  hunger int not null default 80 check (hunger between 0 and 100),
  happiness int not null default 80 check (happiness between 0 and 100),
  energy int not null default 80 check (energy between 0 and 100),
  cleanliness int not null default 80 check (cleanliness between 0 and 100),
  xp int not null default 0,
  level int not null default 0,
  adopted_by uuid references public.users(id) on delete set null,
  last_decay_at timestamptz not null default now(),
  last_need_notify_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists idx_pets_group on public.pets(group_id);

create table if not exists public.pet_care_actions (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  action text not null check (action in ('feed','play','clean','sleep')),
  created_at timestamptz not null default now()
);
create index if not exists idx_pet_actions on public.pet_care_actions(pet_id, created_at desc);

create or replace function public.pet_stage_for(lvl int) returns text
language sql immutable as $$
  select case
    when lvl >= 10 then 'adult'
    when lvl >= 5 then 'teen'
    when lvl >= 1 then 'baby'
    else 'egg' end;
$$;

-- Care for a pet: applies effects, cooldown 15 min per user+action, grants XP
create or replace function public.care_for_pet(p_pet uuid, p_action text)
returns public.pets
language plpgsql security definer set search_path = public as $$
declare
  pet public.pets;
  recent int;
  old_stage text;
begin
  select * into pet from pets where id = p_pet for update;
  if pet.id is null or not public.is_group_member(pet.group_id) then
    raise exception 'NOT_A_MEMBER';
  end if;

  select count(*) into recent from pet_care_actions
   where pet_id = p_pet and user_id = auth.uid() and action = p_action
     and created_at > now() - interval '15 minutes';
  if recent > 0 then
    raise exception 'COOLDOWN';
  end if;

  old_stage := pet.stage;
  if p_action = 'feed' then
    pet.hunger := least(100, pet.hunger + 30);
  elsif p_action = 'play' then
    pet.happiness := least(100, pet.happiness + 25);
    pet.energy := greatest(0, pet.energy - 10);
  elsif p_action = 'clean' then
    pet.cleanliness := least(100, pet.cleanliness + 40);
  elsif p_action = 'sleep' then
    pet.energy := least(100, pet.energy + 40);
  else
    raise exception 'BAD_ACTION';
  end if;

  pet.xp := pet.xp + 5;
  pet.level := floor(sqrt(pet.xp / 20.0))::int; -- hatches at 20xp (4 care actions)
  pet.stage := public.pet_stage_for(pet.level);

  insert into pet_care_actions (pet_id, user_id, action) values (p_pet, auth.uid(), p_action);
  perform public.add_group_xp(pet.group_id, 2);

  update pets set hunger = pet.hunger, happiness = pet.happiness, energy = pet.energy,
    cleanliness = pet.cleanliness, xp = pet.xp, level = pet.level, stage = pet.stage
  where id = p_pet returning * into pet;

  if old_stage <> pet.stage then
    perform public.queue_notification(pet.group_id, null, null,
      '🎉 ' || pet.name || ' evolved!',
      pet.name || ' the ' || pet.species || ' is now a ' || pet.stage || '!',
      jsonb_build_object('type','pet_evolved','pet_id',pet.id,'group_id',pet.group_id));
    perform public.award_badge(auth.uid(), pet.group_id, 'pet_parent');
  end if;

  return pet;
end;
$$;

-- Stat decay, called by pg_cron hourly. Notifies group when a pet is neglected.
create or replace function public.decay_pets() returns void
language plpgsql security definer set search_path = public as $$
declare pet record; hrs numeric;
begin
  for pet in select * from pets for update loop
    hrs := extract(epoch from (now() - pet.last_decay_at)) / 3600.0;
    if hrs < 0.5 then continue; end if;
    update pets set
      hunger = greatest(0, hunger - (4 * hrs)::int),
      happiness = greatest(0, happiness - (3 * hrs)::int),
      energy = greatest(0, energy - (2 * hrs)::int),
      cleanliness = greatest(0, cleanliness - (3 * hrs)::int),
      last_decay_at = now()
    where id = pet.id;

    if (pet.hunger - 4 * hrs < 25 or pet.happiness - 3 * hrs < 25)
       and (pet.last_need_notify_at is null or pet.last_need_notify_at < now() - interval '6 hours') then
      perform public.queue_notification(pet.group_id, null, null,
        '🥺 ' || pet.name || ' needs you!',
        pet.name || ' the ' || pet.species || ' is feeling neglected — come take care of them',
        jsonb_build_object('type','pet_needs_care','pet_id',pet.id,'group_id',pet.group_id));
      update pets set last_need_notify_at = now() where id = pet.id;
    end if;
  end loop;
end;
$$;

alter table public.pets enable row level security;
alter table public.pet_care_actions enable row level security;

create policy pets_select on public.pets for select to authenticated
  using (public.is_group_member(group_id));
create policy pets_insert on public.pets for insert to authenticated
  with check (public.is_group_member(group_id) and adopted_by = auth.uid());
create policy pets_delete on public.pets for delete to authenticated
  using (public.is_group_admin(group_id));

create policy pet_actions_select on public.pet_care_actions for select to authenticated
  using (exists(select 1 from pets p where p.id = pet_id and public.is_group_member(p.group_id)));
