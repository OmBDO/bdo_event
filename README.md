# bdo_event

## Supabase configuration

Authentication is provided by Supabase. Start the app with the project URL and
publishable anon key supplied as compile-time defines:

```text
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

The required variable names are also listed in [.env.example](.env.example).
Flutter does not automatically load `.env` files, so pass the values as
`--dart-define` arguments or configure them in your IDE launch settings.

The sign-up flow stores the display name in Supabase user metadata. Roles are
requested during sign-up as `requested_role` in client-editable user metadata,
but effective roles (`user`, `admin`, or `watcher`) are read from Supabase
`app_metadata` and must be assigned by a trusted backend; they are never
granted from client-editable user metadata. The default effective role is
`user`. Enable the
email/password provider in the Supabase dashboard. If email confirmation is
enabled, users must confirm their address before signing in.

The schema creates a `role_requests` record from the signup metadata. An
administrator or trusted backend must review that request and assign the
effective role in Supabase `app_metadata`; approving a request must never be
implemented by the client.

The database schema is tracked as versioned migrations, including the
[initial schema](supabase/migrations/20260829000000_initial_schema.sql), seat
limit enforcement, and [registration deadline enforcement](supabase/migrations/20260830005000_enforce_registration_deadline.sql).
For a project with the Supabase CLI installed, initialize and link the local
project once, then apply migrations with:

```text
supabase init
supabase link --project-ref <your-project-ref>
supabase db push
```

For local database development, use `supabase start` and `supabase db reset` to
apply the migrations to the local Postgres instance. The committed
[Supabase CLI configuration](supabase/config.toml) uses the conventional local
API, database, Studio, and Inbucket ports. If the CLI is not available, run the
migration files in the Supabase SQL editor before using event creation or
registration. Row-level security policies restrict event mutations to their
creator and registrations to their owner.

## Integration test environment

Integration tests use a disposable Supabase project whenever possible. Start
the local project and apply every migration before running them:

```text
supabase start
supabase db reset
```

Provide `SUPABASE_URL` and `SUPABASE_ANON_KEY` to the app/test process. The
host-side actor registrar and cleanup code may also receive
`SUPABASE_SERVICE_ROLE_KEY`, but that value must stay in CI or the host shell;
do not place it in `.env`, compile it into the Flutter application, or send it
to a device. Integration actors and event records are created with a unique
run namespace, so a fixed shared seed user is intentionally not required.
The expected variables are listed in
[`test/integration_test/.env.example`](test/integration_test/.env.example).

Registration cancellation is persisted as a server-side `revoked` status.
Revoked registrations are excluded from active registration queries, direct
client inserts are blocked, and the registration activation RPC refuses to
reactivate them. The cancelled registration QR therefore cannot be accepted
as an active registration. Re-registration with a new per-registration QR
token is reserved for the watcher validation slice.

Event creators can optionally enable a seat limit while creating or editing an
event. The configured `capacity` is stored in the event payload and enforced
by the server-side registration RPC using the count of active registrations.
The setting is disabled by default, and registrations are rejected once the
active count reaches the configured capacity.

Event creators can also optionally set a registration deadline with a date and
time. The deadline is stored as `registrationDeadline` in the event payload,
shown in the event editor when updating an event, and can be cleared by
disabling the setting. The client disables registration after the deadline,
while the server-side registration RPC enforces it atomically. The setting is
disabled by default.

Events can include a start time and end time in `HH:mm` format. These values
are stored in the event payload and are displayed on the event-detail screen
and the My Ticket card only. Existing events without timing continue to load
without a time display.

## Event sharing and deep links

The event detail menu shares links in the form
`https://bdo-event.app/events/<event-id>`. When the app is installed, a matching
link opens the exact event detail page after the user is authenticated. The
`app_links` integration also supports the `bdoevent://events/<event-id>` scheme
for local device testing.

The default domain is a placeholder until a public web host is configured. To
use another domain, build with `EVENT_LINK_BASE_URL`, for example:

```text
flutter run --dart-define=EVENT_LINK_BASE_URL=https://events.example.com
```

That domain must host an event page with `og:title`, `og:description`, and
`og:image` metadata for WhatsApp previews. It must also serve
`/.well-known/assetlinks.json` for Android and
`/.well-known/apple-app-site-association` for iOS. Update the Android manifest,
`Runner.entitlements`, and the association files with the real domain and
release signing identifiers before production distribution. Without a hosted
domain, shared HTTPS links can still be copied, but rich previews and automatic
app opening cannot work reliably.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Architecture

![Code Architecture](/assets/help/code%20architecture.png)
