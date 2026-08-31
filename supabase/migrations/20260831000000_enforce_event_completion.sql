create or replace function public.event_has_ended(event_payload jsonb)
returns boolean
language sql
stable
set search_path = public
as $$
  select case
    when event_payload ->> 'date' ~ '^\d{4}-\d{2}-\d{2}' then
      (event_payload ->> 'date')::date < current_date
    when event_payload ->> 'date' ~ '^\d{1,2}/\d{1,2}/\d{4}$' then
      to_date(event_payload ->> 'date', 'DD/MM/YYYY') < current_date
    else false
  end;
$$;

revoke all on function public.event_has_ended(jsonb) from public;

create or replace function public.activate_event_registration(
  requested_event_id text,
  event_payload jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  event_record public.events%rowtype;
  event_capacity integer;
  registration_deadline timestamptz;
  active_registration_count bigint;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select * into event_record
  from public.events
  where id = requested_event_id
  for update;

  if not found then
    raise exception 'Event no longer available';
  end if;

  if public.event_has_ended(event_record.payload) then
    raise exception 'Event has ended';
  end if;

  event_capacity := nullif(event_record.payload ->> 'capacity', '')::integer;
  registration_deadline := nullif(
    event_record.payload ->> 'registrationDeadline',
    ''
  )::timestamptz;

  if registration_deadline is not null and now() >= registration_deadline then
    raise exception 'Registration for this event has closed';
  end if;

  if exists (
    select 1
    from public.event_registrations
    where user_id = auth.uid()
      and event_id = requested_event_id
      and status = 'active'
  ) then
    raise exception 'Already registered for this event';
  end if;

  select count(*) into active_registration_count
  from public.event_registrations
  where event_id = requested_event_id
    and status = 'active';

  if event_capacity is not null and active_registration_count >= event_capacity then
    raise exception 'Event has reached its capacity';
  end if;

  insert into public.event_registrations (user_id, event_id, payload, status, cancelled_at)
  values (auth.uid(), requested_event_id, event_payload, 'active', null);
end;
$$;

revoke all on function public.activate_event_registration(text, jsonb) from public;
grant execute on function public.activate_event_registration(text, jsonb) to authenticated;
