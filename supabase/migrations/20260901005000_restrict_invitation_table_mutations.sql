drop policy if exists event_invitations_select on public.event_invitations;
create policy event_invitations_select on public.event_invitations
  for select
  to authenticated
  using (inviter_id = auth.uid() or invitee_id = auth.uid());

drop policy if exists event_invitations_insert on public.event_invitations;
create policy event_invitations_insert on public.event_invitations
  for insert
  to authenticated
  with check (false);

drop policy if exists event_invitations_update on public.event_invitations;
create policy event_invitations_update on public.event_invitations
  for update
  to authenticated
  using (false)
  with check (false);

revoke insert, update, delete on table public.event_invitations from authenticated;
