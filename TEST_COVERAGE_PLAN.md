# BDO Events Test Coverage Plan

## Goal

Build deterministic unit, state, widget, integration, and manual coverage for the application. Coverage percentage is a supporting metric; authorization, registration integrity, invitation, check-in, and storage behavior are release gates.

## Execution Order

- [!] 0. Baseline: Flutter execution is blocked by a Windows access-denied error before test output.
- [~] 1. Pure models and utilities: tests added; focused run pending toolchain access.
- [~] 2. Repository and Supabase adapter contracts: registration, event data-source, and event authorization slices added; Flutter execution remains blocked.
- [~] 3. Cubit success, error, duplicate, rollback, stale-result, and closed-state paths: registered-event and event-screen slices added; Flutter execution remains blocked.
- [~] 4. Widget validation and loading/empty/error/success states.
- [ ] 5. Analytics rendering and responsive layout.
- [ ] 6. Local Supabase RPC, RLS, storage, invitation, and concurrency tests.
- [ ] 7. Manual and end-to-end platform flows.
- [ ] 8. Coverage report and CI gates.

## Test Layout

Tests mirror the production ownership tree under `lib`:

- `test/core/` contains shared model and utility tests.
- `test/features/<feature>/` mirrors the feature's `data`, `domain`, and `presentation` layers, including `cubit`, `pages`, and `widgets` folders.
- `test/shared/` contains legacy cross-feature and service tests until they can be split by owner.

## Current Batch

### Batch 1: Pure Models and Utilities

- [ ] Event and category JSON mapping.
- [ ] User roles and permissions.
- [ ] Registration code encode/decode and malformed input handling.
- [ ] Event date and time formatting.
- [ ] Email validation.
- [ ] Notification count boundaries are already covered in `test/core/model/notification_model_test.dart`.

Validation command:

```powershell
flutter test test/core/model/pure_unit_test.dart
```

Status: test file added. `flutter test test/core/model/pure_unit_test.dart` could not start because the Flutter batch wrapper returned a Windows access-denied error before Dart execution.

Known follow-ups exposed by this batch:

- `Event.copyWith` and `User.copyWith` cannot currently clear nullable fields explicitly.
- `Event.toJson` writes a null category as `{}`, while `Event.fromJson` maps that to `Other`.
- Reminder policy date parsing must be aligned with the UI's supported date formats.

## Batch 2: Repository and Adapter Contracts

- [~] Registration authentication, availability, duplicate, capacity, activation, cancellation, and error mapping.
- [ ] Registration deadline boundary after an injectable clock is introduced.
- [~] Event loading counts, creator metadata, update metadata preservation, missing-event handling, and storage-error mapping.
- [ ] Event delete/storage behavior after a storage adapter seam is introduced.
- [~] Event repository admin, owner, unrelated-user authorization, create denial, and load forwarding.
- [ ] Event owner/admin authorization and metadata preservation.
- [ ] Supabase RPC/table mapping, numeric/null conversion, empty-input short circuits, and storage error translation.
- [ ] Invitation, notification, arrival, and token contracts.

## Batch 3: Cubits and State

- [~] Registered-event token loading, null-token clearing, token errors, cancellation success/error, and duplicate cancellation.
- [~] Event loading orchestration, filtering, duplicate-load protection, delete rollback, and saved-event persistence.
- [~] Event save errors, unauthenticated save protection, delete rollback, duplicate loads, and closed-state save behavior.
- [~] Event detail registration, cancellation, duplicate submission protection, owner-only attendance authorization, and stale-result handling.
- [~] Calendar search normalization, clear-state behavior, and signed-out loading.
- [ ] Calendar reminder reconciliation, preference boundaries, and failure resilience after a reminder-service seam is introduced.
- [~] Watcher permission denial, JSON/compact-code validation, malformed input, check-in history, status mapping, auto-open behavior, partial failure, dashboard isolation, reset/clear-state, and closed-state behavior.
- [~] Authentication Cubit success/error transitions, duplicate-request suppression, role forwarding, session restore failure, navigation, logout, and logout-everywhere behavior.
- [~] Profile Cubit preference hydration/persistence, display toggles, volume clamping, reminder boundaries, profile update success/error, password delegation, notification success/rollback, and clear-state behavior.
- [~] Biometric gating for unavailable devices and disabling the lock, plus profile visibility load/save persistence. Reminder reconciliation and authenticated platform-service failure paths remain pending.
- [~] Main navigation loading completion, tab transitions, duplicate-tab no-op, and closed-state guard.

## Batch 4: Widgets

- [~] Authentication forms and validation, including sign-in errors, password visibility, sign-up field validation, and terms gating.
- [~] Event page empty state, populated event cards, and Upcoming/My Events/Past tab filtering.
- [~] Calendar empty prompt, registered-event list rendering, explore-events navigation intent, and no-match search state.
- [~] Registration status rendering: available, unavailable, full, past deadline, and already registered/ticket action.
- [~] Ticket rendering, token loading/error states, QR output, manual registration-code visibility, copy confirmation, and cancellation-dialog dismissal.
- [~] Successful cancellation and ticket-page close after refresh orchestration. Calendar refresh success and reminder cleanup remain pending.
- [ ] Notifications and invitations.
- [~] Event create/edit required-field validation and edit-mode field hydration.
- [~] Event required-field, time-range, capacity and past-deadline validation, edit hydration, and successful save. Image lifecycle, date/time pickers, location search, and deadline picker coverage remain pending.
- [ ] Attendee list, CSV, sharing, and ticket display.
- [ ] Role-based navigation, profile, watcher, and shared components.

## Batch 5: Analytics

- [~] Zero, unlimited-capacity, exact-capacity, over-capacity, and checked-in conversion boundary values.
- [~] Loading placeholder state is covered. Backend-error state remains pending.
- [~] Wide and narrow layouts around the breakpoint, plus custom-paint chart/donut presence.
- [ ] Nonblank chart and donut painter pixel output.
- [~] Repaint behavior when attendance input changes. Pixel-level painter output remains pending.

## Batch 6: Supabase Integration

- [ ] Current-role and event mutation RLS.
- [ ] Attendee, profile, and storage visibility policies.
- [ ] Concurrent registration and duplicate-registration invariants.
- [ ] Token validation and idempotent check-in.
- [ ] Invitations, notifications, reminders, arrival transitions, and profile persistence.

## Batch 7: Manual and E2E

- [ ] Sign-up, authentication, role navigation, and settings.
- [ ] Event create/edit/delete and registration race.
- [ ] Ticket QR/manual code, cancellation, and calendar refresh.
- [ ] Invitation accept/decline.
- [ ] Watcher scan and check-in-all flows.
- [ ] Notifications, camera, biometrics, deep links, sharing, clipboard, images, and responsive layouts.

## Recommended Gates

- P0 authorization, capacity, duplicate-registration, invitation, check-in, and storage invariants must pass.
- Target 90%+ branch coverage for authentication, registration, event, watcher, profile, and invitation logic.
- Target 80%+ branch coverage for utilities and presentation helpers.
- Cover every error, duplicate, rollback, stale-result, and closed-state branch explicitly.
- Treat framework-generated and platform-only code as excluded or manually verified, not as a reason to weaken domain coverage.

## Required Test Seams

- Injectable clock and `SharedPreferences`.
- Injectable Supabase adapter/client boundary.
- Injectable image picker, storage, geocoder, notification, biometric, camera, TTS, haptic, clipboard, and sharing services.
- Resettable `getIt` registrations.
- Deferred-result helper for stale and concurrent async tests.
