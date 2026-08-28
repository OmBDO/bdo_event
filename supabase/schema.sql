create table if not exists public.events (
  id text primary key,
  creator_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  payload jsonb not null
);

create table if not exists public.event_registrations (
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id text not null references public.events(id) on delete cascade,
  payload jsonb not null,
  created_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

alter table public.events enable row level security;
alter table public.event_registrations enable row level security;

create policy "Authenticated users can view events"
  on public.events for select
  to authenticated
  using (true);

create policy "Organizers can create their events"
  on public.events for insert
  to authenticated
  with check (auth.uid() = creator_id);

create policy "Creators can update their events"
  on public.events for update
  to authenticated
  using (
    auth.uid() = creator_id
    or (auth.jwt() -> 'app_metadata' -> 'roles') ? 'administrator'
  )
  with check (
    auth.uid() = creator_id
    or (auth.jwt() -> 'app_metadata' -> 'roles') ? 'administrator'
  );

create policy "Creators can delete their events"
  on public.events for delete
  to authenticated
  using (
    auth.uid() = creator_id
    or (auth.jwt() -> 'app_metadata' -> 'roles') ? 'administrator'
  );

create policy "Users can view their registrations"
  on public.event_registrations for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can create their registrations"
  on public.event_registrations for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Users can delete their registrations"
  on public.event_registrations for delete
  to authenticated
  using (auth.uid() = user_id);

create index if not exists events_creator_id_idx
  on public.events (creator_id);

create index if not exists event_registrations_event_id_idx
  on public.event_registrations (event_id);