create or replace function public.create_role_request() returns triggerlanguage plpgsqlsecurity definerset search_path = publicas $ $
declare v_requested_role text := new.raw_user_meta_data->>'requested_role';
begin if v_requested_role in ('user', 'admin', 'watcher') then
insert into public.role_requests (user_id, requested_role)
values (new.id, v_requested_role) on conflict (user_id, requested_role, status) do nothing;
end if;
return new;
end;
$ $;