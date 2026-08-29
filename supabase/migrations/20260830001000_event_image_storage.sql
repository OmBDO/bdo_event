insert into storage.buckets (id, name, public)
values ('event-images', 'event-images', false)
on conflict (id) do update set public = excluded.public;

drop policy if exists "Authenticated users can view event images"
  on storage.objects;
drop policy if exists "Authenticated users can upload event images"
  on storage.objects;
drop policy if exists "Owners can update event images"
  on storage.objects;
drop policy if exists "Owners can delete event images"
  on storage.objects;

create policy "Authenticated users can view event images"
on storage.objects for select to authenticated
using (bucket_id = 'event-images');

create policy "Authenticated users can upload event images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'event-images'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "Owners can update event images"
on storage.objects for update to authenticated
using (
  bucket_id = 'event-images'
  and owner_id = (select auth.uid()::text)
)
with check (
  bucket_id = 'event-images'
  and owner_id = (select auth.uid()::text)
);

create policy "Owners can delete event images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'event-images'
  and owner_id = (select auth.uid()::text)
);