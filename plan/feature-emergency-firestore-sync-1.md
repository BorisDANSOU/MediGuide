---
goal: Stream emergency hospitals and on-duty pharmacies from Firestore
version: 1.0
date_created: 2026-10-05
last_updated: 2026-10-05
owner: MediGuide
status: 'Completed'
tags: [feature, firestore, emergency, flutter]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Replace the emergency screen's hospital and on-duty pharmacy lists with live
Firestore updates from the existing `medical_centers` collection. Keep national
emergency numbers and city landmark data local, and clearly identify local
facility fallback when Firestore cannot be read.

## 1. Requirements & Constraints

- **REQ-001**: Subscribe to the existing `medical_centers` collection for the
  selected `countryCode` and profile `city`.
- **REQ-002**: Convert each Firestore document with
  `MedicalCenter.fromMap(document.id, document.data())`.
- **REQ-003**: Display hospitals only when `type == 'hospital'`.
- **REQ-004**: Display pharmacies only when `type == 'pharmacy'` and
  `isGuard == true`.
- **REQ-005**: Recompute distance from the current approximate user-location
  anchor and sort facilities nearest-first.
- **REQ-006**: Keep Firestore snapshot updates visible in the emergency screen
  while it is open.
- **REQ-007**: Keep national emergency numbers and approximate city landmark
  behavior on `EmergencyLocalDataSource`.
- **REQ-008**: Retain local hospital/pharmacy records as fallback for guests,
  `permission-denied`, and Firestore unavailability; show an explicit local or
  offline indicator whenever this fallback is displayed.
- **REQ-009**: A successful Firestore snapshot containing no matching records
  remains empty and does not show local fallback.
- **REQ-010**: Use only facts in the `medical_centers` schema. Do not invent
  emergency service lists or pharmacy closing times.
- **REQ-011**: Disable or hide call actions for records without `phone`.
- **SEC-001**: Preserve current Firestore security rules; do not enable public
  reads or anonymous authentication.
- **CON-001**: Do not create emergency-specific collections, change the
  Firestore schema, deploy rules/indexes, seed or write records, or alter
  national emergency numbers.
- **CON-002**: Do not add package dependencies or GPS acquisition.
- **GUD-001**: Keep Firestore access in the data/repository layer and expose
  domain entities/state to `EmergencyProvider` and widgets.
- **GUD-002**: Cancel live listeners when the selected country/city changes and
  when the provider/page is disposed.
- **PAT-001**: Follow the existing `EmergencyRepository`,
  `EmergencyRepositoryImpl`, `EmergencyProvider`, and injected repository
  patterns used by emergency page tests.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Add typed emergency facility stream and live Firestore mapping
  while preserving local national-number and fallback sources.

Completion criteria:

- The remote data source emits each `medical_centers` snapshot filtered by the
  requested country and city.
- Repository tests prove type/guard filtering, field conversion, distance
  ordering, and distinct empty-live versus local-fallback results.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Add `lib/features/emergency/domain/entities/emergency_facilities_snapshot.dart` with hospital and pharmacy lists plus an explicit source enum distinguishing live Firestore from local fallback. Keep the type immutable and free of Firebase imports. | ✅ | 2026-10-05 |
| TASK-002 | Add `watchCenters({required String countryCode, required String city})` to `lib/features/health_centers/data/datasources/health_center_remote_ds.dart`. Query `medical_centers` with equality filters on `countryCode` and `city`, return a `Stream<List<MedicalCenter>>` from `snapshots()`, and parse each document by document ID with `MedicalCenter.fromMap`. Propagate stream errors without converting a valid empty snapshot into an error. | ✅ | 2026-10-05 |
| TASK-003 | Depends on TASK-001. Extend `lib/features/emergency/domain/repositories/emergency_repository.dart` with a `watchFacilities` stream contract that accepts `countryCode`, `city`, `latitude`, and `longitude` and emits `EmergencyFacilitiesSnapshot`. Make `phone`, hospital `services`, pharmacy `address`, and pharmacy `closeTime` nullable or safely empty in `lib/features/emergency/domain/entities/emergency_hospital_entity.dart` and `lib/features/emergency/domain/entities/emergency_pharmacy_entity.dart` so the Firestore schema can be represented without invented values. Add injectable `HealthCenterRemoteDataSource` and `EmergencyLocalDataSource` dependencies to `lib/features/emergency/data/repositories/emergency_repo_impl.dart`. Map `hospital` records to `EmergencyHospitalEntity`, `pharmacy && isGuard` records to `EmergencyPharmacyEntity`, compute distances using `Distance` from `lat/lng` (round pharmacy meters to an integer), sort nearest-first, and preserve null phone/address data. | ✅ | 2026-10-05 |
| TASK-004 | Depends on TASK-003. In `lib/features/emergency/data/repositories/emergency_repo_impl.dart`, preserve `getEmergencyNumbers` and `getUserLocation` delegation to `EmergencyLocalDataSource`. Inject an `isAuthenticated` callback (defaults to checking `FirebaseAuth.instance.currentUser`); if the user is signed out, emit local facility fallback without opening a Firestore listener. For authenticated users, convert Firestore `permission-denied`, `unavailable`, and `network-request-failed` stream errors into a local-fallback snapshot populated from existing local hospitals and pharmacies for the requested ISO country code. Do not fall back after a successful empty snapshot. Keep local fallback stream alive for a single terminal remote error and expose fallback source state. | ✅ | 2026-10-05 |

### Implementation Phase 2

- GOAL-002: Consume the live stream safely and communicate local fallback
  without disturbing national emergency-number behavior.

Completion criteria:

- The emergency screen updates its displayed facility lists for each live
  snapshot and visibly marks local fallback.
- All stream subscriptions are cancelled on location changes and disposal.
- Existing national-number and call-navigation behavior remains covered by
  passing tests.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Depends on TASK-004. Update `lib/features/emergency/presentation/controllers/emergency_provider.dart` to load the existing local user location and national numbers, then subscribe to `EmergencyRepository.watchFacilities`. Expose the facility source state, apply each snapshot to `hospitals` and `pharmacies`, and cancel the previous `StreamSubscription` before changing country/city and during `dispose`. Keep loading/error handling explicit and prevent late events from a previous location from overwriting current state. | ✅ | 2026-10-05 |
| TASK-006 | Depends on TASK-003 and TASK-005. Update `lib/features/emergency/presentation/pages/emergency_modal_page.dart` to construct the default repository with `EmergencyLocalDataSource` and `HealthCenterRemoteDataSource`. Pass both ISO country code and profile city when loading. Render a visible local/offline data notice when fallback is active, keep successful empty states, map only available fields, and disable/hide call actions for facilities whose phone is absent. Hide blank services, pharmacy address, and close-time rows. Replace fabricated service and close-time text with data-backed type/`is24h`/`isGuard` indications. | ✅ | 2026-10-05 |
| TASK-007 | Depends on TASK-003 and TASK-005. Update test repository fakes in `test/features/emergency/presentation/controllers/emergency_provider_test.dart` and `test/features/emergency/presentation/pages/emergency_modal_page_test.dart` to implement `watchFacilities`; retain existing assertions for local national numbers and page navigation/call actions. | ✅ | 2026-10-05 |

### Implementation Phase 3

- GOAL-003: Verify field mapping, stream lifecycle, fallback behavior, and
  existing emergency-screen behavior without requiring a live Firebase
  project.

Completion criteria:

- All focused emergency tests pass, including fallback, live updates, optional
  fields, and subscription cleanup.
- `flutter analyze` introduces no diagnostics in the modified feature files.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Depends on TASK-002 and TASK-004. Add `test/features/emergency/data/repositories/emergency_firestore_repo_test.dart` with a fake `HealthCenterRemoteDataSource` stream. Verify the requested country/city, hospital and guarded-pharmacy filters, exclusion of clinics/non-guard pharmacies, document-derived IDs, nullable fields, 24-hour/on-duty flags, distance calculation, nearest-first order, valid empty snapshots, and mapped local fallback on permission-denied/unavailable stream errors. | ✅ | 2026-10-05 |
| TASK-009 | Depends on TASK-005 and TASK-007. Extend `test/features/emergency/presentation/controllers/emergency_provider_test.dart` to verify stream emissions update lists, national numbers remain local, changing location cancels the prior subscription, and disposing the provider cancels the active subscription. | ✅ | 2026-10-05 |
| TASK-010 | Depends on TASK-006 and TASK-007. Extend `test/features/emergency/presentation/pages/emergency_modal_page_test.dart` to verify that local fallback is visibly identified, Firestore-backed facility facts render without fabricated service/closing-hour data, and facilities with null phone numbers cannot trigger a call. | ✅ | 2026-10-05 |
| TASK-011 | Depends on TASK-008, TASK-009, and TASK-010. Run `flutter test test/features/emergency/data/repositories/emergency_repo_impl_test.dart test/features/emergency/data/repositories/emergency_firestore_repo_test.dart test/features/emergency/presentation/controllers/emergency_provider_test.dart test/features/emergency/presentation/pages/emergency_modal_page_test.dart` and `flutter analyze`. Resolve feature-introduced failures without changing unrelated baseline issues. | ✅ | 2026-10-05 |

## 3. Alternatives

- **ALT-001**: Create separate emergency hospital and pharmacy collections.
  Rejected because the existing `medical_centers` collection already contains
  the required shared facility identity, location, contact, opening, and guard
  fields; duplicate records would require a second synchronization process.
- **ALT-002**: Replace all static emergency facilities with Firestore-only
  reads. Rejected because emergency facilities should remain available to
  guests and when Firestore/network access is unavailable.
- **ALT-003**: Fetch one snapshot only when the page opens. Rejected because
  the user requested automatic updates while the emergency screen is open,
  especially for pharmacy guard status.

## 4. Dependencies

- **DEP-001**: Existing `cloud_firestore`, `firebase_core`, `firebase_auth`,
  and `latlong2`
  dependencies in `pubspec.yaml`.
- **DEP-002**: Existing Firestore project `mediguide-1d550` and
  `medical_centers` documents confirmed by the user.
- **DEP-003**: Existing `MedicalCenter` model and `HealthCenterRemoteDataSource`
  query/parser in `lib/features/health_centers/data/`.
- **DEP-004**: Existing `EmergencyLocalDataSource` static numbers, local
  hospital/pharmacy fallback, and approximate location behavior.
- **DEP-005**: Existing Firestore rules, which allow `medical_centers` reads
  only to signed-in users.

## 5. Files

- **FILE-001**: `lib/features/emergency/domain/entities/emergency_facilities_snapshot.dart` — new immutable facilities/source snapshot.
- **FILE-002**: `lib/features/health_centers/data/datasources/health_center_remote_ds.dart` — add real-time location-filtered query.
- **FILE-003**: `lib/features/emergency/domain/repositories/emergency_repository.dart` — add typed live facilities stream.
- **FILE-004**: `lib/features/emergency/data/repositories/emergency_repo_impl.dart` — map Firestore data, compute distances, and provide explicit local fallback.
- **FILE-005**: `lib/features/emergency/presentation/controllers/emergency_provider.dart` — own stream subscription lifecycle and expose source state.
- **FILE-006**: `lib/features/emergency/presentation/pages/emergency_modal_page.dart` — wire real repository, fallback notice, truthful field rendering, and optional call actions.
- **FILE-007**: `lib/features/emergency/domain/entities/emergency_hospital_entity.dart` — allow absent phone/services for Firestore records.
- **FILE-008**: `lib/features/emergency/domain/entities/emergency_pharmacy_entity.dart` — allow absent phone/address/closing time for Firestore records.
- **FILE-009**: `test/features/emergency/presentation/controllers/emergency_provider_test.dart` — stream and subscription lifecycle tests.
- **FILE-010**: `test/features/emergency/presentation/pages/emergency_modal_page_test.dart` — fallback/source and rendering regression tests.
- **FILE-011**: `test/features/emergency/data/repositories/emergency_repo_impl_test.dart` — preserve local emergency-number tests and adapt fake dependencies.
- **FILE-012**: `test/features/emergency/data/repositories/emergency_firestore_repo_test.dart` — new Firestore mapping, filtering, distance, and fallback tests.

## 6. Testing

- **TEST-001**: Verify the remote data source applies equality filters for both `countryCode` and `city` and emits each `snapshots()` update using document IDs.
- **TEST-002**: Verify `type == hospital` records are mapped to hospital entities and `type == pharmacy && isGuard == true` records are mapped to pharmacy entities; clinics and non-guard pharmacies are excluded.
- **TEST-003**: Verify distance from the passed approximate location anchor is computed and results sort nearest-first.
- **TEST-004**: Verify phone/address absence does not produce fabricated contact data and phone-less facilities cannot invoke `tel:`.
- **TEST-005**: Verify permission-denied and unavailable errors emit local facility fallback with explicit source state, but an empty successful snapshot emits empty live results.
- **TEST-006**: Verify changing country/city cancels the old subscription and provider disposal cancels the active subscription.
- **TEST-007**: Verify emergency numbers and approximate location still come from `EmergencyLocalDataSource`.
- **TEST-008**: Run the focused command listed in TASK-011 and verify `flutter analyze` reports no new diagnostics attributable to the changed files.

## 7. Risks & Assumptions

- **RISK-001**: The shared `medical_centers` rules require authentication. Guests will receive local fallback rather than live data, by design; rules remain unchanged.
- **RISK-002**: The schema does not identify which hospitals actually operate emergency departments or enumerate their services. The UI must not imply those unrepresented facts.
- **RISK-003**: The schema has no pharmacy closing-time field. The UI must show guard status only, not a fabricated closing time.
- **RISK-004**: Existing static fallback facilities are illustrative/seeded local records and may not match current real-world availability; the UI must label them as local/offline.
- **RISK-005**: Existing document fields `latitude` and `longitude` are required by `MedicalCenter.fromMap`; malformed documents must not silently become valid facilities.
- **ASSUMPTION-001**: The collection uses `type` values `hospital`, `clinic`, and `pharmacy`, and `isGuard` marks currently designated on-duty pharmacies.
- **ASSUMPTION-002**: The profile city exactly matches each document's `city` field, and the profile ISO code exactly matches `countryCode`.
- **ASSUMPTION-003**: The existing approximate location anchor is acceptable for distance ordering until a separate GPS feature is designed.

## 8. Related Specifications / Further Reading

- [Approved emergency Firestore sync design](../docs/superpowers/specs/2026-10-05-emergency-firestore-sync-design.md)
- [Cloud Firestore listen to changes](https://firebase.google.com/docs/firestore/query-data/listen)
- [Cloud Firestore offline persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
