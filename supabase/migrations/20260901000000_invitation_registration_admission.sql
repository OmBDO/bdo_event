create or replace function public.respond_to_event_invitation(
  requested_event_id text,
  requested_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  invitation public.event_invitations%rowtype;
  event_payload jsonb;
begin
  if requested_status not in ('accepted', 'declined') then
    raise exception 'Invalid invitation response';
  end if;

  select * into invitation
  from public.event_invitations
  where event_id = requested_event_id
    and invitee_id = auth.uid()
    and status = 'pending'
  order by created_at desc
  limit 1;

  if not found then
    raise exception 'Invitation not found';
  end if;

  if requested_status = 'accepted' then
    select payload into event_payload
    from public.events
    where id = requested_event_id;

    if not found then
      raise exception 'Event no longer available';
    end if;

    perform public.activate_event_registration(
      requested_event_id,
      event_payload
    );
  end if;

  update public.event_invitations
  set status = requested_status, responded_at = now()
  where id = invitation.id;
end;
$$;

revoke all on function public.respond_to_event_invitation(text, text) from public;
grant execute on function public.respond_to_event_invitation(text, text) to authenticated;
