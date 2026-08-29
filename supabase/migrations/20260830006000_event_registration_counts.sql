create or replace function public.load_event_registration_counts(
  requested_event_ids text[]
)
returns table (
  "eventId" text,
  "registrationCount" bigint
)
language sql
security definer
set search_path = public
as $$
  select event.id,
      count(registration.registration_token)
  from public.events as event
  left join public.event_registrations as registration
    on registration.event_id = event.id
   and registration.status = 'active'
  where auth.uid() is not null
    and event.id = any(requested_event_ids)
  group by event.id;
$$;

revoke all on function public.load_event_registration_counts(text[]) from public;
grant execute on function public.load_event_registration_counts(text[]) to authenticated;