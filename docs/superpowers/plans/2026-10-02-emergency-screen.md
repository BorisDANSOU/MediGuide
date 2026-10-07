# Emergency Screen Implementation Plan

> **For agentic workers:** Execute this plan inline, one task at a time, with tests before implementation. Do not commit changes.

**Goal:** Replace the emergency placeholder with the approved local-demo screen and make Urgences a first-class navigation destination.

**Architecture:** The page consumes `EmergencyProvider`, which loads country-filtered numbers through the existing `EmergencyRepository`. The UI uses local demo fixtures for hospitals and pharmacies and keeps every call/directions action non-operative with an explicit demo message. The existing shell gains an Urgences branch at index 2; the other branch indices move accordingly.

**Tech Stack:** Flutter, Dart, `ChangeNotifier`, `go_router`, existing emergency repository and `flutter_test`.

## Global Constraints

- Reuse `AppColors` and `AppTheme`.
- Display « Données de démonstration » and mark Côte d’Ivoire numbers and service availability as not verified.
- Keep Togo values `112`, `117`, and `118` separate from Côte d’Ivoire demo numbers.
- Do not launch phone, GPS, maps, or network actions; show « Démonstration : aucune action réelle effectuée. » instead.
- Keep Urgences in the shared bottom navigation and make it branch index 2.
- Preserve existing user changes and do not commit.

## Files

- Modify `lib/features/emergency/presentation/controllers/emergency_provider.dart` to inject `EmergencyRepository` and expose loading/error state.
- Modify `lib/features/emergency/data/datasources/emergency_local_ds.dart` to add explicitly demo-only Côte d’Ivoire fixture rows while retaining existing Togo rows.
- Modify `lib/features/emergency/presentation/pages/emergency_modal_page.dart` to render the scrollable emergency demo page and show safe feedback for unavailable actions.
- Modify `lib/config/routes/app_routes.dart`, `lib/features/navigation/presentation/pages/main_shell_page.dart`, and `lib/features/navigation/presentation/widgets/app_bottom_bar.dart` to route/select the new branch and update tab indices. `EmergencyFab` is not used by the current shell and remains untouched.
- Add provider and page tests under `test/features/emergency/`.

### Task 1: Load emergency numbers from the repository

**Interfaces:** `EmergencyProvider(EmergencyRepository repository)`, `loadForCountry(String country)`, `numbers`, `isLoading`, and `errorMessage`.

- [x] Add tests proving `loadForCountry` returns the fake repository’s country-filtered values, clears loading on completion, and exposes a generic error without exception details.
- [x] Run `flutter test test/features/emergency/presentation/controllers/emergency_provider_test.dart`; confirm it fails because the provider initially has no repository.
- [x] Implement the constructor and asynchronous loading state; remove the provider’s inline `112`/`117` list.
- [x] Add fixture rows for `Côte d’Ivoire` in `EmergencyLocalDataSource` using the values shown in the approved mockup, while retaining the existing Togo rows. The UI banner identifies the page’s numbers as unverified demo data.
- [x] Re-run the focused provider test; all cases pass.

### Task 2: Implement the emergency demo page

**Interface:** `const EmergencyModalPage({Key? key, EmergencyRepository? repository})`; when omitted, use `EmergencyRepositoryImpl(const EmergencyLocalDataSource())`.

- [x] Add widget tests for the demo badge, Côte d’Ivoire context, national services, CHU/PISAM demo entries, pharmacies, and emergency advice.
- [x] Add a widget test that taps an « Appeler » action and finds « Démonstration : aucune action réelle effectuée. » without invoking an external intent.
- [x] Run `flutter test test/features/emergency/presentation/pages/emergency_modal_page_test.dart`; confirm it fails against the placeholder.
- [x] Render the approved sections in order: header/location, demo notice, emergency numbers, demo location, national services, demo hospitals, demo pharmacies, and call advice. Use theme colors and icon tiles because no hospital photo assets are part of this feature.
- [x] Keep loading, error, and empty states visible; use an explicit local Snackbar for call/composer/itinerary buttons.
- [x] Re-run the focused page tests; all cases pass.

### Task 3: Make Urgences a shell branch

- [x] Add a widget test for the bottom bar labels at indices 0–4 and the selected Urgences state at index 2.
- [x] Move the emergency route into `StatefulShellRoute` as branch 2, then place Maternité at 3 and Profil at 4.
- [x] Change the central emergency FAB to select branch 2 instead of pushing the modal route; emergency links navigate to the branch destination.
- [x] Re-run the emergency page/navigation tests; all cases pass.

### Task 4: Validate the emergency slice

- [x] Run targeted `flutter analyze` on emergency/navigation files; no diagnostics.
- [x] Run all focused emergency/navigation/maternity tests; all pass.
- [x] Perform Flutter hot reload on the DTD-connected app; succeeded.
- [x] Confirm the diff contains no edits to unrelated generated files or pre-existing user changes.

Note: a full `flutter analyze` / `flutter test` run currently fails on the separate `test/core/services/notification_service_test.dart`, whose expected notification-service API is not implemented yet. The emergency/navigation slice is clean.