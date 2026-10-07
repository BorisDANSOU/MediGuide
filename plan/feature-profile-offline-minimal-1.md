---
goal: Implement the minimal profile and offline-status screen
version: 1.0
date_created: 2026-10-07
last_updated: 2026-10-07
owner: MediGuide
status: Completed
tags: [feature, profile, offline]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Implement only the profile capabilities already supported by MediGuide: account identity or guest mode, the existing local search location, real connectivity status, and Firebase sign-out. Do not add mock medical, cache, locale, reminder, or emergency-contact data.

## 1. Requirements & Constraints

- **REQ-001**: Show the current account name and email from `authSessionProvider`; show an explicit guest state when the provider value is `null`.
- **REQ-002**: Preserve the existing country/city profile data and `CountryPickerSheet` behavior backed by `SharedPreferences`.
- **REQ-003**: Show the existing connectivity-backed offline message using `OfflineBanner` or an equivalent presentation backed by `connectivity_plus`. Do not claim Internet reachability or cache size.
- **REQ-004**: Show sign-out only for an authenticated user. Require confirmation, call `AuthSession.signOut()`, and navigate to `AppRoutes.auth` only after success.
- **REQ-005**: Display sign-out errors explicitly; do not navigate or show a success state after a failed sign-out.
- **CON-001**: Exclude CMU/medical file, ICE contact, cache-size gauge, region downloads, language, energy, reminder controls, and support-contact actions because these are not implemented profile capabilities.
- **CON-002**: Preserve unrelated worktree changes and modify only the files listed in Section 5.
- **PAT-001**: Follow existing Flutter, Riverpod, GoRouter, and widget-test patterns in the repository.
- **PAT-002**: Use the existing app theme and profile components rather than introducing a new design system.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Render the minimal profile state from existing providers and implement the real sign-out flow.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Update `lib/features/user_profile/presentation/widgets/profile_header_card.dart` to accept the current `AppUser?` in addition to the existing `UserProfileEntity`; render the account's full name and email when signed in, and a clear visitor label when null. Keep the existing country/city location display and avatar styling. | ✅ | 2026-10-07 |
| TASK-002 | Update `lib/features/user_profile/presentation/pages/profile_page.dart` to watch `authSessionProvider`, show the existing `OfflineBanner` with the profile content, preserve `CountryPickerSheet`, and conditionally show a sign-out button for authenticated users. On tap, display a confirmation dialog; on confirmation call `ref.read(authSessionProvider.notifier).signOut()`, then use `context.go(AppRoutes.auth)` only on success. Catch sign-out failures at the UI boundary and show a `SnackBar` with the error; leave the user on the profile page. Depends on TASK-001. | ✅ | 2026-10-07 |

### Implementation Phase 2

- GOAL-002: Verify the guest, signed-in, location, connectivity, and sign-out behaviors.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-003 | Add `test/features/user_profile/presentation/profile_page_test.dart`. Use the existing `pumpApp`/provider override conventions and fake auth repository to test signed-in identity, guest state with no sign-out button, canceling sign-out, successful sign-out navigation, failed sign-out error feedback, and country/city display. Simulate `connectivity_plus` offline state through its platform channel/test interface and assert the offline message is visible. Depends on TASK-002. | ✅ | 2026-10-07 |
| TASK-004 | Run the focused profile widget tests and `flutter analyze lib`; fix only issues introduced by this implementation. Record any unrelated pre-existing analyzer findings separately. Depends on TASK-003. | ✅ | 2026-10-07 |

## 3. Alternatives

- **ALT-001**: Reproduce the entire reference mockup, including medical and cache cards. Rejected because the corresponding data and controls are not currently available and would appear falsely authoritative.
- **ALT-002**: Add new profile persistence and settings providers for all mockup controls. Rejected because it expands the scope beyond essential working features.
- **ALT-003**: Implement a new connectivity abstraction for the profile. Rejected unless the existing `OfflineBanner` cannot be tested; reuse the established widget and plugin first.

## 4. Dependencies

- **DEP-001**: `authSessionProvider` and `AuthSession.signOut()` from `lib/features/auth/presentation/controllers/auth_providers.dart`.
- **DEP-002**: `AppRoutes.auth` and `context.go` from the existing GoRouter setup.
- **DEP-003**: `userProfileControllerProvider`, `CountryPickerSheet`, and the existing SharedPreferences-backed profile.
- **DEP-004**: `OfflineBanner` and the existing `connectivity_plus` dependency.
- **DEP-005**: Existing `FakeAuthRepository`, `pumpApp`, and Flutter widget-test dependencies.

## 5. Files

- **FILE-001**: `lib/features/user_profile/presentation/pages/profile_page.dart` — compose profile, offline status, and confirmed sign-out.
- **FILE-002**: `lib/features/user_profile/presentation/widgets/profile_header_card.dart` — show account identity/guest state alongside location.
- **FILE-003**: `test/features/user_profile/presentation/profile_page_test.dart` — cover the minimal profile behaviors.

## 6. Testing

- **TEST-001**: Authenticated profile renders full name/email and a sign-out action.
- **TEST-002**: Guest profile renders visitor state and has no sign-out action.
- **TEST-003**: Canceling the sign-out confirmation does not call sign-out.
- **TEST-004**: Successful sign-out navigates to `AppRoutes.auth`.
- **TEST-005**: Failed sign-out displays the error and does not navigate.
- **TEST-006**: Existing search country/city values remain visible.
- **TEST-007**: Offline connectivity displays the offline notice.
- **TEST-008**: `flutter analyze lib` completes without new diagnostics attributable to these changes.

Validation result: all 6 focused profile widget tests pass. `flutter analyze lib` reports only the existing `avoid_print` info in `lib/core/services/notification_service.dart:251`; no diagnostics were reported in the profile implementation or its new test.

## 7. Risks & Assumptions

- **RISK-001**: `OfflineBanner` uses the `connectivity_plus` platform channel directly; the widget test must configure and reset the plugin mock channel to avoid cross-test state.
- **RISK-002**: Firebase sign-out errors may contain implementation details; display a user-safe message while retaining error visibility in the project-standard manner.
- **ASSUMPTION-001**: A `null` value from `authSessionProvider` represents the visitor/no-account state.
- **ASSUMPTION-002**: The current local country/city selector remains the authoritative profile location for this screen; syncing location to Firestore is not part of this plan.

## 8. Related Specifications / Further Reading

- [Minimal profile and offline design](../docs/superpowers/specs/2026-10-07-profile-offline-minimal-design.md)
- `lib/features/user_profile/presentation/pages/profile_page.dart`
- `lib/core/widgets/offline_banner.dart`
- `lib/features/auth/presentation/controllers/auth_providers.dart`
