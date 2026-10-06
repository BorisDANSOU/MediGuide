---
goal: Open emergency express from login without duplicate navigator page keys
version: 1.0
date_created: 2026-10-05
last_updated: 2026-10-05
owner: MediGuide
status: 'Completed'
tags: [bug, navigation, flutter, go_router]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Replace the login screen with the existing app shell's emergency branch when
the user taps "Accès urgence express", then verify the route transition.

## 1. Requirements & Constraints

- **REQ-001**: The express button in `AuthPage` must navigate to
  `AppRoutes.emergency` using `context.go`.
- **REQ-002**: The destination must remain the existing emergency branch in
  `createAppRouter`.
- **CON-001**: Do not add navigator keys, duplicate routes, or emergency pages.
- **CON-002**: Do not modify other login, shell, or emergency navigation actions.
- **PAT-001**: Use the existing `createAppRouter` factory and Flutter widget
  tests for route-level validation.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Correct the auth-to-emergency navigation transition.

Completion criteria: pressing the login screen's emergency express action
replaces `/auth` with the shell's emergency branch and does not assert on
duplicate page keys.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | In `lib/features/auth/presentation/pages/auth_page.dart`, change `_EmergencyAccessCard`'s `onTap` callback from `context.push(AppRoutes.emergency)` to `context.go(AppRoutes.emergency)`. Leave `_onSignedIn`, "Continuer sans compte", and all other routes unchanged. | ✅ | 2026-10-05 |
| TASK-002 | Extend the existing `test/auth_page_test.dart` using its `pumpApp` helper and `createAppRouter(initialLocation: AppRoutes.auth)`. Tap the button with text `Accès urgence express`, pump the route transition, and assert that the emergency page's unique heading `Services nationaux prioritaires` is visible and the `/auth` login form is absent. | ✅ | 2026-10-05 |

### Implementation Phase 2

- GOAL-002: Validate the route change against existing behavior.

Completion criteria: the focused new test and existing auth/navigation tests
pass; no new analyzer errors are introduced.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-003 | Run the new auth emergency route test and the existing auth/router test files. | ✅ | 2026-10-05 |
| TASK-004 | Run `flutter analyze` and confirm any reported diagnostics are pre-existing and unrelated to this navigation patch. | ✅ | 2026-10-05 |

## 3. Alternatives

- **ALT-001**: Add a root-level emergency route. Rejected because the destination
  already exists as a branch and duplicate route definitions would add ambiguity.
- **ALT-002**: Add navigator keys or custom page keys. Rejected because the
  conflict is caused by pushing a shell-branch destination from outside its
  shell, not by missing custom keys.

## 4. Dependencies

- **DEP-001**: Existing `go_router` dependency and `createAppRouter` factory.
- **DEP-002**: Existing emergency branch and widget-test setup.

## 5. Files

- **FILE-001**: `lib/features/auth/presentation/pages/auth_page.dart` — change express action from push to go.
- **FILE-002**: `test/auth_page_test.dart` — verify the transition to the shell emergency branch.

## 6. Testing

- **TEST-001**: The emergency express button navigates from `/auth` to the existing shell emergency destination.
- **TEST-002**: The transition completes without a duplicate page-key assertion; the auth form is no longer visible.
- **TEST-003**: Existing auth/router tests pass and `flutter analyze` reports no new diagnostics.

## 7. Risks & Assumptions

- **RISK-001**: `go` intentionally replaces the login location, so back navigation returns to the shell's previous/root branch behavior rather than popping back to `/auth`.
- **ASSUMPTION-001**: Emergency access from login should enter the same persistent app shell as emergency access from other tabs.

## 8. Related Specifications / Further Reading

- [Auth emergency navigation design](../docs/superpowers/specs/2026-10-05-auth-emergency-navigation-design.md)
- [GoRouter navigation](https://pub.dev/documentation/go_router/latest/topics/Navigation-topic.html)
