---
goal: Prevent profile header overflow on narrow layouts
version: 1.0
date_created: 2026-10-07
last_updated: 2026-10-07
owner: MediGuide
status: Completed
tags: [bug, profile, responsive]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Make `ProfileHeaderCard` responsive to very narrow available widths so account identity and location no longer cause a horizontal `RenderFlex` overflow.

## 1. Requirements & Constraints

- **REQ-001**: Keep the existing horizontal avatar/content layout when the card has sufficient width.
- **REQ-002**: Use a vertical compact layout when the available card width cannot fit the avatar, spacing, and a usable identity column.
- **REQ-003**: Keep account name and email to one line with ellipsis.
- **REQ-004**: Allow the profile city/country to wrap instead of requiring a one-line width.
- **REQ-005**: Add a widget test using a narrow viewport and increased text scale; verify that layout produces no Flutter exception and the city/country remains rendered.
- **CON-001**: Do not modify profile/authentication data, Firestore, navigation, or local persistence.
- **CON-002**: Limit implementation changes to `ProfileHeaderCard` and the existing Profile widget test.
- **PAT-001**: Follow the existing Flutter widget and responsive test conventions in `test/helpers.dart`.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Adapt the profile header layout to its available width.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Update `lib/features/user_profile/presentation/widgets/profile_header_card.dart` to use `LayoutBuilder` with a named compact-layout threshold based on the 64 px avatar, 16 px gap, card padding, and a minimum useful content width. Preserve the current horizontal layout above the threshold. Below it, stack the avatar above a full-width identity column. Keep identity text ellipsized and render city/country in a wrapping or vertical icon/text arrangement so the location does not depend on a minimum horizontal width. | ✅ | 2026-10-07 |

### Implementation Phase 2

- GOAL-002: Reproduce the reported narrow layout and verify the fix.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-002 | Extend `test/features/user_profile/presentation/profile_page_test.dart` with a test that calls `setScreen` using a narrow phone viewport and text scale 1.5, pumps the authenticated Profile page with long name/email and city/country values, calls `expectNoOverflowWhileScrolling`, and asserts the full location text remains discoverable. | ✅ | 2026-10-07 |
| TASK-003 | Run `flutter test test/features/user_profile/presentation/profile_page_test.dart` and `flutter analyze lib`; fix only regressions introduced by TASK-001 or TASK-002. | ✅ | 2026-10-07 |

## 3. Alternatives

- **ALT-001**: Further truncate the location text. Rejected because the user selected an adaptive layout that keeps the full location available.
- **ALT-002**: Always stack the avatar and identity. Rejected because the current horizontal design should remain on screens with adequate width.

## 4. Dependencies

- **DEP-001**: Flutter `LayoutBuilder` and existing Material layout widgets.
- **DEP-002**: Existing test helpers `setScreen` and `expectNoOverflowWhileScrolling` in `test/helpers.dart`.
- **DEP-003**: Existing profile/auth test connectivity channel setup in `test/features/user_profile/presentation/profile_page_test.dart`.

## 5. Files

- **FILE-001**: `lib/features/user_profile/presentation/widgets/profile_header_card.dart` — choose a horizontal or compact layout based on constraints and allow location wrapping.
- **FILE-002**: `test/features/user_profile/presentation/profile_page_test.dart` — reproduce the constrained layout and assert no overflow.

## 6. Testing

- **TEST-001**: Authenticated header with a narrow viewport and large text scale produces no Flutter layout exception.
- **TEST-002**: Long city/country remains present in the widget tree in compact mode.
- **TEST-003**: Existing profile behavior tests continue passing.
- **TEST-004**: `flutter analyze lib` reports no new diagnostics attributable to the responsive header.

## 7. Risks & Assumptions

- **RISK-001**: A width threshold that is too high could stack the header unnecessarily; derive it from fixed avatar/gap/padding sizes plus a minimum content width and test both narrow and standard widths if needed.
- **ASSUMPTION-001**: The reported 6.5 px content constraint is an extreme narrow-layout case; the compact layout must not assume enough width for the location icon and text to remain in a single `Row`.

Validation result: all 7 focused profile widget tests pass, including the 240 px viewport at 1.5 text scale. `flutter analyze lib` reports only the pre-existing `avoid_print` info in `lib/core/services/notification_service.dart:251`.

## 8. Related Specifications / Further Reading

- [Profile header overflow design](../docs/superpowers/specs/2026-10-07-profile-header-overflow-design.md)
- `lib/features/user_profile/presentation/widgets/profile_header_card.dart`
- `test/helpers.dart`
