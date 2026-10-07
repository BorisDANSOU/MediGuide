---
goal: Replace fictional maternity appointment and pregnancy details with CPN recommendations
version: 1.0
date_created: 2026-10-06
last_updated: 2026-10-06
owner: MediGuide
status: 'Completed'
tags: [feature, maternity, data-integrity, flutter]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

Remove placeholder pregnancy age and appointment details from the maternity
dashboard, and show only the next incomplete CPN recommendation from the
existing schedule.

## 1. Requirements & Constraints

- **REQ-001**: Select the first `CpnEntity` with `completed == false` from the
  current schedule list; show its actual `name` and `week`.
- **REQ-002**: Clearly label the displayed CPN as a recommendation, not a
  booked/confirmed appointment.
- **REQ-003**: Remove hard-coded gestational week, trimester, estimated due
  date, appointment countdown/date/time, facility, and practitioner.
- **REQ-004**: Remove presence confirmation and itinerary actions while no
  persisted appointment entity exists.
- **REQ-005**: If no incomplete CPN exists, show a neutral no-recommendation
  message without suggesting a real appointment.
- **CON-001**: Do not add appointment or pregnancy-profile persistence as part
  of this change.
- **CON-002**: Preserve local guest progress and CPN completion behavior.
- **CON-003**: Keep the dashboard's emergency card, exam cards, advice, and task
  navigation unchanged.
- **PAT-001**: Derive dashboard content from `MaternityProvider.cpnSchedules`;
  do not hard-code individual schedule IDs or appointment metadata.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Replace the appointment-like card with a truthful CPN recommendation.

Completion criteria:

- The next incomplete CPN is displayed with its recommended week and a visible
  disclaimer that it is a recommendation, not a booked visit.
- None of the old fabricated age, term, appointment, place, provider, or
  appointment-action labels remain on the pregnancy dashboard.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Refactor `PregnancySummaryCard` in `lib/features/maternity/presentation/widgets/maternity_dashboard_widgets.dart` to accept only the next `CpnEntity?`; remove `presenceConfirmed`, `onConfirmPresence`, and `onItinerary` constructor parameters and fields. Remove static `28e SA`, trimester, `14 Nov. 2025`, countdown, `Jeudi 18 Septembre à 09h00`, `Centre Médical Urbain (CMU)`, and `Dr. Konan` widgets. Render heading `Prochaine consultation recommandée`, CPN name, `Semaine recommandée : <week>`, and `Recommandation du calendrier — aucun rendez-vous confirmé.` If `cpn` is null, render `Aucune consultation CPN à venir dans le calendrier.` | ✅ | 2026-10-06 |
| TASK-002 | Update `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart`: remove `_presenceConfirmed`, stop passing presence/itinerary callbacks to `PregnancySummaryCard`, and preserve `_nextCpn` selection and surrounding dashboard actions without adding appointment creation behavior. | ✅ | 2026-10-06 |

### Implementation Phase 2

- GOAL-002: Validate truthful recommendation, completed, and empty schedule UI.

Completion criteria:

- Dashboard tests verify real CPN name/week and disclaimer.
- Tests confirm fabricated metadata and appointment controls are absent.
- Existing maternity dashboard and full Flutter tests pass.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-003 | Update `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart`: assert the next incomplete CPN name/week and the explicit recommendation disclaimer; assert absence of `28e SA`, `T3 • Trimestre Vital`, `14 Nov. 2025`, `Dans 4 jours`, `Jeudi 18 Septembre`, `Centre Médical Urbain`, `Dr. Konan`, `Confirmer présence`, and `Itinéraire`. Add a test with every fake CPN completed and assert the no-upcoming-CPN message. | ✅ | 2026-10-06 |
| TASK-004 | Run focused maternity dashboard tests, all Flutter tests, and `flutter analyze`; verify analysis introduces no new diagnostic. | ✅ | 2026-10-06 |

## 3. Alternatives

- **ALT-001**: Keep demo appointment text only for guests. Rejected because it
  presents fictitious clinical logistics as real.
- **ALT-002**: Hide the full CPN card until a booked appointment exists.
  Rejected because existing schedule reference data is available and useful as
  a clearly labeled recommendation.
- **ALT-003**: Add appointment fields and booking flow now. Rejected because
  no appointment model, facility assignment, or booking backend exists and
  those additions exceed the approved scope.

## 4. Dependencies

- **DEP-001**: `CpnEntity` and the existing maternity repository schedule data.
- **DEP-002**: Existing Flutter widget-test setup and fake maternity repository.

## 5. Files

- **FILE-001**: `lib/features/maternity/presentation/widgets/maternity_dashboard_widgets.dart` — remove fictional details and render recommendation.
- **FILE-002**: `lib/features/maternity/presentation/pages/maternity_dashboard_page.dart` — remove appointment-only local state and callbacks.
- **FILE-003**: `test/features/maternity/presentation/pages/maternity_dashboard_page_test.dart` — recommendation and no-fabricated-data tests.

## 6. Testing

- **TEST-001**: Incomplete CPN is shown with its actual name and recommended week.
- **TEST-002**: Recommendation disclaimer is visible and no appointment-confirmed language appears.
- **TEST-003**: No hard-coded pregnancy age, trimester, due date, appointment time/date, facility, practitioner, countdown, confirmation, or itinerary remains.
- **TEST-004**: All-completed/empty schedule shows the neutral no-upcoming-CPN state.
- **TEST-005**: Focused and full Flutter test suites pass; `flutter analyze` has no new issues.

## 7. Risks & Assumptions

- **RISK-001**: Users may still interpret a recommended CPN week as a booked
  visit; the explicit disclaimer and absence of logistics/actions mitigate
  this.
- **ASSUMPTION-001**: The existing `CpnEntity.week` is the authoritative
  recommendation value for dashboard presentation.
- **ASSUMPTION-002**: No true maternity appointment source is currently
  available; adding one requires a separately approved design.

## 8. Related Specifications / Further Reading

- [Approved maternity dashboard recommendation design](../docs/superpowers/specs/2026-10-06-maternity-remove-demo-appointment-design.md)
- [Approved authenticated maternity header design](../docs/superpowers/specs/2026-10-06-maternity-authenticated-header-design.md)
