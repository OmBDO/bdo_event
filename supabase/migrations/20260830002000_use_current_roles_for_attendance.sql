create or replace function public.load_event_attendance_count(requested_event_id text)
returns bigint
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
      from auth.users
      where id = auth.uid()
        and raw_app_meta_data -> 'roles' ? 'watcher'
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
      from auth.users
      where id = auth.uid()
        and raw_app_meta_data -> 'roles' ? 'watcher'
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

  return (
    select count(*)
    from public.event_check_ins
    where event_id = requested_event_id
  );
end;
$$;

revoke all on function public.load_event_check_in_count(text) from public;
grant execute on function public.load_event_check_in_count(text) to authenticated;
