# Maternity Dashboard Implementation Plan

> **For agentic workers:** Execute this plan inline, one task at a time, with tests before implementation. Do not commit changes.

**Goal:** Implement the Maternity dashboard shown in the approved mockup, using the existing app theme and local maternity repository.

**Architecture:** Keep `MaternityDashboardPage` as the route entry point and preserve the existing navigation shell. Connect its presentation controller to `MaternityRepository` for CPN and vaccination data; keep only profile/appointment details absent from current entities as local demo content.

**Tech Stack:** Flutter, Dart, `ChangeNotifier`, existing `MaternityRepository`, `flutter_test`.

## Global Constraints

- Reuse `AppColors` and `AppTheme`; do not add a parallel palette.
- Keep the page functional without Firebase or Firestore.
- Keep the existing bottom navigation and global emergency FAB in `MainShellPage`.
- Use the existing local repository for CPN and vaccine lists.
- Use the three exact mockup photos when source files are provided; expected asset names are `maternity_warning.jpg`, `maternity_bag.jpg`, and `maternity_nutrition.jpg` under `assets/images/`.
- Do not present the local reminder placeholder as a scheduled notification or fabricate a successful external action.

## Files

- Modify `lib/features/maternity/presentation/controllers/maternity_provider.dart` to load CPN and vaccines from an injected repository and expose loading/error/empty state.
- Modify `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart` to compose the scrollable demo dashboard, local tab state, and local-only actions.
- Modify `lib/config/routes/app_routes.dart` to route `/maternity` to `MaternityDashboardPage`.
- Add focused widgets under `lib/features/maternity/presentation/widgets/` for the header, emergency alert, pregnancy/appointment summary, exam rows, advice rows, and listening-line panel.
- Add tests under `test/features/maternity/` for provider data loading and dashboard rendering/tab behavior.

### Task 1: Connect the maternity controller to local data

**Interfaces:** `MaternityProvider(MaternityRepository repository)`, `loadSchedules()`, `vaccines`, `cpnSchedules`, `isLoading`, and `errorMessage`.

- [x] Add a provider test with a fake repository returning one vaccine and one CPN; assert both collections are loaded after `loadSchedules()`.
- [x] Run `flutter test test/features/maternity/presentation/controllers/maternity_provider_test.dart`; confirm it fails because the controller currently has no repository-backed schedule API.
- [x] Update `MaternityProvider` to load both repository schedules, notify listeners around loading, and expose a generic error state without including personal data.
- [x] Re-run the focused provider test and confirm it passes.

### Task 2: Implement the dashboard and route

**Interfaces:** `const MaternityDashboardPage({Key? key, MaternityRepository? repository})`; an optional repository enables widget tests while production defaults to `MaternityRepositoryImpl(const MaternityLocalDataSource())`.

- [x] Add a widget test that pumps the dashboard and checks the mockup’s main headings, CPN 3 card, all three advice titles, and the listening-line section.
- [x] Add a widget test that selects « Mon Bébé (0–24 mois) » and sees repository-backed vaccine content, then returns to « Ma Grossesse (En cours) ».
- [x] Run `flutter test test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart`; confirm the tests fail against the current placeholder.
- [x] Build the dashboard in the existing page, add focused presentation widgets, and switch the route from `PlaceholderPage` to `MaternityDashboardPage`.
- [x] Use `assets/images/maternity_warning.jpg`, `assets/images/maternity_bag.jpg`, and `assets/images/maternity_nutrition.jpg` in fixed-size image slots; verify Flutter bundles the supplied files and do not substitute unrelated photos or icons.
- [x] Re-run the focused dashboard tests and confirm they pass.

### Task 3: Validate the changed slice

- [x] Run `flutter analyze`; expect no new diagnostics.
- [x] Run `flutter test`; expect all widget and provider tests to pass.
- [x] Confirm the diff contains no edits to unrelated generated files or existing user changes.