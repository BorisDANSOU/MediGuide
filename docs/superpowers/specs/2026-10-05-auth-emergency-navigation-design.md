# Auth Emergency Navigation Design

Date: 2026-10-05

## Goal

Allow a signed-out user to open the emergency destination from the login page
without a duplicate GoRouter page-key assertion.

## Current behavior

The emergency express button in `AuthPage` calls `context.push('/emergency')`.
That route is a branch destination of the `StatefulShellRoute` and is not a
root-level route. Pushing it from `/auth` can place the branch page on an
incompatible navigation stack, resulting in a duplicate navigator page-key
assertion in Flutter web.

## Chosen change

Keep `/emergency` in the existing emergency branch. Change only the login
page's emergency express action to `context.go(AppRoutes.emergency)`. This
replaces the current location with the application shell at its emergency
branch instead of pushing the branch destination over `/auth`.

Do not add a new route, navigator key, page key, or route redirect. Preserve the
main-shell emergency button and all other navigation behavior.

## Validation

- Add a router-level test that starts at `/auth`, activates the express
  emergency action, and confirms the emergency destination is displayed.
- Run that targeted test and the existing route/auth tests.
- Confirm no duplicate-page-key exception occurs during the transition.
