# lib Consistency Review

## Scope

Review and incremental cleanup of the Dart code under `lib/`.

Constraint: preserve current appearance and user-visible behavior unless a behavior fix is explicitly approved.

## Ordered Worklist

- [x] 1. Correct `LocalAuthStore` imports and confirm ownership under `core/prefs`.
- [x] 2. Make event and registration services own their complete read/write boundaries.
- [x] 3. Choose and document one state-management approach.
- [x] 4. Remove duplicated seeded event lists without changing tab contents.
- [x] 5. Standardize Dart file and folder naming.
- [x] 6. Handle persistence failures consistently.
- [x] 7. Harden preference JSON decoding.
- [x] 7a. Review legacy registration migration ownership and versioning.
- [x] 8. Separate or harden platform-specific image handling.
- [x] 9. Align permissions and domain invariants with service boundaries.
- [x] 10. Connect the calendar search control.
- [x] 10a. Review remaining inactive UI controls.
- [x] 10b. Persist notification preferences.
- [x] 11. Add focused tests for authentication, persistence, events, and registrations.
- [x] 12. Split metadata/session storage from domain-data storage.

## Confirmed Findings

- `AuthRepository` orchestrates authentication, users, sessions, events, registrations, and global notifiers.
- Event data is split between hard-coded controller lists, persisted events, and calendar festival data.
- Naming is now consistent across the reviewed paths; broader renames were avoided where they would create unnecessary import churn.
- Dark theme remains local-only state because app-wide theme state is not implemented.
- SQLite is used for users, created events, and registrations on native platforms; web uses a namespaced fallback behind the same adapter.

## Change Log

### Item 1

Completed: corrected imports to `core/prefs/local_auth_store.dart`. No visual or runtime design changes were made.

### Item 2

Completed: routed startup and post-login event and registration loading through their feature services. The facade still exposes the same API and updates the same notifiers.

### Item 3

Completed: standardized on Flutter-native `setState` for screen-local state and `ValueNotifier` for shared repository state. Removed unused GetX controller inheritance, notification calls, imports, and dependency declaration. No visual behavior changed.

### Item 4

Completed first slice: retained one canonical seeded event list and derived the existing `My Events` and `Past` lists from it. Displayed data, ordering, and tab behavior remain unchanged. Consolidating persisted events and calendar festival data remains separate work.

### Item 6

Completed: `LocalAuthStore` now checks every preference write and throws `LocalStorageException` when a write fails. Authentication, event, and registration operations convert those failures into explicit errors without updating in-memory state as though persistence succeeded.

### Item 7

Completed first slice: validated top-level user/event JSON shapes and individual record shapes before deserialization. Malformed persisted values now fall back to empty collections instead of crashing initialization. Legacy registration migration ownership is documented separately under item 7a.

### Item 7a

Completed: legacy registration migration now records an explicit owner user ID before marking the migration complete. Existing migrated data remains compatible, while another user cannot claim an unmigrated legacy registration blob.

### Item 8

Completed: moved image storage and rendering behind conditional platform implementations. Native platforms retain the existing copied-file behavior, while web avoids `dart:io` and uses the picked image path with `Image.network`.

### Item 9

Completed: separated update and delete authorization checks, while keeping `canManage` as a compatibility alias. Registration now enforces event availability and capacity in the service boundary instead of relying only on UI state.

### Item 10

Completed first slice: connected the existing calendar search field to filter registered events by title or location. The original no-registration state and visual structure remain unchanged. Remaining inactive controls are tracked under item 10a.

### Item 10a

Completed: connected profile logout to the existing session-clearing and authentication navigation flow; connected My Event Registrations to the existing calendar and registered-event pages; replaced the remaining profile tile no-ops with explicit informational dialogs; and connected the event-detail overflow control to a copy event-details action. Push notifications and dark theme remain local screen state because app-wide services and theme state are not implemented.

### Item 11

Completed first slice: added service tests covering unavailable, full, duplicate, and cancelled registrations, preservation of event ownership metadata during updates, missing-event update errors, user/event persistence round-trips including notification preference state, repository preference updates, malformed persisted collections, explicit ownership during legacy registration migration, and the local authentication lifecycle. Static diagnostics and `git diff --check` pass. Flutter test execution remains blocked because the installed Flutter executable returns `Access is denied` on this machine.

### Item 10b

Completed: notification preference changes now persist in the local user record and restore when the profile is reopened. Failed persistence restores the previous switch value and shows an error. No visual styling changes were made.

### Item 5

Completed: corrected the reviewed Dart file and folder naming inconsistencies, including the calendar component typo, widget filename, location dropdown, NavItem model, AppColors file, main-shell feature, profile page folder, and calendar page folder. Imports were updated where present. No runtime or visual behavior changed.

### Item 12

Completed: added a platform-safe local database adapter under `lib/core/db`, with model/payload conversion utilities under `lib/core/db/utility`. Native platforms store users, created events, and registrations in SQLite tables; session state and notification preferences remain in `SharedPreferences` under `lib/core/prefs`. Existing preference-backed domain data migrates into the new store on first read and is removed only after a successful database write. Web uses a namespaced `SharedPreferences` fallback because browser SQLite/WASM is not configured. Flutter dependency resolution and runtime tests remain blocked by `Access is denied` from the installed Flutter executable.
