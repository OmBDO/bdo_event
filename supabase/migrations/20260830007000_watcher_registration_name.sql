drop function if exists public.validate_event_registration(uuid, text);

create function public.validate_event_registration(
  requested_token uuid,
  requested_event_id text
)
returns table (
  event_id text,
  user_id uuid,
  display_name text,
  status text,
  registered_at timestamptz
)
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not (public.has_current_role('watcher') or public.has_current_role('admin')) then
    raise exception 'Watcher access required';
  end if;

  return query
    select registration.event_id,
           registration.user_id,
           coalesce(
             user_record.raw_user_meta_data ->> 'display_name',
             user_record.raw_user_meta_data ->> 'full_name',
             split_part(coalesce(user_record.email, 'User'), '@', 1),
             'User'
           ),
           registration.status,
           registration.created_at
    from public.event_registrations as registration
    join auth.users as user_record on user_record.id = registration.user_id
    where registration.registration_token = requested_token
      and registration.event_id = requested_event_id
      and registration.status = 'active';
end;
$$;

revoke all on function public.validate_event_registration(uuid, text) from public;
grant execute on function public.validate_event_registration(uuid, text) to authenticated;