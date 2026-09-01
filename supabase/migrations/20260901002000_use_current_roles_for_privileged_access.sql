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
    public.has_current_role('admin')
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
set search_path = public, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not (
    public.has_current_role('admin')
    or public.has_current_role('watcher')
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
    public.has_current_role('admin')
    or public.has_current_role('watcher')
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

create or replace function public.list_invitation_recipients()
returns table (user_id uuid, display_name text, email text)
language sql
security definer
set search_path = public, auth
as $$
  select users.id,
         coalesce(users.raw_user_meta_data ->> 'display_name', '') as display_name,
         users.email
  from auth.users as users
  where public.has_current_role('admin')
    and users.id <> auth.uid()
  order by display_name, email;
$$;

revoke all on function public.list_invitation_recipients() from public;
grant execute on function public.list_invitation_recipients() to authenticated;

create or replace function public.send_event_invitations(
  requested_event_id text,
  requested_user_ids uuid[]
)
returns integer
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  inserted_count integer;
begin
  if not public.has_current_role('admin') then
    raise exception 'Admin access required';
  end if;
  if not exists (select 1 from public.events where id = requested_event_id) then
    raise exception 'Event not found';
  end if;

  insert into public.event_invitations (event_id, inviter_id, invitee_id)
  select requested_event_id, auth.uid(), recipient
  from unnest(requested_user_ids) as recipient
  where recipient <> auth.uid()
  on conflict (event_id, invitee_id) do nothing;
  get diagnostics inserted_count = row_count;

  insert into public.notifications (
    user_id, event_id, notification_type, title, message, event_date
  )
  select invitation.invitee_id,
         event.id,
         'invitation',
         'You are invited to an event',
         'You have been invited to ' || coalesce(event.payload ->> 'title', 'an event') || '.',
         case
           when event.payload ->> 'date' ~ '^\d{4}-\d{2}-\d{2}'
             then (event.payload ->> 'date')::date
           else to_date(event.payload ->> 'date', 'DD/MM/YYYY')
         end
  from public.event_invitations as invitation
  join public.events as event on event.id = invitation.event_id
  where invitation.event_id = requested_event_id
    and invitation.inviter_id = auth.uid()
    and invitation.invitee_id = any(requested_user_ids)
    and invitation.status = 'pending'
  on conflict (user_id, event_id, notification_type) do nothing;
  return inserted_count;
end;
$$;

revoke all on function public.send_event_invitations(text, uuid[]) from public;
grant execute on function public.send_event_invitations(text, uuid[]) to authenticated;
