# Maternity Authenticated Header Design

Date: 2026-10-06

## Goal

Ensure the maternity dashboard never presents a demo identity as the signed-in
person's real medical record.

## Existing behavior

`MaternityDashboardHeader` currently displays the hard-coded text
`Dossier suivi : Awa K. (28 ans) · ID #MG-9821`. That text is placeholder
content and is unrelated to Firebase Authentication or the Firestore profile.
The application supports local maternity mode for guests, so authentication
must not become a requirement for accessing the dashboard.

## Chosen design

Read the current `AppUser` from `authSessionProvider` in
`MaternityDashboardPage` and pass an optional display name to
`MaternityDashboardHeader`. When an authenticated user has a non-empty name,
show `Dossier suivi : <nom>` using the real session name. Do not infer age or
generate a medical-record identifier. If no authenticated user exists, or the
name is blank, omit the dossier line entirely. Preserve the guest-local
maternity experience and all other header content.

## Validation

- Add a widget test confirming guest mode does not display `Awa K.`, `28 ans`,
  or `MG-9821`.
- Add a widget test confirming an authenticated session's actual display name
  appears and the hard-coded demo identity does not.
- Keep existing maternity dashboard tests passing.
