# `lib` Application Audit and Remediation Tasks

**Scope:** `lib/` only
**Audit date:** 2026-08-28
**Status:** Audit complete; implementation remediation substantially complete; automated test execution remains pending

## Purpose

This document records the complete application check performed within `lib/` and turns the confirmed findings into ordered implementation tasks. It is the working checklist for finishing the dependency-injection, authentication-state, resource-centralization, and data-ownership cleanup.

## Audit Result

- Full `lib` diagnostics: no errors found.
- Changed common and feature files: no errors found.
- `git diff --check`: passed.
- Supabase authentication and table storage are in place.
- GetIt `^9.2.1` is installed and root Cubit provisioning exists.
- Active feature folders use the intended data/domain/presentation organization.
- English user-facing copy is centralized in `lib/core/util/event.resource.dart` for the migrated surfaces.
- Routes were intentionally excluded from resource centralization.
- `dart format` was not available because the local Dart executable was blocked by Windows process permissions.

## Coverage

The audit covered:

- `lib/main.dart`
- `lib/core/common/`
- `lib/core/di/`
- `lib/core/model/`
- `lib/core/prefs/`
- `lib/core/util/`
- `lib/features/auth_screen/`
- `lib/features/calendar_screen/`
- `lib/features/event_detail_screen/`
- `lib/features/event_screen/`
- `lib/features/loading_screen/`
- `lib/features/main_screen/`
- `lib/features/profile_screen/`
- `lib/features/registered_screen/`

Out of scope for this document:

- `test/`
- `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/`
- Supabase SQL/schema changes
- Route centralization
- Localization implementation

## Completed Work

### Backend and storage

- Replaced the previous local/plaintext authentication path with Supabase authentication.
- Replaced SQLite/local table storage with Supabase table storage.
- Added event and registration persistence through `SupabaseStore`.
- Added Supabase configuration guidance to the README.

### Architecture and dependency injection

- Added GetIt composition root at `lib/core/di/app_dependencies.dart`.
- Registered datasources, repositories, use cases, and Cubits.
- Added root `MultiBlocProvider` provisioning in `lib/main.dart`.
- Migrated event, event-detail, registered-event, calendar, signin, and signup paths to injected use cases.
- Moved main/profile logout actions through `AuthScreenCubit`.

### Resource centralization

The following groups are in `lib/core/util/event.resource.dart`:

- `AppText`
- `AppAssets`
- `AppStorageKeys`
- `AppDatabase`
- `AppIdentifiers`
- `AppLocations`

Migrated surfaces include authentication, calendar, event detail, event management, registered tickets, profile, main navigation, loading, shared common widgets, Supabase table names, metadata keys, location seed values, and stored-image identifiers.

### Dead legacy auth flow cleanup

- Usage tracing confirmed the dedicated sign-in and sign-up use-case chains were unused by the active Cubits.
- Removed their DI registrations and dedicated datasource, repository, contract, request, and use-case files.
- Preserved the shared `AuthRemoteDataSource`, `AuthRepository`, and active authentication Cubits.

### Hard-coded UI copy cleanup

- Moved remaining active event, registration, permission, and configuration messages into `AppText`.
- Reused the centralized catalog for category titles, event actions, event-detail feedback, and repository errors.
- The remaining calendar subtitle is dynamic event data, not fixed application copy.

## Confirmed Findings

### Finding 1: Static authentication repository bypasses GetIt (resolved)

**Location:** `lib/features/auth_screen/data/repositories/auth_repository.dart`

`AuthRepository` previously used static state and internally constructed collaborators. It now receives its `SupabaseStore` and `AuthRemoteDataSource` through GetIt as an instance repository. Sign-in, sign-up, session initialization, and logout Cubits use that same instance.

**Impact:** Resolved for the authentication path. Remaining feature-state ownership is tracked by Task 2.

### Finding 2: Authentication and event state are globally mutable (partially resolved)

**Location:** `lib/features/auth_screen/data/repositories/auth_repository.dart`

The authentication repository no longer exposes static current-user state or `ValueNotifier`s. Registration and created-event consumers still require migration to Cubit-owned state or explicit feature repositories.

**Impact:** State ownership is unclear; Cubit lifecycle and test isolation are weaker; stale cross-feature updates are easier to introduce.

### Finding 3: Seed event data is embedded in presentation state (resolved)

**Location:** `lib/features/event_screen/presentation/cubit/event_screen_state.dart`

`EventScreenState` now starts with an empty event list. `EventPage` and `MyEventScreen` explicitly load persisted events through `EventScreenCubit`.

**Impact:** Resolved; presentation state now represents loaded backend data rather than bundled fixture data.

### Finding 4: Event categories are defined in multiple places (resolved)

**Previous locations:**

- `lib/core/model/event_model/event_catagory.dart`
- `lib/features/event_screen/presentation/pages/create_event_page.dart`

**Resolution:** The canonical catalog is now `EventCategory.defaults`; both category selection and event creation consume it.

**Impact:** Resolved; category names, supported values, icons, and colors now have one shared source.

### Finding 5: Supabase projections still contain inline database keys (resolved)

**Location:** `lib/core/prefs/supabase_store.dart`

Supabase projections, filters, event row mappings, and registration DTO mappings now use `AppDatabase` constants, including `id`, `creator_id`, `created_at`, `payload`, `event_id`, `user_id`, `registered_at`, and `is_checked_in`.

**Impact:** Resolved; schema keys have one centralized resource definition.

### Finding 6: Provider authentication messages pass directly to the UI (resolved)

**Location:** `lib/features/auth_screen/data/repositories/auth_repository.dart`

Supabase authentication exceptions are mapped through `mapAuthError` to controlled `AppText` messages for invalid credentials, duplicate registration, and generic failures.

**Impact:** Resolved; provider-specific wording no longer reaches the UI and authentication messages use the centralized catalog.

### Finding 7: Missing Supabase compile-time configuration causes a hard startup exception (resolved)

**Location:** `lib/main.dart`

When `SUPABASE_URL` or `SUPABASE_ANON_KEY` is missing, startup now renders a configuration error screen and returns before Supabase or GetIt initialization.

**Impact:** Resolved; misconfiguration remains fail-fast and is now visible inside the Flutter application with the required command-line configuration.

## Implementation Tasks

## Task 1: Make authentication dependencies injectable

**Current status:** Implementation complete; diagnostics verified. The confirmed-dead dedicated sign-in/sign-up chains were removed. Full unit-test execution remains pending because the local Dart executable is blocked by Windows process permissions.

**Slice type:** AFK
**Slice shape:** enablement for Tasks 2-4

**Description:** Convert the static authentication repository into an injectable instance while preserving the current Supabase behavior and public feature outcomes. Register the repository and its required collaborators through GetIt.

**Acceptance criteria:**

- [x] Authentication repository dependencies are supplied through constructors.
- [x] No authentication production path constructs its own datasource, store, or registration service.
- [x] Existing signin, signup, session-check, and logout behavior remains unchanged.

**Verification:**

- [x] Auth repository and Cubit diagnostics pass.
- [ ] Existing authentication tests pass.
- [ ] Manual check: sign up, sign in, refresh active session, and log out.

**Dependencies:** None

**Files likely touched:**

- `lib/features/auth_screen/data/repositories/auth_repository.dart`
- `lib/features/auth_screen/presentation/cubit/auth_screen_cubit.dart`
- `lib/core/di/app_dependencies.dart`
- `lib/main.dart`

**Estimated scope:** M

## Task 2: Introduce an injected session/auth state boundary

**Current status:** Auth, event-detail registration, event-list, profile, My Events, and logout-state portions complete. `AuthScreenCubit`, `SignInCubit`, `SignUpCubit`, `ProfileScreenCubit`, `CalendarScreenCubit`, and `EventScreenCubit` use injected state/dependencies. Event-detail registration uses `EventDetailState`, event lists use `EventScreenState`, profile/My Events rendering use Cubit state, and logout clears the long-lived feature Cubits before the next session. Profile state is rehydrated after a later successful sign-in.

**Slice type:** AFK
**Slice shape:** vertical

**Description:** Replace direct feature reads of static `AuthRepository.currentUser`, `registrations`, and `createdEvents` with an injected session-facing abstraction or Cubit-owned state boundary. Preserve the existing authenticated, registration, and event-management workflows.

**Acceptance criteria:**

- [x] Calendar, event detail, event management, and profile no longer depend directly on static mutable authentication state.
- [x] Logout clears dependent feature state consistently.
- [ ] Registration and created-event updates remain visible to the relevant screens.

**Verification:**

- [x] Cubit and repository diagnostics pass.
- [ ] Unit tests cover authenticated and unauthenticated transitions.
- [ ] Manual check: register/cancel an event, create/update/delete an event, and log out.

**Dependencies:** Task 1

**Files likely touched:**

- `lib/features/auth_screen/`
- `lib/features/calendar_screen/`
- `lib/features/event_detail_screen/`
- `lib/features/event_screen/`
- `lib/features/profile_screen/`
- `lib/features/registered_screen/`

**Estimated scope:** L

## Task 3: Move event seed data out of UI state

**Current status:** Implementation complete; diagnostics verified. Automated tests remain pending because the local Dart executable is blocked by Windows process permissions.

**Slice type:** AFK
**Slice shape:** vertical

**Description:** Move default event fixtures out of `EventScreenState` into a dedicated datasource or fixture provider, leaving the Cubit state responsible only for runtime UI state.

**Acceptance criteria:**

- [x] `EventScreenState` contains no embedded event fixture list.
- [x] The event loading path has one authoritative source for live data.
- [x] Live Supabase-loaded events continue to render through `EventScreenCubit`.

**Verification:**

- [x] Event screen diagnostics pass.
- [ ] Event loading tests cover empty, seeded/mock, and backend-loaded states.
- [ ] Manual check: upcoming, personal, and past event tabs render correctly.

**Dependencies:** Task 1

**Files likely touched:**

- `lib/features/event_screen/presentation/cubit/event_screen_state.dart`
- `lib/features/event_screen/data/`
- `lib/features/event_screen/domain/`

**Estimated scope:** S

## Task 4: Create one event-category catalog

**Current status:** Implementation complete; diagnostics verified. Automated tests remain pending.

**Slice type:** AFK
**Slice shape:** vertical

**Description:** Establish one authoritative category catalog containing names, parsing aliases, icons, and colors. Reuse it in JSON conversion and the create-event form.

**Acceptance criteria:**

- [x] Category names and visual metadata are defined once.
- [x] JSON parsing and create-event selection use the same catalog.
- [x] Unknown categories retain the existing fallback behavior.

**Verification:**

- [x] Category model and create-page diagnostics pass.
- [ ] Tests cover known categories, aliases, and unknown values.
- [ ] Manual check: select and save each supported category.

**Dependencies:** None

**Files likely touched:**

- `lib/core/model/event_model/event_catagory.dart`
- `lib/features/event_screen/presentation/pages/create_event_page.dart`

**Estimated scope:** S

## Task 5: Finish database resource centralization

**Current status:** Implementation complete; diagnostics and diff validation verified. Supabase store tests remain pending.

**Slice type:** AFK
**Slice shape:** enablement for Task 6

**Description:** Replace remaining Supabase table, column, projection, metadata, and stable identifier literals in `lib` with the appropriate resource constants. Keep routes and secrets out of the resource file.

**Acceptance criteria:**

- [x] Supabase table and column identifiers have one resource owner.
- [x] Select projections and row mapping use the same identifiers as writes and filters.
- [x] No secrets or environment values are moved into the resource catalog.

**Verification:**

- [x] `lib` diagnostics pass.
- [ ] Supabase store tests pass with mocked responses.
- [x] `git diff --check` passes.

**Dependencies:** None

**Files likely touched:**

- `lib/core/prefs/supabase_store.dart`
- `lib/core/util/event.resource.dart`
- `lib/features/**/data/`

**Estimated scope:** S

## Task 6: Normalize authentication error messages

**Current status:** Implementation complete; diagnostics verified. Auth tests remain pending.

**Slice type:** AFK
**Slice shape:** vertical

**Description:** Map Supabase authentication failures to controlled application messages while retaining useful logging/diagnostic detail outside the user-facing message.

**Acceptance criteria:**

- [x] Provider exception text is not displayed directly as application copy.
- [x] Signin and signup failures use centralized messages.
- [x] Unexpected failures remain distinguishable from invalid credentials and account-creation failures.

**Verification:**

- [ ] Auth datasource/repository tests cover provider errors and unexpected exceptions.
- [x] `lib` diagnostics pass.
- [ ] Manual check: invalid credentials, duplicate account, and network failure states.

**Dependencies:** Task 1

**Files likely touched:**

- `lib/features/auth_screen/data/repositories/auth_repository.dart`
- `lib/features/auth_screen/signin_screen/data/`
- `lib/features/auth_screen/signup_screen/data/`
- `lib/core/util/event.resource.dart`

**Estimated scope:** S

## Task 7: Improve missing Supabase configuration handling

**Current status:** Implementation complete; diagnostics verified. Startup tests and manual configuration checks remain pending.

**Slice type:** HITL
**Slice shape:** vertical

**Description:** Decide whether missing compile-time Supabase configuration should remain a developer startup failure or be represented by a user-visible configuration screen. Implement the approved behavior without exposing secrets.

**Acceptance criteria:**

- [x] Missing URL/key behavior is explicitly defined as a rendered configuration screen.
- [x] The app does not attempt Supabase initialization with empty values.
- [x] Failure messaging contains no secret values.

**Verification:**

- [ ] Startup tests cover missing and valid configuration.
- [ ] Manual check with and without both `--dart-define` values.
- [x] `lib` diagnostics pass.

**Dependencies:** None

**Files likely touched:**

- `lib/main.dart`
- `lib/core/util/event.resource.dart`
- `lib/features/loading_screen/`

**Estimated scope:** S

## Checkpoint: After Tasks 1-4

- [x] GetIt is the only production dependency-construction path.
- [x] Auth/session state has a defined owner.
- [x] Event seed data and categories have authoritative owners.
- [ ] Authentication, calendar, event detail, event management, and profile flows still work.
- [ ] Unit tests and `lib` diagnostics pass.

## Checkpoint: After Tasks 5-7

- [x] Database identifiers are centralized.
- [x] User-facing authentication errors are controlled and consistent.
- [ ] Supabase configuration behavior is documented and tested.
- [x] Full `lib` diagnostics pass.
- [x] `git diff --check` passes.
- [ ] Ready for code review.

## Suggested Execution Order

1. Task 1: injectable authentication dependencies
2. Task 2: injected session/auth state boundary
3. Task 3: event seed-data ownership
4. Task 4: shared category catalog
5. Task 5: database resource centralization
6. Task 6: controlled authentication errors
7. Task 7: configuration failure behavior

## Open Decisions

- Should the session boundary be a dedicated `SessionCubit`, an injected session repository, or a combination of both?
- Should seed events remain as development fixtures, or should the application rely exclusively on Supabase data?
- Should missing Supabase configuration remain a hard developer error, or should release builds display a configuration/unavailable screen?
- What logging mechanism should retain provider exception details after user-facing messages are normalized?
