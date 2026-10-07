# MediGuide Emergency Facilities Firestore Sync Design

Date: 2026-10-05

## Goal

Synchronize hospitals and on-duty pharmacies shown on the emergency screen with
the existing Cloud Firestore `medical_centers` collection, while keeping
national emergency numbers local and retaining explicit local facility fallback
for guests and unavailable Firestore data.

## Existing context

- Firebase is already initialized for project `mediguide-1d550`.
- Firestore persistence is configured in `main()`.
- `medical_centers` is the existing facility collection. Its documents contain
  `name`, `type`, `countryCode`, `country`, `city`, `latitude`, `longitude`,
  nullable `phone`, nullable `address`, nullable `openingHours`, `is24h`, and
  `isGuard`; the Firestore document ID is the facility ID.
- The current Firestore rules allow reads from `medical_centers` only for
  authenticated users.
- The emergency screen currently loads emergency numbers, hospitals,
  pharmacies, and an approximate city landmark from `EmergencyLocalDataSource`.
- Emergency numbers are currently local and the user confirmed they should
  remain so.
- Existing `EmergencyHospitalEntity` includes services, and
  `EmergencyPharmacyEntity` includes closing-time text, but `medical_centers`
  does not contain those fields.

## Chosen approach

Reuse `medical_centers` rather than create and maintain duplicate emergency
facility collections. Add a Firestore-backed emergency facility data source
and extend the emergency repository/provider boundary to consume live
snapshots. Keep the existing local source for national emergency numbers,
approximate location, and guest/offline fallback records.

For the profile's `countryCode` and `city`, watch Firestore documents matching
both fields. Convert them using `MedicalCenter.fromMap(document.id, data)`.
Select hospitals where `type == 'hospital'`; select on-duty pharmacies where
`type == 'pharmacy' && isGuard == true`. Compute distances from the existing
approximate user-location anchor using facility coordinates and sort nearest
first. This design does not add GPS acquisition.

Map only facts represented by the Firestore schema. Use document ID, name,
phone, address, coordinates, `is24h`, and `isGuard`. Do not invent hospital
services or pharmacy closing times. Hide/disable phone actions when a phone
number is absent. Display only a supported 24-hour indication when `is24h` is
true, and a guard indication when `isGuard` is true.

## Access, live updates, and fallback

- Keep `firestore.rules` unchanged; authenticated accounts receive live
  Firestore updates while the emergency screen is open.
- Retain the existing local hospital/pharmacy records as an explicit fallback
  for unauthenticated access, permission denial, and unavailable Firestore data.
- If fallback records are shown, the emergency screen clearly identifies them
  as local/offline data; it must not silently present them as live Firestore
  results.
- A successful Firestore snapshot with no matching documents is a genuine
  empty result, not a reason to show demo/local facilities.
- Firestore's existing local cache may provide cached records while offline.
  If Firestore cannot provide a usable snapshot, switch to local fallback and
  mark it as such.
- On country/city changes, cancel the previous listeners before subscribing
  to the new location. Cancel all listeners when the emergency page/provider
  is disposed.
- National emergency numbers and approximate city-location behavior remain
  sourced from the existing local data source.

## User-interface behavior

- Keep existing emergency-number data and call actions.
- Replace static hospital/pharmacy results with the live results when
  Firestore is readable.
- Use the facility name, address, coordinates, and distance from the current
  approximate anchor.
- Do not display Firestore centers without phone numbers as callable; do not
  fabricate phone numbers, offered services, or closing times.
- Show a distinct local/offline indicator when local fallback is active.
- Keep successful empty results distinct from loading, fallback, and error
  states.

## Out of scope

- Syncing national emergency-number documents; they remain local.
- Changing rules to permit unauthenticated reads.
- Creating new Firestore collections or changing `medical_centers` schema.
- Editing or seeding Firestore data.
- Syncing maternity schedules, pregnancy tasks, or user-profile preferences.
- Adding GPS permissions/acquisition or changing the approximate location
  source.

## Validation

- Unit-test document-to-emergency-entity mapping, including missing optional
  phone/address and the existing field constraints.
- Test hospital/pharmacy type and `isGuard` filtering and country/city query
  parameters.
- Test distance calculation and nearest-first ordering.
- Test live snapshot updates, listener cancellation on location change and
  disposal, and proper handling of stream errors.
- Test local fallback for unauthenticated/permission-denied and unavailable
  Firestore cases, including its visible UI indicator.
- Test that a successful empty Firestore snapshot remains empty and does not
  fall back to local facilities.
- Verify emergency numbers still come from the local source and current
  emergency screen tests remain valid.
- Run focused emergency tests and `flutter analyze`.
