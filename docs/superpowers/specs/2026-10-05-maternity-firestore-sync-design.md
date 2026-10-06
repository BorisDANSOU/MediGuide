# MediGuide Maternity Firestore Synchronization Design

Date: 2026-10-05

## Goal

Synchronize MediGuide's maternity reference calendars and personal pregnancy
tracking with the configured Firebase project, while keeping guest data local
and restricting personal medical progress to its authenticated owner.

## Existing context

- Firebase is initialized for project `mediguide-1d550`; Firestore persistence is
  configured before application reads.
- Firestore currently has a `users/{uid}` rule for that user's root profile
  document, but no explicit rules for subcollections.
- `MaternityLocalDataSource` contains static vaccine and CPN calendars.
  Vaccine `status` and CPN `completed` currently default to `false`.
- `HealthTasksLocalDataSource` constructs pregnancy tasks with due dates offset
  from the current time. `HealthTasksRepoImpl.completeTask` returns a changed
  entity but the local data source does not persist that completion.
- Vaccine reminders are currently scheduled as device-local notifications.
- The app supports continuing without a signed-in account.
- The user requested synchronization for vaccine and CPN calendars, personal
  tasks and completion state, and vaccine reminder dates.

## Chosen architecture

Use shared, read-only reference collections and owner-scoped private progress
subcollections:

- `maternity_vaccines/{vaccineId}` stores reference fields: `name`,
  `recommendedMonth`, and optional `description`.
- `maternity_cpn_schedules/{cpnId}` stores reference fields: `name`,
  `recommendedWeek`, and optional `description`.
- `users/{uid}/vaccine_progress/{vaccineId}` stores per-user `completed` and
  optional `reminderAt` values.
- `users/{uid}/cpn_progress/{cpnId}` stores per-user `completed` values.
- `users/{uid}/maternity_tasks/{taskId}` stores the account's instantiated
  tasks: title, description, category, priority, due date, completion state,
  and optional completion date.

Use the existing repository interfaces as the UI boundary. Add Firestore-backed
data sources/repositories for signed-in users, but leave notification
scheduling itself local to each device. Saving a reminder updates the local
notification and the account's `reminderAt`, so another signed-in device can
display the selected date; a remote reminder date does not promise that a
notification has been registered on every device.

On the first successful signed-in task load, create the user's task documents
from the current task templates only if the user task collection is confirmed
empty. Use stable template IDs and a transaction or deterministic create-if-
absent writes so repeated launches/devices do not duplicate or reset tasks.
Persist due dates at that first initialization; do not regenerate them on later
loads.

For vaccine/CPN reference schedules, read Firestore as the source for signed-in
users and combine each reference item with the matching per-user progress
document. A missing progress document means `completed == false` and no
reminder. Marking an item complete or setting a reminder writes only the user's
progress document; it never mutates the shared reference item.

Guests do not access Firestore. They continue using local reference records,
and changes made while signed out are not uploaded or merged after sign-in.
This keeps guest activity explicitly device-local. Store guest task completion
and vaccine/CPN completion locally using the existing `shared_preferences`
dependency, keyed by stable task/schedule IDs and retained across app restarts
on that device. Guest state must never be written to or copied into a signed-in
user's private records.

## Security rules

- Allow signed-in users to read `maternity_vaccines` and
  `maternity_cpn_schedules`.
- Deny all client writes to those shared reference collections. A trusted
  administrative import process may populate them using Firebase Admin SDK,
  which bypasses client security rules.
- For each of `vaccine_progress`, `cpn_progress`, and `maternity_tasks` under
  `users/{uid}`, allow read and write only when `request.auth != null` and
  `request.auth.uid == uid`.
- Do not add a broad recursive subcollection rule that grants access to
  unrelated user subcollections.
- Keep existing `users/{uid}` profile rules and `medical_centers` rules
  unchanged.

## Initial reference-data import

Add an administrative, one-time seed/import path based on the currently
reviewed local vaccine and CPN reference values. The importer must use the
explicit Firebase project ID, deterministic document IDs, idempotent merge
writes, and a dry-run default. Require an explicit apply flag before any remote
write. Credentials must come from the operator's Firebase Admin/ADC
environment; never store service-account credentials in the repository or
Flutter application. Do not execute the remote apply operation as part of
implementation or tests.

## Error handling and offline behavior

- Preserve Firestore's configured offline cache for signed-in users.
- Distinguish loading, successful empty reference data, local guest mode,
  permission denial, and retryable backend/network errors.
- Do not convert failed Firestore reads/writes into success-shaped empty
  progress or silently report a completion/reminder write as saved.
- If a signed-in Firestore operation fails, expose a retryable error. Do not
  automatically fall back to or upload guest/local progress, because that
  could overwrite account data.
- For guests, explicitly label the maternity data as local/device-only.
- When a signed-in user changes account or signs out, clear any in-memory
  account-specific lists and stop listeners before loading local guest state.

## Out of scope

- Syncing emergency facilities or national emergency numbers.
- Synchronizing the user's name, country, city, or unrelated profile
  preferences.
- Copying guest progress into an account at sign-in.
- Scheduling operating-system notifications remotely; only reminder dates are
  synchronized.
- Changing medical recommendations, vaccine/CPN content, or task medical
  guidance.
- Deploying rules or applying reference data to the live Firebase project as
  part of implementation.

## Validation

- Unit-test mapping of reference vaccines and CPN records and private progress
  documents, including absent progress defaults.
- Test that updating completion/reminder writes only per-user progress and
  never modifies shared reference data.
- Test first-login task initialization, stable persisted due dates, and
  idempotency across repeated and concurrent initialization attempts.
- Test that a non-empty task list is never reseeded or reset.
- Test local guest behavior and verify no Firebase read or write is attempted.
- Test sign-out/account changes clear old account state and cancel active
  Firestore subscriptions.
- Validate Firestore rules with the Firebase Emulator if available, including
  cross-user denial and shared-reference client-write denial.
- Test the seed tool defaults to dry run, requires an explicit apply flag, and
  uses deterministic IDs and merge-safe writes.
- Run focused maternity tests and `flutter analyze`.
