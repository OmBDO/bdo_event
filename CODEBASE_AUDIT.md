# BDO Event Codebase Audit

**Audit date:** 2026-09-01
**Scope:** Flutter/Dart application, Supabase migrations and RLS, platform adapters, tests, and CI
**Method:** Read-only review of source, call sites, migrations, test harnesses, and workflow configuration. No source files were changed during the audit. The existing user modification in `lib/features/profile_screen/presentation/pages/profile_screen.dart` was inspected and left untouched.

## Executive Summary

The codebase has a coherent feature-first Flutter structure, Cubit state management, GetIt dependency injection, adapter seams for platform services, and a substantial integration-test harness. The most important risks are at the registration and authorization boundary: several database paths can bypass the invariants enforced by the normal registration path, and some privileged operations rely on stale JWT role claims instead of current database roles.

The next group of risks comes from duplicated temporal representations, stale asynchronous responses, and a migration manifest that does not include the latest migration. The remaining findings are lifecycle, cache, model, and logging improvements.

## Current Repository State

- Branch: `main`, ahead of `origin/main` by one commit.
- The audit itself made no source changes.
- The profile screen has an existing user/formatter modification and was not edited.
- No unresolved merge entries or conflict markers remain.
- Editor diagnostics report no errors.
- Flutter/Dart runtime validation is currently unavailable on this Windows environment because the Flutter wrapper and direct Dart executable return access-denied failures.

## Subsystem Inventory

| Area                       | Main boundaries                                          | Key implementation surfaces                                                                             | Status                   |
| -------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ------------------------ |
| Bootstrap and DI           | Application startup, GetIt registrations, Cubit lifetime | `lib/core/bootstrap/application_bootstrap.dart`, `lib/core/di/app_dependencies.dart`                    | Recommendations          |
| Navigation shell           | Tab state and page lifetime                              | `lib/features/main_screen/presentation/widgets/main_screen_shell.dart`, `main_screen_destinations.dart` | Recommendation           |
| Core models/resources      | Event, user, category, tokens, database keys             | `lib/core/model`, `lib/core/util/resource`                                                              | Recommendations          |
| Date/time policy           | Display, filtering, reminders, completion                | `event_schedule.dart`, `event_date_formatter.dart`, `event_reminder_policy.dart`                        | Recommendation           |
| Authentication             | Session restore, role mapping, logout                    | `lib/features/auth_screen`                                                                              | Recommendation           |
| Event/calendar             | Loading, creation, filtering, recent events              | `lib/features/event_screen`, `lib/features/calendar_screen`                                             | Recommendations          |
| Registration/detail/ticket | Admission, revoke, ticket, attendees                     | `lib/features/event_detail_screen`, `lib/features/registered_screen`                                    | P0 recommendations       |
| Profile/preferences        | User settings, visibility, persistence                   | `lib/features/profile_screen`                                                                           | Recommendation           |
| Notifications              | Scheduling, invitation actions, arrivals                 | `lib/core/notifications`, `lib/features/notification_screen`                                            | Recommendation           |
| Watcher                    | QR validation, check-in, dashboard                       | `lib/features/watcher_screen`                                                                           | Recommendation           |
| Platform adapters          | Storage, image picker, scanner, biometrics, TTS, haptics | `lib/core/common`                                                                                       | Lifecycle recommendation |
| Supabase security          | RPCs, RLS, grants, storage                               | `supabase/migrations`                                                                                   | P0/P1 recommendations    |
| Tests and CI               | Unit/widget/integration harnesses and workflows          | `test`, `.github/workflows`                                                                             | Recommendation           |

## Recommendations

### P0-1: Use one authoritative registration-admission path

**Impact:** High
**Confidence:** High
**Effort:** Medium
**Blast radius:** Supabase invitation and registration flows

Invitation acceptance directly inserts an active registration in `supabase/migrations/20260830009000_product_capabilities.sql`. The normal `activate_event_registration` RPC in `supabase/migrations/20260831000000_enforce_event_completion.sql` separately enforces event existence, completion, deadline, duplicate registration, and capacity.

This creates inconsistent states: an invitee can accept after the deadline, after the event has finished, or after capacity is reached. The invitation function should invoke the authoritative admission function using the event payload read from `public.events`. The entire function is transactional, so an admission failure also leaves the invitation pending instead of marking it accepted prematurely.

**Implementation slice:** Replace the direct insert in `respond_to_event_invitation` with a call to `activate_event_registration`. Add integration coverage for acceptance success, duplicate response, capacity exhaustion, expired deadline, finished event, and unavailable event.

**Dependency:** Decide the product behavior for an invitation that is accepted after the event is full or closed. The recommended behavior is rejection with the invitation remaining pending.

### P0-2: Remove direct authenticated deletion of registrations

**Impact:** High
**Confidence:** High
**Effort:** Low
**Blast radius:** Registration lifecycle, ticket/check-in history, cleanup clients

`event_registrations` grants authenticated users `DELETE` access and has a matching row policy in `supabase/migrations/20260829000000_initial_schema.sql`. This bypasses `revoke_event_registration`, which preserves the row, marks it revoked, records `cancelled_at`, and invalidates the registration token.

**Implementation slice:** Add a migration that revokes authenticated `DELETE` and drops the authenticated delete policy. Keep service-role cleanup available for integration tests. Add an authenticated direct-delete denial test and a revoke lifecycle test.

**Dependency:** Confirm no production client intentionally uses direct table deletion.

### P0-3: Make privileged authorization use current database roles

**Impact:** High
**Confidence:** High
**Effort:** Medium
**Blast radius:** Attendee access and invitation administration

Some privileged functions inspect `auth.jwt() -> app_metadata -> roles`, while newer paths use current database roles. A role revoked after session issuance may therefore remain effective for JWT-based attendee or invitation operations.

**Implementation slice:** Route privileged policies and RPC checks through the current-role helper. Restrict direct invitation table grants and add stale-role integration cases for attendee access, recipient listing, and invitation sending.

**Dependency:** Define the intended immediate-effect behavior for role revocation.

### P1-1: Establish one temporal/date authority

**Impact:** Medium/high
**Confidence:** High
**Effort:** Medium
**Blast radius:** Event creation, display, calendar, reminders, completion, SQL

The event UI writes dates as `DD/MM/YYYY`, while `EventReminderPolicy.eventStartTime` only calls `DateTime.tryParse`, so reminders silently fail for events created through the UI. Date parsing is duplicated in `EventSchedule`, `event_date_formatter`, and `CalendarElement`, with different validation behavior. The server completion function also checks only whether the date is before the current date and does not include same-day `endTime`.

**Implementation slice:** Make `EventSchedule.parseEventDate` the shared parser, update reminder/display/calendar callers, cover both legacy and ISO formats, and align server completion with the client policy. Define and test the event timezone.

### P1-2: Fix category serialization round-trips

**Impact:** Medium
**Confidence:** High
**Effort:** Low
**Blast radius:** Event creation and reload

The default category list contains `Music` and `Business`, but `EventCategory.fromJson` does not deserialize either name and falls back to `Other`. The existing model test records this loss as the expected result.

**Implementation slice:** Add stable category identifiers and a single catalog map. Preserve compatibility with existing name-based payloads. Round-trip every default category in tests.

### P1-3: Add request identity to asynchronous state owners

**Impact:** Medium
**Confidence:** High
**Effort:** Medium
**Blast radius:** Event, calendar, watcher, and profile state

`EventScreenCubit.load(force: true)` and `CalendarScreenCubit.loadRegistrations()` can overlap. Late responses can overwrite newer state. Watcher validation/check-in and profile visibility loading also need identity guards when state is reset, logged out, or switched to another user.

**Implementation slice:** Add a request generation or cancellation token to each operation and apply results only when the request and user/event identity still match. Add delayed-fake tests that complete requests out of order.

**Dependency:** Define “latest request wins” behavior per operation.

### P1-4: Make main destinations lazy

**Impact:** Medium
**Confidence:** High
**Effort:** Medium
**Blast radius:** Startup work and tab state preservation

`MainScreenShell` places concrete page instances into an `IndexedStack`, and `main_screen_destinations.dart` constructs all destinations immediately. Hidden pages can initialize Cubits and perform network/native work before the user opens the tab.

**Implementation slice:** Store builders or route factories, instantiate on first activation, and cache only the pages that must preserve state. Add a test that counts repository calls before and after tab activation.

**Dependency:** Decide which tabs preserve state across navigation.

### P1-5: Bound global resource lifetimes (Implemented)

**Impact:** Medium
**Confidence:** High
**Effort:** Low/medium
**Blast radius:** Long-running sessions and keyboard tracking

`EventImage` stores signed URLs in a static map without global expiry eviction, size bounds, or LRU behavior. `AppKeyboardTracker.initialize()` adds a global observer on every call, while calendar elements can initialize it repeatedly and no clear application owner disposes it.

**Implementation slice:** Add bounded expiry eviction and make observer registration idempotent with one root-owned disposal point. Add lifecycle tests.

### P1-6: Keep the migration manifest authoritative (Implemented)

**Impact:** Medium
**Confidence:** High
**Effort:** Low
**Blast radius:** Integration environment confidence

`supabase/migrations/20260831000000_enforce_event_completion.sql` exists, but `MigrationManifest` still ends at `20260830010000_profile_image_storage.sql`, and its test expects the older version. The manifest can therefore pass while omitting a required migration.

**Implementation slice:** Update the manifest and latest-version assertion, then test for missing, duplicate, and unexpected migration files. Decide whether the manifest is a complete whitelist or only a minimum list.

### P2-1: Add explicit nullable-clearing semantics and remove orphaned registration layers (Implemented)

`User.copyWith` and `Event.copyWith` interpret null as “keep the old value,” so callers cannot clear nullable fields through the public API. Separately, `EventRegistration` and two `RegisteredEventDto` classes have no meaningful production usage in the traced code.

**Implementation slice:** Add explicit clear flags or a sentinel API, cover it with model tests, then remove unused types only after usage tracing confirms they are not package APIs.

### P2-2: Remove personal data from production logs (Implemented)

`AuthRepository` logs user ID, email, role claims, requested role, mapped roles, and display name. This is useful during local diagnosis but unnecessarily exposes identity data in device or collected logs.

**Implementation slice:** Keep operational outcome and non-sensitive correlation data; remove email, display name, and requested-role values from production logging.

## Implementation Progress

The first implementation pass has been started one slice at a time after this audit was written:

- Invitation acceptance now uses the authoritative registration admission function.
- Authenticated direct registration deletion is revoked; registration lifecycle remains RPC-driven.
- Invitation administration and attendance RPCs use current database roles, and direct invitation table mutations are blocked.
- Event completion now includes same-day `endTime`, and registration admission enforces event availability.
- Reminder, formatter, and calendar consumers share `EventSchedule` date parsing.
- Music and Business categories survive JSON round-trips.
- Event and calendar Cubits reject stale asynchronous responses.
- Main-screen destinations are lazily built and cached after first activation.
- Profile visibility persistence rolls back optimistic state when saving fails.
- Event-image cache size and keyboard-observer lifetime are bounded and covered by focused tests.
- Auth and frontend-permission logs no longer emit identity or raw role metadata.
- Event, User, and Location nullable `copyWith` fields can be explicitly cleared.
- Unused registration model/DTO layers and their orphan-only tests were removed.

Each completed slice has focused tests or regression coverage. The configured Flutter executable remains unavailable locally because Windows denies process startup, so test execution must be completed in the project CI or a working Flutter environment.

## Rejected or Deferred Findings

- Broad `on Object` catches were not automatically classified as defects. Several are deliberate nonfatal adapter boundaries, such as watcher dashboard counters.
- Auth request password logging is sanitized by key-name checks and was not promoted to a finding.
- Duplicate repositories and DTOs were not removed during this audit without stronger usage-tracing evidence and an API-compatibility decision.
- Lifecycle-status filtering was not recommended because lifecycle columns exist without active client lifecycle semantics.
- Static scroll/controller disposal and post-frame notification callbacks need a more specific leak or race reproduction before promotion.
- The commented watcher destination is a deferred product/navigation decision, not a confirmed defect.

## Remaining Work

1. Run the focused and full Flutter test suites in a working Flutter environment.
2. Apply the six new Supabase migrations and run the integration security/admission journeys.
3. Define the canonical event timezone and verify date/end-time behavior around timezone boundaries.
4. Decide whether stable category IDs are required beyond the repaired name-based compatibility.

## Validation Limits

- The repository has a broad unit/widget/integration test structure and CI workflows, but integration journeys are documented as implemented and unverified.
- Local Flutter/Dart execution is blocked by Windows access-denied process failures.
- Supabase and `psql` executables were not available locally, so SQL behavior must be verified in the configured integration environment or CI.
