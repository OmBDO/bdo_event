drop policy if exists "Users can delete their registrations"
  on public.event_registrations;

revoke delete on table public.event_registrations from authenticated;
