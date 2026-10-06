# MediGuide Firestore Medical Centers Design

Date: 2026-10-05

## Goal

Read the existing `medical_centers` collection in the configured Firebase
project `mediguide-1d550` and use its records in MediGuide's map, home, search,
and detail flows instead of the demo center repository.

## Existing context

- Firebase Core and Cloud Firestore are already dependencies.
- `main()` initializes Firebase with the generated platform options and enables
  Firestore persistence.
- The configured Firebase project is `mediguide-1d550`.
- `MedicalCenter` describes the Firestore document fields; the Firestore
  document ID is the center ID.
- The active health-center provider currently returns
  `DemoHealthCenterRepository`. The remote data source is a stub, and the local
  data source returns an empty list.
- Firestore rules require authentication to read `medical_centers`. The app
  also permits continuing without an account.

## Chosen approach

Replace the demo repository behind the existing Riverpod provider with the
Firestore-backed implementation of the existing `HealthCenterRepository`
contract. Continue to use the domain entities and use cases so the widgets do
not depend on Firebase APIs.

The Firestore data source reads documents from `medical_centers`, parses each
document with `MedicalCenter.fromMap(document.id, document.data())`, and maps
the result to the existing `HealthCenterEntity`. For the home, map, and search
flows, queries are scoped to the selected supported location using
`countryCode` and `city`. The map uses the city associated with the selected
country, consistent with the current one-city-per-country supported-location
list. Search text and type/guard/24-hour filters remain client-side, preserving
the existing behavior and avoiding unrelated query/index changes.

The existing Firebase initialization and offline persistence remain in place.
No new Firebase project configuration, package, schema field, rule, index, or
write/seeding flow is part of this change. Detail pages continue to receive the
already-loaded domain entity.

## Access and failure behavior

- Firestore rules remain unchanged: only signed-in Firebase users may read
  centers.
- If a guest receives Firestore `permission-denied`, home, map, and search
  clearly indicate that sign-in is required and provide navigation to the
  existing authentication screen.
- Other Firebase/network failures remain distinguishable from an empty
  collection and provide an explicit retry action where the screen supports
  loading centers.
- The map must not silently turn a failed read into an empty marker layer; it
  exposes the failure and retry/sign-in action while retaining the map itself.
- Firestore's configured local persistence may serve cached records offline.
  If neither server data nor cached results are available, the error is shown;
  demo records are not substituted.

## Out of scope

- Changing Firestore security rules or allowing anonymous/public reads.
- Seeding, editing, or deleting center documents.
- Changing the `medical_centers` schema or deploying indexes.
- Reworking authentication or the behavior of unrelated app features.
- Adding geospatial fields or redesigning radius-based search.

## Validation

- Unit-test `MedicalCenter` parsing and conversion to the domain entity,
  including the Firestore document ID and nullable fields.
- Test repository queries for the selected country code and city, plus the
  existing client-side filtering and ordering behavior.
- Test that permission-denied is surfaced as a sign-in-required state, while
  other Firebase errors remain retryable and an empty successful query remains
  an empty state.
- Run the focused Flutter tests and analyze the modified Dart files.