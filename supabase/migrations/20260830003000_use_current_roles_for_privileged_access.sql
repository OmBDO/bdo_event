create or replace function public.has_current_role(required_role text)
returns boolean
language sql
security definer
stable
set search_path = auth, pg_temp
as $$
  select exists (
    select 1
    from auth.users
    where id = (select auth.uid())
      and raw_app_meta_data -> 'roles' ? required_role
  );
$$;

revoke all on function public.has_current_role(text) from public;
grant execute on function public.has_current_role(text) to authenticated;

create or replace function public.validate_event_registration(
  requested_token uuid,
  requested_event_id text
)
returns table (
  event_id text,
  user_id uuid,
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

  if not (
    public.has_current_role('watcher')
    or public.has_current_role('admin')
  ) then
    raise exception 'Watcher access required';
  end if;

  return query
    select registration.event_id,
           registration.user_id,
           registration.status,
           registration.created_at
    from public.event_registrations as registration
    where registration.registration_token = requested_token
      and registration.event_id = requested_event_id
      and registration.status = 'active';
end;
$$;

revoke all on function public.validate_event_registration(uuid, text) from public;
grant execute on function public.validate_event_registration(uuid, text) to authenticated;

create or replace function public.check_in_event_registration(
  requested_token uuid,
  requested_event_id text
)
returns text
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  registration public.event_registrations%rowtype;
  inserted_token uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not (
    public.has_current_role('watcher')
    or public.has_current_role('admin')
  ) then
    raise exception 'Watcher access required';
  end if;

  select * into registration
  from public.event_registrations
  where registration_token = requested_token
    and event_id = requested_event_id
    and status = 'active';

  if not found then
    return 'invalid';
  end if;

  insert into public.event_check_ins (
    registration_token, event_id, user_id, checked_in_by
  ) values (
    registration.registration_token,
    registration.event_id,
    registration.user_id,
    auth.uid()
  ) on conflict (registration_token) do nothing
  returning registration_token into inserted_token;

  if inserted_token is null then
    return 'already_checked_in';
  end if;
  return 'checked_in';
end;
$$;

revoke all on function public.check_in_event_registration(uuid, text) from public;
grant execute on function public.check_in_event_registration(uuid, text) to authenticated;

drop policy if exists "Admins can create their events" on public.events;
create policy "Admins can create their events"
  on public.events for insert
  to authenticated
  with check (
    auth.uid() = creator_id
    and public.has_current_role('admin')
  );

drop policy if exists "Creators can update their events" on public.events;
create policy "Creators can update their events"
  on public.events for update
  to authenticated
  using (
    auth.uid() = creator_id
    or public.has_current_role('admin')
  )
  with check (
    auth.uid() = creator_id
    or public.has_current_role('admin')
  );

drop policy if exists "Creators can delete their events" on public.events;
create policy "Creators can delete their events"
  on public.events for delete
  to authenticated
  using (
    auth.uid() = creator_id
    or public.has_current_role('admin')
  );

drop policy if exists "Admins can view role requests" on public.role_requests;
create policy "Admins can view role requests"
  on public.role_requests for select
  to authenticated
  using (public.has_current_role('admin'));

drop policy if exists "Admins can review role requests" on public.role_requests;
create policy "Admins can review role requests"
  on public.role_requests for update
  to authenticated
  using (public.has_current_role('admin'))
  with check (public.has_current_role('admin'));
