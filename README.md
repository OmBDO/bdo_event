# bdo_event

## Supabase configuration

Authentication is provided by Supabase. Start the app with the project URL and
publishable anon key supplied as compile-time defines:

```text
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

The sign-up flow stores the display name in Supabase user metadata. Roles are
read from Supabase `app_metadata` and must be assigned by a trusted backend;
they are never accepted from client-editable user metadata. Enable the
email/password provider in the Supabase dashboard. If email confirmation is
enabled, users must confirm their address before signing in.

Run [supabase/schema.sql](supabase/schema.sql) in the Supabase SQL editor before
using event creation or registration. Row-level security policies restrict
event mutations to their creator and registrations to their owner.

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
