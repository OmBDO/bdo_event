create or replace function public.create_role_request()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_requested_role text := new.raw_user_meta_data ->> 'requested_role';
begin
  if v_requested_role in ('user', 'admin', 'watcher') then
    insert into public.role_requests (user_id, requested_role)
    values (new.id, v_requested_role)
    on conflict (user_id, requested_role, status) do nothing;
  end if;

  return new;
end;
$$;
