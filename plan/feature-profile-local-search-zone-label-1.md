---
goal: Clarify that the profile search location is stored locally
version: 1.0
date_created: 2026-10-07
last_updated: 2026-10-07
owner: MediGuide
status: Completed
tags: [feature, profile, copy]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Make the profile location card explicitly describe the country and city as a local search preference, preserve existing local selections across future sign-ins, and use the account country only as the initial default when the device has no saved location.

## 1. Requirements & Constraints

- **REQ-001**: In `ProfilePage`, change the current location-card title from `Pays et ville` to `Zone de recherche`.
- **REQ-002**: Add visible supporting text that says the selected zone is saved on this device and is independent of the country associated with the account.
- **REQ-003**: Preserve the currently displayed city and country values, `CountryPickerSheet`, `UserProfileController.selectCountry`, and `SharedPreferences` persistence.
- **REQ-004**: On sign-in or sign-up, initialize the local profile from the account country only if no location has been saved on the device.
- **REQ-005**: Never overwrite a previously saved local search location with a later account country during sign-in or sign-up.
- **CON-001**: Do not read or write Firestore as part of changing the location from Profile.
- **CON-002**: Do not synchronize profile location changes to Firestore.
- **CON-003**: Do not modify unrelated worktree changes.
- **PAT-001**: Follow existing French UI wording, theme, and Flutter widget-test conventions.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Clearly label the existing profile location as local-only.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | In `lib/features/user_profile/presentation/pages/profile_page.dart`, update the `ListTile` for `CountryPickerSheet.show(context)`: set `title` to `Zone de recherche` and provide a subtitle that contains the current `${profile.city}, ${profile.country}` and explicitly states `Enregistrée sur cet appareil, indépendamment du pays du compte.` Preserve its existing tap handler and profile data source. | ✅ | 2026-10-07 |
| TASK-002 | Add `initializeProfileIfAbsent` through `UserRepository`, `UserRepoImpl`, `UserLocalDataSource`, `InitializeProfileLocation`, and `UserProfileController`. In `lib/features/auth/presentation/pages/auth_page.dart`, call the controller initializer from `_onSignedIn` instead of unconditionally calling `selectCountry`; retain an existing profile and seed only an absent one from `AppUser.country`. | ✅ | 2026-10-07 |

### Implementation Phase 2

- GOAL-002: Verify the new wording and unchanged local selection behavior.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-003 | Update `test/helpers.dart`, `test/auth_page_test.dart`, and `test/features/user_profile/presentation/profile_page_test.dart` to verify existing local location survives login to an account with a different country; account country initializes an empty device profile; sign-up initializes an empty device profile; the new local-only label renders; and choosing `Côte d'Ivoire` updates the local profile. | ✅ | 2026-10-07 |
| TASK-004 | Run the focused auth and profile tests plus `flutter analyze lib`; fix only diagnostics caused by this change and record unrelated baseline diagnostics separately. | ✅ | 2026-10-07 |

## 3. Alternatives

- **ALT-001**: Synchronize location changes to Firestore. Rejected because the requested behavior keeps this preference device-local.
- **ALT-002**: Never use the account country to initialize a device with no saved location. Rejected because it would leave first-time users on the unrelated generic default.
- **ALT-003**: Add a separate settings page for location scope. Rejected because a subtitle on the existing card provides the clarification with the smallest UI change.

## 4. Dependencies

- **DEP-001**: `userProfileControllerProvider` and its existing local repository in `lib/features/user_profile/presentation/controllers/user_profile_controller.dart`.
- **DEP-002**: `CountryPickerSheet` in `lib/features/user_profile/presentation/widgets/country_picker_sheet.dart`.
- **DEP-003**: Existing Profile widget test setup in `test/features/user_profile/presentation/profile_page_test.dart`.
- **DEP-004**: Authentication completion callback `_onSignedIn` in `lib/features/auth/presentation/pages/auth_page.dart`.

## 5. Files

- **FILE-001**: `lib/features/user_profile/presentation/pages/profile_page.dart` — update the location card title and subtitle only.
- **FILE-002**: `test/features/user_profile/presentation/profile_page_test.dart` — verify the clarification and preserve the country-selection assertion.
- **FILE-003**: `lib/features/user_profile/domain/repositories/user_repository.dart`, `lib/features/user_profile/data/datasources/user_local_datasource.dart`, and `lib/features/user_profile/data/repositories/user_repo_impl.dart` — support conditional local initialization.
- **FILE-004**: `lib/features/user_profile/domain/usecases/initialize_profile_location.dart` and `lib/features/user_profile/presentation/controllers/user_profile_controller.dart` — initialize the first local search zone.
- **FILE-005**: `lib/features/auth/presentation/pages/auth_page.dart` — seed only a missing local zone during successful authentication.
- **FILE-006**: `test/helpers.dart` and `test/auth_page_test.dart` — cover empty-device and existing-local-location authentication scenarios.

## 6. Testing

- **TEST-001**: Verify the Profile screen renders `Zone de recherche`.
- **TEST-002**: Verify the subtitle explains local-device storage and independence from the account country while displaying the current city and country.
- **TEST-003**: Verify selecting `Côte d'Ivoire` still changes the displayed local city/country to `Abidjan, Côte d'Ivoire`.
- **TEST-004**: Run focused Profile widget tests and `flutter analyze lib`.

Validation result: 21 focused auth and profile tests pass. `flutter analyze lib` reports one unrelated pre-existing `avoid_print` info in `lib/core/services/notification_service.dart:251`; the changed files have no reported diagnostics.

## 7. Risks & Assumptions

- **RISK-001**: Adding a longer subtitle may wrap on narrow screens; the existing `ListTile` layout should be checked at the test viewport used by the project.
- **ASSUMPTION-001**: If no local profile exists, the account country is the right initial search zone; after that, a saved device-local choice takes precedence.

## 8. Related Specifications / Further Reading

- [Local search-zone label design](../docs/superpowers/specs/2026-10-07-profile-local-search-zone-label-design.md)
- `lib/features/user_profile/presentation/pages/profile_page.dart`
- `lib/features/user_profile/data/datasources/user_local_datasource.dart`
