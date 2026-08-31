create or replace function public.event_has_ended(event_payload jsonb)
returns boolean
language plpgsql
stable
set search_path = public
as $$
declare
  raw_date text := event_payload ->> 'date';
  raw_end_time text := event_payload ->> 'endTime';
  event_date date;
  event_end time;
begin
  if raw_date ~ '^\d{4}-\d{2}-\d{2}' then
    event_date := raw_date::date;
  elsif raw_date ~ '^\d{1,2}/\d{1,2}/\d{4}$' then
    event_date := to_date(raw_date, 'DD/MM/YYYY');
  else
    return false;
  end if;

  if raw_end_time ~ '^([01]?[0-9]|2[0-3]):[0-5][0-9]$' then
    event_end := make_time(
      split_part(raw_end_time, ':', 1)::integer,
      split_part(raw_end_time, ':', 2)::integer,
      0
    );
    return localtimestamp >= event_date + event_end;
  end if;

  return event_date < current_date;
end;
$$;

revoke all on function public.event_has_ended(jsonb) from public;
