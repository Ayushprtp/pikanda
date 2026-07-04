-- Storage buckets + group-scoped access policies.
-- Path convention: <group_id>/<user_id>/<filename> (avatars: <user_id>/<filename>)
insert into storage.buckets (id, name, public)
values ('zaps','zaps',false), ('voice-notes','voice-notes',false),
       ('capsules','capsules',false), ('avatars','avatars',false)
on conflict (id) do nothing;

-- group-content buckets: members read, uploader writes to own folder
create policy "group buckets read" on storage.objects for select to authenticated
using (
  bucket_id in ('zaps','voice-notes','capsules')
  and public.is_group_member(((storage.foldername(name))[1])::uuid)
);

create policy "group buckets insert" on storage.objects for insert to authenticated
with check (
  bucket_id in ('zaps','voice-notes','capsules')
  and public.is_group_member(((storage.foldername(name))[1])::uuid)
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "group buckets delete own" on storage.objects for delete to authenticated
using (
  bucket_id in ('zaps','voice-notes','capsules')
  and (storage.foldername(name))[2] = auth.uid()::text
);

-- avatars: owner writes, groupmates read
create policy "avatar read" on storage.objects for select to authenticated
using (
  bucket_id = 'avatars'
  and (
    (storage.foldername(name))[1] = auth.uid()::text
    or public.shares_group_with(((storage.foldername(name))[1])::uuid)
  )
);

create policy "avatar write" on storage.objects for insert to authenticated
with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatar update" on storage.objects for update to authenticated
using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatar delete" on storage.objects for delete to authenticated
using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
