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

The database schema is tracked as the versioned migration
[20260829000000_initial_schema.sql](supabase/migrations/20260829000000_initial_schema.sql).
For a project with the Supabase CLI installed, initialize and link the local
project once, then apply migrations with:

```text
supabase init
supabase link --project-ref <your-project-ref>
supabase db push
```

For local database development, use `supabase start` and `supabase db reset` to
apply the migrations to the local Postgres instance. If the CLI is not
available, run the migration file in the Supabase SQL editor before using event
creation or registration. Row-level security policies restrict event mutations
to their creator and registrations to their owner.

Registration cancellation is persisted as a server-side `revoked` status.
Revoked registrations are excluded from active registration queries, direct
client inserts are blocked, and the registration activation RPC refuses to
reactivate them. The cancelled registration QR therefore cannot be accepted
as an active registration. Re-registration with a new per-registration QR
token is reserved for the watcher validation slice.

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
