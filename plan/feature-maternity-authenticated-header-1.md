---
goal: Show the authenticated account name instead of a demo maternity identity
version: 1.0
date_created: 2026-10-06
last_updated: 2026-10-06
owner: MediGuide
status: 'Completed'
tags: [feature, authentication, maternity, flutter]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Remove the fictitious maternity dossier identity and display the real
authenticated user's name only when available, while retaining guest access.

## 1. Requirements & Constraints

- **REQ-001**: Use the active authenticated `AppUser` from
  `authSessionProvider` as the only source of the displayed dossier name.
- **REQ-002**: Display `Dossier suivi : <nom>` only when a user exists and
  `fullName.trim()` is not empty.
- **REQ-003**: Never display the hard-coded demo identity, age, or invented
  record identifier.
- **REQ-004**: Hide the dossier line for guests and authenticated accounts with
  missing/blank names; keep guest maternity pages usable.
- **CON-001**: Do not add Firestore reads, profile fields, age calculation, or
  medical-record ID generation.
- **CON-002**: Preserve all unrelated maternity header actions and content.
- **PAT-001**: Pass display state from `MaternityDashboardPage` to
  `MaternityDashboardHeader` as an optional presentation value; do not have the
  header access authentication providers directly.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Replace the demo identity with the current authenticated account
  name and hide it in guest mode.

Completion criteria:

- Guest dashboard contains no demo identity text and no dossier line.
- Authenticated dashboard displays the supplied session name without age or
  fabricated ID.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Update `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart` to import `authSessionProvider`, watch its `AppUser?` state through the existing `ConsumerStatefulWidget`/Riverpod context pattern, trim `fullName`, and pass `null` when no user or blank name exists. | ✅ | 2026-10-06 |
| TASK-002 | Update `lib/features/maternity/presentation/widgets/maternity_dashboard_widgets.dart`: add an optional `String? dossierName` parameter to `MaternityDashboardHeader`; replace the hard-coded `Dossier suivi : Awa K. (28 ans) · ID #MG-9821` with a conditional `Text('Dossier suivi : $dossierName')`; render no dossier `Text` widget when `dossierName == null`. | ✅ | 2026-10-06 |

### Implementation Phase 2

- GOAL-002: Verify guest and authenticated header states with focused widget
  tests.

Completion criteria:

- Targeted maternity dashboard tests pass for guest, named session, and blank
  session names.
- No hard-coded sample name, age, or ID is rendered.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-003 | Extend `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart` with a guest test asserting absence of `Awa K.`, `28 ans`, and `MG-9821`; add a `ProviderScope` test overriding `authSessionProvider` with an authenticated `AppUser` and assert its actual full name is displayed without age/ID; add a blank-name authenticated case asserting the dossier line is hidden. | ✅ | 2026-10-06 |
| TASK-004 | Run the focused maternity dashboard tests and `flutter analyze`; confirm no new diagnostics are introduced. | ✅ | 2026-10-06 |

## 3. Alternatives

- **ALT-001**: Require authentication to access maternity pages. Rejected
  because guest-local maternity functionality is an explicit existing behavior.
- **ALT-002**: Fetch a separate Firestore maternity profile to populate the
  header. Rejected because no such profile contract exists and the current
  session already supplies the account's full name.
- **ALT-003**: Keep the sample name but remove only the age and ID. Rejected
  because the sample name still falsely identifies a guest or another account.

## 4. Dependencies

- **DEP-001**: Existing `authSessionProvider` and `AppUser.fullName`.
- **DEP-002**: Existing Flutter Riverpod widget test overrides.

## 5. Files

- **FILE-001**: `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart` — read session and pass optional name.
- **FILE-002**: `lib/features/maternity/presentation/widgets/maternity_dashboard_widgets.dart` — conditionally render real dossier name.
- **FILE-003**: `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart` — guest/authenticated/blank-name coverage.

## 6. Testing

- **TEST-001**: Guest mode hides the dossier line and all demo identity tokens.
- **TEST-002**: A named authenticated session displays its own full name.
- **TEST-003**: A blank authenticated name hides the dossier line.
- **TEST-004**: Existing maternity dashboard behavior remains intact and focused Flutter tests pass.
- **TEST-005**: `flutter analyze` reports no new issues.

## 7. Risks & Assumptions

- **RISK-001**: The session name can be missing because Firebase Auth display
  name/profile data is incomplete; the specified safe behavior is to hide the
  dossier line, not display a fallback identity.
- **ASSUMPTION-001**: `AppUser.fullName` is the intended display name for the
  account dossier header; age and medical record number are not currently
  available as verified user-profile fields.

## 8. Related Specifications / Further Reading

- [Approved authenticated maternity header design](../docs/superpowers/specs/2026-10-06-maternity-authenticated-header-design.md)
- [Riverpod provider overrides in tests](https://riverpod.dev/docs/concepts2/overrides)
