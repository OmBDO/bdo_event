create or replace function public.load_event_attendees(requested_event_id text)
returns table (
  "userId" uuid,
  "displayName" text,
  "photoUrl" text
)
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not (
    exists (
      select 1
      from auth.users
      where id = auth.uid()
        and raw_app_meta_data -> 'roles' ? 'admin'
    )
    or exists (
      select 1
      from public.events
      where id = requested_event_id
        and creator_id = auth.uid()
    )
  ) then
    raise exception 'Event access denied';
  end if;

  return query
    select registration.user_id,
           coalesce(
             user_record.raw_user_meta_data ->> 'display_name',
             user_record.raw_user_meta_data ->> 'full_name',
             split_part(coalesce(user_record.email, 'User'), '@', 1),
             'User'
           ),
           coalesce(
             user_record.raw_user_meta_data ->> 'photo_url',
             user_record.raw_user_meta_data ->> 'avatar_url',
             user_record.raw_user_meta_data ->> 'picture'
           )
    from public.event_registrations as registration
    join auth.users as user_record on user_record.id = registration.user_id
    where registration.event_id = requested_event_id
      and registration.status = 'active'
    order by registration.created_at;
end;
$$;

revoke all on function public.load_event_attendees(text) from public;
grant execute on function public.load_event_attendees(text) to authenticated;