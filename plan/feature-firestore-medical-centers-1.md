---
goal: Connect MediGuide health-center screens to Cloud Firestore
version: 1.0
date_created: 2026-10-05
last_updated: 2026-10-05
owner: MediGuide
status: 'Completed'
tags: [feature, firestore, flutter]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Replace the active demo health-center repository with a Firestore-backed
implementation for project `mediguide-1d550`. Keep the existing domain
interfaces and screens, and make authentication-required and retry states
explicit rather than presenting failed reads as empty results.

## 1. Requirements & Constraints

- **REQ-001**: Read center documents from the existing `medical_centers`
  collection using the configured Firebase project `mediguide-1d550`.
- **REQ-002**: Scope home, map, and search queries by the selected supported
  location's `countryCode` and `city`.
- **REQ-003**: Parse Firestore documents using `MedicalCenter.fromMap` and use
  each Firestore document ID as the center ID.
- **REQ-004**: Preserve existing home, search, map-marker, filtering, sorting,
  and detail-page behavior for successfully loaded records.
- **REQ-005**: Preserve Firestore persistence for offline reads and never
  substitute demo records when a Firestore read fails.
- **SEC-001**: Do not weaken Firestore rules or enable anonymous/public reads.
- **SEC-002**: A `permission-denied` read must show a sign-in-required state
  with navigation to the existing authentication screen.
- **CON-001**: Do not change Firebase project configuration, Firestore schema,
  rules, indexes, or seeding/write behavior.
- **CON-002**: Do not add a package dependency.
- **GUD-001**: Firestore access stays behind the existing data/repository
  boundary; widgets consume domain entities, not Firestore snapshots.
- **GUD-002**: Keep backend failures distinguishable from an empty successful
  query and provide retry actions for recoverable read failures.
- **PAT-001**: Follow the existing Riverpod provider, repository, controller,
  and `StateMessage` patterns.
- **PAT-002**: Preserve current demo-driven widget tests by overriding the
  health-center repository provider in the shared test helper.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Implement the Firestore data path and activate it through the shared
  health-center repository provider.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Add a domain-level health-center access failure in `lib/features/health_centers/domain/failures/health_center_access_failure.dart`. Give it an explicit permission-denied representation so presentation controllers can distinguish required sign-in from other failures without importing Firebase APIs. | ✅ | 2026-10-05 |
| TASK-002 | Depends on TASK-001. Replace the stub in `lib/features/health_centers/data/datasources/health_center_remote_ds.dart` with an injectable Cloud Firestore data source for `medical_centers`. Add a location query accepting ISO `countryCode` and `city`, map each document with `MedicalCenter.fromMap(doc.id, doc.data())`, and expose an all-record read for the existing radius-based repository method. Propagate Firestore errors without converting them to empty results. | ✅ | 2026-10-05 |
| TASK-003 | Depends on TASK-002. Update `lib/features/health_centers/data/repositories/health_center_repo_impl.dart` to use the remote data source for `searchHealthCenters`, map `MedicalCenter` values into `HealthCenterEntity`, and retain the optional type filter. Convert Firebase `permission-denied` to the TASK-001 domain failure; rethrow other errors. Preserve `getNearbyHealthCenters` by filtering fetched records using the existing latitude/longitude radius semantics. | ✅ | 2026-10-05 |
| TASK-004 | Depends on TASK-003. Update `lib/features/health_centers/presentation/controllers/health_centers_providers.dart` to construct `HealthCenterRepositoryImpl` with the Firestore data source instead of `DemoHealthCenterRepository`. Make `healthCentersByCountryProvider` query the supported city for its country using `SupportedLocations.forCountry(country)`. | ✅ | 2026-10-05 |

### Implementation Phase 2

- GOAL-002: Surface access failures, retryable errors, and location-scoped map
  results consistently in the user interface.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Depends on TASK-001. Update `lib/features/home/presentation/controllers/home_controller.dart` and `lib/features/health_centers/presentation/controllers/search_controller.dart` to retain a distinct sign-in-required state when the repository throws the domain access failure; keep other exceptions in the existing retryable error state. | ✅ | 2026-10-05 |
| TASK-006 | Depends on TASK-005. Update `lib/features/home/presentation/pages/home_page.dart` and `lib/features/health_centers/presentation/pages/search_page.dart` to render a clear sign-in-required message and navigate to `AppRoutes.auth` for that state. Keep their current retry actions for other loading failures and their existing successful empty states. | ✅ | 2026-10-05 |
| TASK-007 | Depends on TASK-004 and TASK-001. Update `lib/features/health_centers/presentation/pages/map_page.dart` to show the selected country's supported city in its provider query and render an error overlay with sign-in navigation or provider invalidation/retry when the provider fails. Keep the map visible and do not treat `centersAsync.value ?? []` as the only result state. | ✅ | 2026-10-05 |

### Implementation Phase 3

- GOAL-003: Add focused regression coverage and validate the complete Firestore
  read flow without requiring a live Firebase project in unit tests.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Depends on TASK-002 and TASK-003. Add unit tests for `MedicalCenter.fromMap` and the repository adapter, covering document ID, all center fields, nullable values, type filtering, location parameters, permission-denied conversion, propagation of other Firebase errors, and the existing radius behavior using a fake remote data source. | ✅ | 2026-10-05 |
| TASK-009 | Depends on TASK-005, TASK-006, and TASK-007. Update `test/helpers.dart` to override `healthCenterRepositoryProvider` with `DemoHealthCenterRepository` for existing widget tests. Add controller/widget tests for permission-denied sign-in messaging, navigation to `AppRoutes.auth`, retryable non-auth failures, and a successful empty response. | ✅ | 2026-10-05 |
| TASK-010 | Depends on TASK-008 and TASK-009. Run focused Flutter tests for the new data/controller/UI tests and existing `test/home_page_test.dart` and `test/search_and_detail_test.dart`; run `flutter analyze`. Resolve failures introduced by this feature without changing unrelated baseline issues. | ✅ | 2026-10-05 |

## 3. Alternatives

- **ALT-001**: Keep the demo repository and replace only the remote stub. Rejected
  because the active provider would continue to return demo data and the search
  path currently uses an empty local data source.
- **ALT-002**: Query Firestore directly from map/home/search widgets. Rejected
  because it bypasses the existing repository/domain boundary and duplicates
  loading, conversion, and failure handling.

## 4. Dependencies

- **DEP-001**: Existing `cloud_firestore`, `firebase_core`, `firebase_auth`,
  and `flutter_riverpod` dependencies in `pubspec.yaml`.
- **DEP-002**: Existing Firebase project options for `mediguide-1d550`.
- **DEP-003**: Existing `firestore.rules`, which permit center reads only to
  signed-in users.
- **DEP-004**: Existing `SupportedLocations` entries, which map each supported
  country display name to its ISO country code and city.

## 5. Files

- **FILE-001**: `lib/features/health_centers/domain/failures/health_center_access_failure.dart` — new typed access failure.
- **FILE-002**: `lib/features/health_centers/data/datasources/health_center_remote_ds.dart` — Firestore query and document parsing.
- **FILE-003**: `lib/features/health_centers/data/repositories/health_center_repo_impl.dart` — domain conversion and repository behavior.
- **FILE-004**: `lib/features/health_centers/presentation/controllers/health_centers_providers.dart` — active provider wiring and supported-city query.
- **FILE-005**: `lib/features/home/presentation/controllers/home_controller.dart` — distinct sign-in-required state.
- **FILE-006**: `lib/features/home/presentation/pages/home_page.dart` — sign-in and retry UI.
- **FILE-007**: `lib/features/health_centers/presentation/controllers/search_controller.dart` — distinct sign-in-required state.
- **FILE-008**: `lib/features/health_centers/presentation/pages/search_page.dart` — sign-in and retry UI.
- **FILE-009**: `lib/features/health_centers/presentation/pages/map_page.dart` — map-scoped query and error overlay.
- **FILE-010**: `test/helpers.dart` — preserve demo fixtures for existing widget tests.
- **FILE-011**: `test/features/health_centers/data/models/medical_center_test.dart` — new model parsing tests.
- **FILE-012**: `test/features/health_centers/data/repositories/health_center_repo_impl_test.dart` — new repository tests with a fake data source.
- **FILE-013**: `test/features/health_centers/presentation/controllers/health_centers_error_test.dart` — new controller and error-state tests.
- **FILE-014**: `test/home_page_test.dart` and `test/search_and_detail_test.dart` — regression and sign-in navigation coverage.

## 6. Testing

- **TEST-001**: Verify `MedicalCenter.fromMap` preserves Firestore document ID, parses numeric coordinates, and retains nullable phone/address/opening-hours values.
- **TEST-002**: Verify `HealthCenterRepositoryImpl.searchHealthCenters` passes the requested country code and city to its data source and applies the existing optional type filter.
- **TEST-003**: Verify `getNearbyHealthCenters` returns only centers inside the requested radius and propagates read failures.
- **TEST-004**: Verify home and search controllers classify the typed permission-denied failure separately from generic failures.
- **TEST-005**: Verify home, search, and map expose a sign-in action for permission-denied and a retry action for recoverable failures.
- **TEST-006**: Verify a successful query returning no documents remains an empty state, not an error.
- **TEST-007**: Run `flutter test test/features/health_centers/data/models/medical_center_test.dart test/features/health_centers/data/repositories/health_center_repo_impl_test.dart test/features/health_centers/presentation/controllers/health_centers_error_test.dart test/home_page_test.dart test/search_and_detail_test.dart`.
- **TEST-008**: Run `flutter analyze`.

## 7. Risks & Assumptions

- **RISK-001**: `getNearbyHealthCenters` has coordinates but no country/city. Without geospatial fields, retaining its current contract requires reading records and filtering distances client-side; this is not used by the selected home/map/search flows and may become costly if the collection grows substantially.
- **RISK-002**: A document missing numeric `latitude` or `longitude` cannot be converted by the current `MedicalCenter.fromMap`; the read must surface this malformed data rather than silently omit the record.
- **ASSUMPTION-001**: `mediguide-1d550` is the Firebase project containing the intended MediGuide Firestore database; the user confirmed this.
- **ASSUMPTION-002**: The deployed documents in `medical_centers` use the fields defined by `MedicalCenter` and have valid numeric coordinates.
- **ASSUMPTION-003**: Current supported-location data contains one primary city per country, as defined in `lib/core/constants/supported_locations.dart`.
- **ASSUMPTION-004**: Firestore offline persistence remains configured before the first Firestore read.

## 8. Related Specifications / Further Reading

- [Approved Firestore integration design](../docs/superpowers/specs/2026-10-05-firestore-medical-centers-design.md)
- [FlutterFire Cloud Firestore documentation](https://firebase.google.com/docs/flutter/setup)
- [Cloud Firestore offline persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
