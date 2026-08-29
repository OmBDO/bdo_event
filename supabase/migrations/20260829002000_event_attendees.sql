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
    (auth.jwt() -> 'app_metadata' -> 'roles') ? 'admin'
    or (auth.jwt() -> 'app_metadata' -> 'roles') ? 'watcher'
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

create or replace function public.load_event_attendance_count(requested_event_id text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not (
    (auth.jwt() -> 'app_metadata' -> 'roles') ? 'admin'
    or (auth.jwt() -> 'app_metadata' -> 'roles') ? 'watcher'
    or exists (
      select 1
      from public.events
      where id = requested_event_id
        and creator_id = auth.uid()
    )
  ) then
    raise exception 'Event access denied';
  end if;

  return (
    select count(*)
    from public.event_registrations
    where event_id = requested_event_id
      and status = 'active'
  );
end;
$$;

revoke all on function public.load_event_attendance_count(text) from public;
grant execute on function public.load_event_attendance_count(text) to authenticated;

create or replace function public.load_event_check_in_count(requested_event_id text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not (
    (auth.jwt() -> 'app_metadata' -> 'roles') ? 'admin'
    or (auth.jwt() -> 'app_metadata' -> 'roles') ? 'watcher'
    or exists (
      select 1
      from public.events
      where id = requested_event_id
        and creator_id = auth.uid()
    )
  ) then
    raise exception 'Event access denied';
  end if;

  return (
    select count(*)
    from public.event_check_ins
    where event_id = requested_event_id
  );
end;
$$;

revoke all on function public.load_event_check_in_count(text) from public;
grant execute on function public.load_event_check_in_count(text) to authenticated;