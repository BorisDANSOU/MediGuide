---
goal: Synchronize maternity calendars and private pregnancy progress with Firebase
version: 1.0
date_created: 2026-10-05
last_updated: 2026-10-05
owner: MediGuide
status: 'In progress'
tags: [feature, firestore, maternity, flutter]
---

# Introduction

![Status: In progress](https://img.shields.io/badge/status-In%20progress-yellow)

Move shared vaccine/CPN reference schedules and account-specific maternity
progress to Firestore. Keep guests device-local, scope personal documents by
Firebase UID, and synchronize reminder dates without remotely scheduling
device notifications.

## 1. Requirements & Constraints

- **REQ-001**: Read shared vaccine references from
  `maternity_vaccines/{vaccineId}` with `name`, `recommendedMonth`, and optional
  `description`.
- **REQ-002**: Read shared CPN references from
  `maternity_cpn_schedules/{cpnId}` with `name`, `recommendedWeek`, and optional
  `description`.
- **REQ-003**: Store vaccine progress in
  `users/{uid}/vaccine_progress/{vaccineId}` using `completed` and optional
  `reminderAt` Firestore `Timestamp`.
- **REQ-004**: Store CPN progress in
  `users/{uid}/cpn_progress/{cpnId}` using `completed`.
- **REQ-005**: Store pregnancy tasks in
  `users/{uid}/maternity_tasks/{taskId}` with stable ID, title, description,
  category, priority, `dueDate`, `isCompleted`, and optional `completedDate`.
- **REQ-006**: Initialize signed-in user task documents from existing templates
  only if the user collection is confirmed empty; preserve stable due dates and
  never reset an existing user's task data.
- **REQ-007**: Persist vaccine completion, CPN completion, task completion, and
  reminder dates to the signed-in user's private documents.
- **REQ-008**: Continue local reference/progress behavior for guests using
  `shared_preferences`; do not attempt Firestore access while signed out and do
  not merge guest data into an account on sign-in.
- **REQ-009**: Keep operating-system notification scheduling local to the
  current device. Sync the reminder date only; do not claim a notification was
  installed on another device.
- **REQ-010**: Add an idempotent initial importer for the current vaccine and
  CPN reference values with dry-run default and explicit `--apply` opt-in.
- **SEC-001**: Authenticated clients may read reference calendars but may not
  write them. Admin import credentials must never be stored in source control or
  the Flutter app.
- **SEC-002**: A user may read/write only documents beneath their own UID in
  `vaccine_progress`, `cpn_progress`, and `maternity_tasks`.
- **SEC-003**: Do not add recursive user-subcollection rules that broaden
  access to other or future private collections.
- **CON-001**: Preserve all existing rules for `medical_centers` and
  `users/{uid}` root documents.
- **CON-002**: Do not change medical recommendations, seed personal progress,
  or perform live Firestore writes as part of implementation or tests.
- **CON-003**: Do not add dependencies to the Flutter runtime; use the
  existing `shared_preferences` and Firebase dependencies. The standalone
  importer may have its own isolated Node package manifest for `firebase-admin`.
- **GUD-001**: Keep Firestore behind the maternity and health-task repository
  interfaces.
- **GUD-002**: Report backend errors explicitly; do not convert failed
  reads/writes to empty success or report unsaved changes as saved.
- **PAT-001**: Preserve existing repository injection seams used by maternity
  widget/controller tests.
- **PAT-002**: On account switch/sign-out, discard previous account data and
  cancel account-bound listeners before loading another scope.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Define reference/progress storage, populate only shared reference
  data through a safe admin-only importer, and enforce ownership rules.

Completion criteria:

- Shared vaccine/CPN reference fields and owner-only progress paths match the
  approved specification.
- The importer defaults to dry run, requires explicit `--apply`, uses
  deterministic IDs/merge writes, and never contains credentials.
- Firestore rules preserve existing matches and deny cross-user progress access.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Add `assets/data/maternity_reference.json` containing the current vaccine and CPN definitions from `lib/features/maternity/data/datasources/maternity_local_ds.dart`. Keep reference records limited to stable `id`, `name`, recommended month/week, and description; do not include user completion state. Update `pubspec.yaml` assets only if the existing `assets/data/` directory declaration does not already bundle the file. | ✅ | 2026-10-05 |
| TASK-002 | Update `lib/features/maternity/data/datasources/maternity_local_ds.dart` to load and parse `assets/data/maternity_reference.json` through `rootBundle`, preserving current vaccine and CPN values and returning incomplete guest defaults. Add typed parsing/validation so missing IDs or invalid month/week values throw a visible data-format error rather than return partial empty schedules. | ✅ | 2026-10-05 |
| TASK-003 | Add isolated `tools/maternity_seed/package.json` and `tools/maternity_seed/import.mjs` using `firebase-admin`. Read `assets/data/maternity_reference.json` relative to the repository root, target project `mediguide-1d550`, initialize Admin SDK through Application Default Credentials, print intended IDs/counts in dry-run mode by default, require `--apply` for merge-safe writes to `maternity_vaccines` and `maternity_cpn_schedules`, and exit non-zero for missing credentials, malformed JSON, or write failure. Do not execute `--apply`. | ✅ | 2026-10-05 |
| TASK-004 | Update `firestore.rules` without modifying existing `medical_centers` or `users/{uid}` behavior. Add authenticated read and denied client writes for `maternity_vaccines` and `maternity_cpn_schedules`. Add separate exact match rules for `users/{uid}/vaccine_progress/{documentId}`, `users/{uid}/cpn_progress/{documentId}`, and `users/{uid}/maternity_tasks/{documentId}`; allow read/write only when signed in and `request.auth.uid == uid`. | ✅ | 2026-10-05 |

### Implementation Phase 2

- GOAL-002: Implement signed-in reference reads, private progress writes, and
  persistent local guest state through existing repository contracts.

Completion criteria:

- Signed-in users read reference schedules and per-user progress separately.
- Updating completion or reminder state writes only the corresponding UID's
  private document.
- Guest operations use local storage only, and account data does not bleed
  between users.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Depends on TASK-001 and TASK-002. Add `lib/features/maternity/data/datasources/maternity_firestore_data_source.dart` with injectable `FirebaseFirestore` and typed methods to read `maternity_vaccines`/`maternity_cpn_schedules`, read the three progress subcollections for a supplied UID, and merge a single user's progress document. Serialize dates with Firestore `Timestamp`; derive progress document IDs from the reference/task IDs. Propagate Firebase errors. | ✅ | 2026-10-05 |
| TASK-006 | Depends on TASK-005 and TASK-007. Add `lib/features/maternity/data/repositories/maternity_firestore_repo_impl.dart` implementing `MaternityRepository`. Combine shared reference records with matching user progress; default missing progress to incomplete/no reminder; implement vaccine and CPN completion/reminder writes to `users/{uid}` subcollections only. Do not write to shared reference collections. | ✅ | 2026-10-05 |
| TASK-007 | Depends on TASK-001. Extend `lib/features/maternity/domain/entities/vaccine_entity.dart` with nullable `reminderAt` while preserving existing callers, and ensure `status` represents the current user's completion state rather than a shared reference field. Update `lib/features/maternity/data/models/vaccine_model.dart` parsing to handle reference-only and merged progress fields. Keep `CpnEntity.completed` user-scoped when returned by the repository. | ✅ | 2026-10-05 |
| TASK-008 | Depends on TASK-006. Update `lib/features/maternity/domain/repositories/maternity_repository.dart` and `lib/features/maternity/presentation/controllers/maternity_provider.dart` with completion and reminder persistence methods. On vaccine completion or reminder selection, await the repository write before reporting success; update in-memory schedules only after a successful write. Keep OS notification calls local and propagate errors into the existing visible controller error state. | ✅ | 2026-10-05 |
| TASK-009 | Depends on TASK-001. Add `lib/features/maternity/data/datasources/maternity_guest_local_data_source.dart` backed by the existing `SharedPreferences` instance. Persist guest vaccine/CPN completion, reminder dates, and pregnancy task completion by stable ID. Select local versus Firestore repositories based on the current authenticated `AppUser` UID; never initialize or call Firebase in guest mode. | ✅ | 2026-10-05 |

### Implementation Phase 3

- GOAL-003: Synchronize per-user pregnancy tasks safely and preserve task
  filtering/completion behavior.

Completion criteria:

- A new account's task list is initialized at most once using stable IDs and
  stable due dates.
- Existing task documents and completion state survive reloads and concurrent
  initial loads without reset.
- Guest task progress is local and never copied into account data.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-010 | Depends on TASK-005. Add `lib/features/maternity/data/datasources/health_tasks_firestore_data_source.dart` with UID-scoped methods for reading `users/{uid}/maternity_tasks` and completing one task. Convert category/priority enum names and due/completion dates to/from Firestore fields with validation. A completion write must set `isCompleted: true` and a server/device completion timestamp while retaining title, due date, category, and priority. | ✅ | 2026-10-05 |
| TASK-011 | Depends on TASK-010 and TASK-012. Add `lib/features/maternity/data/repositories/health_tasks_firestore_repo_impl.dart` implementing `HealthTasksRepository`. Preserve category, urgent, and overdue filters. Initialize defaults only when the server-backed collection query confirms it is empty; create deterministic task documents with stable IDs and one-time due dates using a transaction/read-before-write strategy that does not overwrite concurrently created or already completed records. | ✅ | 2026-10-05 |
| TASK-012 | Depends on TASK-009. Update `lib/features/maternity/data/datasources/health_tasks_local_ds.dart` and `lib/features/maternity/data/repositories/health_tasks_repo_impl.dart` to load deterministic guest task templates and persist guest completion through `MaternityGuestLocalDataSource`. Keep due dates stable for a guest installation instead of recomputing relative dates after every reload. | ✅ | 2026-10-05 |
| TASK-013 | Depends on TASK-009 and TASK-011. Update `lib/features/maternity/presentation/controllers/health_tasks_provider.dart` and `lib/features/maternity/presentation/pages/health_tasks_page.dart` to inject the correct UID-scoped repository, clear/reload state when auth UID changes, show a local/device-only label for guests, and surface retryable errors without claiming a failed completion succeeded. | ✅ | 2026-10-05 |

### Implementation Phase 4

- GOAL-004: Wire calendar pages to the authenticated account, maintain guest
  mode, and validate rules, imports, repositories, and user-visible behavior.

Completion criteria:

- Dashboard/calendar pages reflect the active auth UID and clear stale prior
  account state on sign-out/account switch.
- Guest pages remain usable with device-local progress and no Firestore calls.
- Focused tests pass and analysis reports no new diagnostics in modified files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-014 | Depends on TASK-008, TASK-009, and TASK-013. Update `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart` and `lib/features/maternity/presentation/pages/vaccine_schedule_page.dart` to resolve active user state from `FirebaseAuth.currentUser` and `FirebaseAuth.authStateChanges()`, instantiate local repositories for guests and UID-scoped Firestore repositories for signed-in users, and reload schedules on account change. Replace the vaccine page's static “données locales” caption with an accurate source label. | ✅ | 2026-10-05 |
| TASK-015 | Depends on TASK-014. Update `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart`, `lib/features/maternity/presentation/pages/vaccine_schedule_page.dart`, and relevant `lib/features/maternity/presentation/widgets/` to expose CPN/vaccine completion state and reminder date from per-user progress, provide an explicit guest-local label, and preserve notification scheduling on the current device. | ✅ | 2026-10-05 |
| TASK-016 | Depends on TASK-005 through TASK-012. Add focused unit tests for reference JSON parsing, Firestore mapping, missing progress defaults, UID path selection, completion/reminder merge writes, and guest local persistence under `test/features/maternity/data/`. Use fake data sources; no Firebase credentials or live network. | ✅ | 2026-10-05 |
| TASK-017 | Depends on TASK-013 through TASK-015. Extend `test/features/maternity/presentation/controllers/maternity_provider_test.dart`, `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart`, and `test/features/maternity/presentation/pages/vaccine_schedule_page_test.dart` for successful writes, failed-write messaging, guest mode, user switching, private progress display, and reminder date sync. Add `test/features/maternity/data/repositories/health_tasks_firestore_repo_impl_test.dart`, `test/features/maternity/data/repositories/health_tasks_repo_impl_test.dart`, `test/features/maternity/presentation/controllers/health_tasks_provider_test.dart`, and `test/features/maternity/presentation/pages/health_tasks_page_test.dart` for repository filtering/delegation, stable guest due dates, completion persistence, guest storage, and cross-account state clearing. | ✅ | 2026-10-05 |
| TASK-018 | Depends on TASK-004. Add an isolated Node test package at `tools/firestore_rules_tests/package.json` and `tools/firestore_rules_tests/maternity_rules.test.mjs` using `@firebase/rules-unit-testing` and the Firebase Emulator. Verify signed-in reference reads, client reference-write denial, owner progress read/write, unauthenticated denial, and cross-UID denial. Tests are added but execution remains blocked because the installed Java runtime is below the Firebase Emulator requirement of Java 21; do not replace them with tests that only inspect rule source text. | | |
| TASK-019 | Depends on TASK-003, TASK-016, TASK-017, and TASK-018. Add importer tests at `tools/maternity_seed/import.test.mjs` for dry-run default, explicit `--apply` gating, deterministic IDs, malformed input, and merge-safe intended writes. Run focused maternity tests, `npm test` in each isolated tools package, and `flutter analyze`; do not invoke the importer's remote apply mode. | ✅ | 2026-10-05 |

## 3. Alternatives

- **ALT-001**: Store references, progress, and tasks together in one
  `users/{uid}` document. Rejected because the document grows as arrays change,
  is harder to update concurrently, and conflates global reference data with
  private medical records.
- **ALT-002**: Duplicate all vaccine/CPN reference records into each user
  document. Rejected because it duplicates public reference data and complicates
  correction/versioning.
- **ALT-003**: Upload guest progress automatically at sign-in. Rejected because
  it can mix device-local or shared-device medical progress into the wrong
  account.

## 4. Dependencies

- **DEP-001**: Existing `cloud_firestore`, `firebase_core`, `firebase_auth`,
  `shared_preferences`, and notification dependencies.
- **DEP-002**: Existing authenticated user session in
  `lib/features/auth/presentation/controllers/auth_providers.dart`.
- **DEP-003**: Firebase project `mediguide-1d550`.
- **DEP-004**: Firebase Emulator Suite and `@firebase/rules-unit-testing` in
  `tools/firestore_rules_tests/` for executable Firestore rule tests.
- **DEP-005**: Firebase Admin SDK in the isolated importer package and operator
  Application Default Credentials for explicit seed application.

## 5. Files

- **FILE-001**: `assets/data/maternity_reference.json` — canonical shared vaccine and CPN reference seed.
- **FILE-002**: `lib/features/maternity/data/datasources/maternity_local_ds.dart` — load guest/reference definitions from the canonical asset.
- **FILE-003**: `tools/maternity_seed/package.json` and `tools/maternity_seed/import.mjs` — isolated dry-run-first Admin SDK importer.
- **FILE-004**: `firestore.rules` — exact shared-reference read and owner-scoped progress rules.
- **FILE-005**: `lib/features/maternity/data/datasources/maternity_firestore_data_source.dart` — reference/progress reads and private progress writes.
- **FILE-006**: `lib/features/maternity/data/repositories/maternity_firestore_repo_impl.dart` — authenticated schedule/progress composition.
- **FILE-007**: `lib/features/maternity/domain/entities/vaccine_entity.dart`, `lib/features/maternity/domain/entities/cpn_entity.dart`, and `lib/features/maternity/data/models/vaccine_model.dart` — personal completion/reminder field mapping.
- **FILE-008**: `lib/features/maternity/domain/repositories/maternity_repository.dart` and `lib/features/maternity/presentation/controllers/maternity_provider.dart` — progress/reminder write contract.
- **FILE-009**: `lib/features/maternity/data/datasources/maternity_guest_local_data_source.dart` — persistent local guest progress.
- **FILE-010**: `lib/features/maternity/data/datasources/health_tasks_firestore_data_source.dart` and `lib/features/maternity/data/repositories/health_tasks_firestore_repo_impl.dart` — private task read/write and one-time initialization.
- **FILE-011**: `lib/features/maternity/data/datasources/health_tasks_local_ds.dart` and `lib/features/maternity/data/repositories/health_tasks_repo_impl.dart` — stable guest templates and local completion persistence.
- **FILE-012**: `lib/features/maternity/presentation/controllers/health_tasks_provider.dart` and `lib/features/maternity/presentation/pages/health_tasks_page.dart` — UID switching, source label, and completion error state.
- **FILE-013**: `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart` and `lib/features/maternity/presentation/pages/vaccine_schedule_page.dart` — authenticated/guest repository wiring and schedule UI.
- **FILE-014**: `test/features/maternity/data/` — parser, repository, guest persistence, and task initialization tests.
- **FILE-015**: `test/features/maternity/presentation/controllers/maternity_provider_test.dart`, `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart`, and `test/features/maternity/presentation/pages/vaccine_schedule_page_test.dart` — calendar and account-state widget/controller tests.
- **FILE-016**: `tools/firestore_rules_tests/package.json` and `tools/firestore_rules_tests/maternity_rules.test.mjs` — emulator-backed ownership and shared-reference rule tests.
- **FILE-017**: `tools/maternity_seed/import.test.mjs` — isolated importer behavior tests.

## 6. Testing

- **TEST-001**: Parse the canonical reference JSON and assert all current vaccine IDs/months and CPN IDs/weeks are preserved with no completion fields.
- **TEST-002**: Verify signed-in reads combine reference definitions with that UID's progress; missing progress is incomplete with no reminder.
- **TEST-003**: Verify vaccine/CPN completion and reminder writes target only `users/{uid}` subcollections and never mutate shared definitions.
- **TEST-004**: Verify `reminderAt`, `dueDate`, and `completedDate` round-trip through Firestore timestamps and local guest ISO-8601 storage.
- **TEST-005**: Verify task initialization creates the baseline only for a confirmed empty collection, uses stable dates/IDs, and is idempotent for repeated/concurrent calls. This Firestore transaction behavior still needs emulator-backed execution; the current environment does not provide the required Java 21 runtime.
- **TEST-006**: Verify an existing task set is never reseeded or reset and failed reads/writes remain visible errors.
- **TEST-007**: Verify guest mode reads/writes local storage only, persists completion across repository recreation, and is not merged when the user signs in.
- **TEST-008**: Verify account switching and sign-out clear previous account state and prevent stale data from rendering.
- **TEST-009**: Run `npm test` in `tools/firestore_rules_tests/` against Firestore Emulator and verify owner access while denying unauthenticated/cross-user writes and shared reference writes.
- **TEST-010**: Run `npm test` in `tools/maternity_seed/` and verify dry-run makes no Admin writes, `--apply` is required for writes, deterministic reference IDs are used, and errors exit non-zero.
- **TEST-011**: Run focused maternity tests and `flutter analyze`; run importer and emulator tests independently where configured.

## 7. Risks & Assumptions

- **RISK-001**: Pregnancy tasks and completion states are sensitive health data;
  any overly broad Firestore rule or incorrect UID selection could expose one
  user's records to another.
- **RISK-002**: A failed initial task query must not be mistaken for an empty
  collection; otherwise retry could overwrite or duplicate a user's task plan.
- **RISK-003**: A reminder date synced from another device is not an OS
  notification on this device; the UI must not imply otherwise.
- **RISK-004**: Shared calendar updates may alter reference recommendations;
  client rules therefore deny reference writes and only the trusted importer
  may update definitions.
- **RISK-005**: Firestore Emulator or Firebase Admin credentials may not be
  configured locally. Unit tests must remain runnable without live credentials,
  and no live import should run during implementation.
- **ASSUMPTION-001**: Existing local vaccine and CPN entries are the approved
  initial reference data to import.
- **ASSUMPTION-002**: Stable existing IDs (`bcg`, `polio0`, `penta1`, `cpn1`,
  and corresponding current IDs) become deterministic Firestore document IDs.
- **ASSUMPTION-003**: The current task template set is the intended initial
  per-account checklist; tasks are copied once and then belong to the user.
- **ASSUMPTION-004**: Guests use the same current template set and store their
  completion/reminder state only on the local device.

## 8. Related Specifications / Further Reading

- [Approved maternity Firestore synchronization design](../docs/superpowers/specs/2026-10-05-maternity-firestore-sync-design.md)
- [Cloud Firestore data model](https://firebase.google.com/docs/firestore/data-model)
- [Cloud Firestore security rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Firestore offline persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firebase Admin SDK setup](https://firebase.google.com/docs/admin/setup)
