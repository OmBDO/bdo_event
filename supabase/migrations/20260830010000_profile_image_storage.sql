insert into storage.buckets (id, name, public)
values ('profile-images', 'profile-images', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists "profile images are publicly readable" on storage.objects;
drop policy if exists "users can upload their profile image" on storage.objects;
drop policy if exists "users can update their profile image" on storage.objects;
drop policy if exists "users can delete their profile image" on storage.objects;

create policy "profile images are publicly readable"
on storage.objects for select
using (bucket_id = 'profile-images');

create policy "users can upload their profile image"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "users can update their profile image"
on storage.objects for update to authenticated
using (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
)
with check (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "users can delete their profile image"
on storage.objects for delete to authenticated
using (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);