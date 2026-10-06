---
goal: Back maternity examination cards with persisted health-task state
version: 1.0
date_created: 2026-10-06
status: 'Completed'
tags: [feature, maternity, flutter, firestore]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Implement the approved [maternity examination task-cards specification](../docs/superpowers/specs/2026-10-06-maternity-exam-task-cards-design.md). The dashboard will show completion state from the active guest-local or authenticated health-task repository and remove unsupported appointment, laboratory, facility, and document claims.

## 1. Requirements & Constraints

- **REQ-001**: Load dashboard health tasks through `HealthTasksProvider` and the existing `MaternityRepositoryFactory.healthTasks(uid:)`.
- **REQ-002**: Map the ultrasound card to `echo3` and the biological-assessment card to `blood2`.
- **REQ-003**: Map VAT to the first available incomplete task in `vat1`, `vat2` order; when both exist and are complete, show `vat2`; when only one exists, show that task; omit the card when neither exists.
- **REQ-004**: Derive card titles from `HealthTaskEntity.title` and labels from `isCompleted`: `À suivre` or `Déclaré fait`.
- **REQ-005**: Hide cards while tasks are loading; display an explicit task-loading error and retry action on failure; omit a card after successful load if its task is absent.
- **REQ-006**: Route each card's `Voir le suivi` action and the section's `Tout voir` action to the existing `HealthTasksPage`.
- **REQ-007**: Reload task state when the authentication UID changes and keep guest-local and account-scoped task repositories isolated.
- **CON-001**: Do not render generated task due dates, completion dates, gestational-age assertions, laboratory values/results, facility counts, booking actions, or PDF/report actions in the dashboard cards.
- **CON-002**: Do not describe user-declared completion as clinician-confirmed or medically validated.
- **PAT-001**: Follow the dashboard's existing provider lifecycle and repository-injection patterns; add no dependency or new persistence schema.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Load active-session health tasks in the maternity dashboard and render cards solely from persisted task state.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | In `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart`, add optional `HealthTasksRepository` injection alongside the existing maternity repository injection. Create and load a `HealthTasksProvider` in `initState` using the injected repository or `MaternityRepositoryFactory.healthTasks(uid: _activeUid)`; dispose it with the page. Extend `_onAuthChanged` to replace the task repository for the new UID, clearing old-account task state before reload. | ✅ | 2026-10-06 |
| TASK-002 | In `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart`, replace the three hard-coded `MaternityExamCard` instances in `_buildPregnancyContent` with task-driven cards for `echo3`, `blood2`, and the VAT sequence (`vat1`, then `vat2`) exactly as REQ-002 through REQ-004 specify. Hide the cards while tasks load; render the provider error with a retry control on failure; omit missing tasks after successful load. Route card actions and the section's `Tout voir` action to `HealthTasksPage` using the existing navigation pattern. This task depends on TASK-001. | ✅ | 2026-10-06 |
| TASK-003 | In `lib/features/maternity/presentation/widgets/maternity_dashboard_widgets.dart`, adapt `MaternityExamCard` so details and footer content can be omitted instead of populated with unsupported claims. Render the task title, the `À suivre`/`Déclaré fait` state, and the `Voir le suivi` action; derive its completed visual state from `isCompleted`. Do not display task descriptions, due/completion dates, result values, facilities, bookings, or report actions. | ✅ | 2026-10-06 |

### Implementation Phase 2

- GOAL-002: Verify all card mappings, empty/error states, navigation, and removal of unsupported claims.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-004 | In `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart`, add an injectable fake `HealthTasksRepository` and widget tests for `echo3`, `blood2`, VAT selection (`vat1` pending, `vat2` pending, both complete, one task missing, both missing), missing non-VAT tasks, task loading, task-load failure/retry, and card/`Tout voir` navigation. Assert that task dates, laboratory results, facility claims, booking controls, and PDF/report actions do not render. Preserve all existing dashboard identity and CPN tests. | ✅ | 2026-10-06 |
| TASK-005 | Run the focused test file `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart` and Flutter analysis for the changed Dart files. Fix regressions caused by this feature and confirm no new diagnostics are introduced. This task depends on TASK-001 through TASK-004. | ✅ | 2026-10-06 |

## 3. Alternatives

- **ALT-001**: Keep the hard-coded recommendation cards and append a task status. Rejected because the existing titles, dates, results, facilities, and actions imply unsupported medical or appointment data.
- **ALT-002**: Remove the entire examination section. Rejected because persisted task state can safely provide meaningful checklist progress.
- **ALT-003**: Add appointment booking and medical-result/document storage. Rejected because it is a larger workflow requiring new data contracts and user-facing decisions outside the approved scope.

## 4. Dependencies

- **DEP-001**: Existing `HealthTasksProvider` and `HealthTasksRepository`.
- **DEP-002**: Existing `MaternityRepositoryFactory.healthTasks(uid:)` guest-local and authenticated implementations.
- **DEP-003**: Existing `HealthTasksPage` as the destination for task-list navigation.
- **DEP-004**: Approved design specification at `docs/superpowers/specs/2026-10-06-maternity-exam-task-cards-design.md`.

## 5. Files

- **FILE-001**: `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart` — task-provider lifecycle, active-session handling, card mapping, loading/error states, and navigation.
- **FILE-002**: `lib/features/maternity/presentation/widgets/maternity_dashboard_widgets.dart` — optional neutral card content and task-status presentation.
- **FILE-003**: `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart` — task repository fake and dashboard behavior tests.
- **FILE-004**: `docs/superpowers/specs/2026-10-06-maternity-exam-task-cards-design.md` — approved requirements and acceptance criteria; reference only.

## 6. Testing

- **TEST-001**: Verify exact task identifier mapping and completion labels in dashboard widget tests.
- **TEST-002**: Verify VAT sequence selection and missing-task behavior for each defined edge case.
- **TEST-003**: Verify task loading and error/retry states do not appear as an empty successful result.
- **TEST-004**: Verify card actions and `Tout voir` open `HealthTasksPage`.
- **TEST-005**: Verify generated dates, results, facility counts, booking controls, and PDF/report actions are absent.
- **TEST-006**: Run focused dashboard tests and Flutter analysis; ensure existing CPN and identity tests still pass.

## 7. Risks & Assumptions

- **RISK-001**: Health-task templates are initialized with relative due-date offsets. The dashboard must not accidentally expose those dates while refactoring the card.
- **RISK-002**: Authentication changes must clear the previous account's task state before displaying newly loaded tasks.
- **ASSUMPTION-001**: The existing task repository returns stable IDs `echo3`, `blood2`, `vat1`, and `vat2` when those tasks are available.
- **ASSUMPTION-002**: Marking a task complete remains the user's declaration and is not a clinical result.

## 8. Related Specifications / Further Reading

- [Approved maternity exam task-cards specification](../docs/superpowers/specs/2026-10-06-maternity-exam-task-cards-design.md)
- [Maternity Firestore synchronization specification](../docs/superpowers/specs/2026-10-05-maternity-firestore-sync-design.md)
- [Maternity dashboard recommendation specification](../docs/superpowers/specs/2026-10-06-maternity-remove-demo-appointment-design.md)
