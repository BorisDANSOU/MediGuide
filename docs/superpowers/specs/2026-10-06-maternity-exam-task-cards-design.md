---
title: Maternity Exam Cards Backed by Health Tasks
version: 1.0
date_created: 2026-10-06
tags: [design, maternity, firestore, flutter]
---

# Introduction

This specification defines how the maternity dashboard's examination and
vaccination cards reflect persisted health-task state without presenting
unrecorded appointments, laboratory results, facilities, or documents as real.

## 1. Purpose & Scope

The target audience is developers implementing the pregnancy dashboard in
MediGuide. The scope is limited to the "Échéances & Examens Recommandés"
section and its navigation to the existing health-task list.

The dashboard must use the existing guest-local or authenticated Firestore
health-task repository. This specification does not introduce medical-record
uploads, appointment booking, facility search, clinician validation, or a new
source of medical recommendations.

## 2. Definitions

- **Health task**: A persisted `HealthTaskEntity` with an identifier, title,
  completion state, due date, and other checklist fields.
- **Declared complete**: The `isCompleted` state recorded by the user through
  the existing health-task checklist. This is not professional verification.
- **SA**: *Semaines d'aménorrhée*, a gestational-age unit.
- **Guest mode**: Use of the maternity feature without an authenticated user;
  health-task changes are persisted locally.

## 3. Requirements, Constraints & Guidelines

- **REQ-001**: The dashboard shall obtain examination and vaccination task
  state from the health-task repository selected for the current session.
- **REQ-002**: The third-trimester ultrasound card shall be associated with task
  identifier `echo3`.
- **REQ-003**: The second-trimester biological assessment card shall be
  associated with task identifier `blood2`.
- **REQ-004**: The VAT card shall represent the VAT sequence: show the first
  available incomplete task in order `vat1`, then `vat2`. If both tasks exist
  and are complete, show the `vat2` task as declared complete. If only one VAT
  task exists, show that task. If neither exists, omit the VAT card.
- **REQ-005**: Each card shall derive its title from the associated task and
  show only one of these task states: `À suivre` when `isCompleted` is false,
  and `Déclaré fait` when `isCompleted` is true.
- **REQ-006**: Each displayed card shall have a `Voir le suivi` action that
  opens the existing health-task list. The section's `Tout voir` action shall
  open the same list.
- **REQ-007**: Omit an examination card when its associated task is absent.
  During task loading, do not present absence as a confirmed empty state.
- **REQ-008**: If health tasks fail to load, display the loading error and a
  retry action; do not silently treat the error as missing tasks.
- **REQ-009**: Reload health tasks for the active account when authentication
  changes, using the same guest-local/authenticated repository selection as
  the existing maternity task list.
- **CON-001**: Task completion is a user-declared checklist state, not evidence
  that a clinician performed or verified an examination.
- **CON-002**: Existing task due dates are initialized from relative template
  offsets and are not confirmed clinical appointments. The cards shall not
  display them.
- **CON-003**: Health tasks do not store examination results, report files,
  nearby facilities, or bookings. The cards shall not claim or imply that any
  such data is available.
- **GUD-001**: Keep the existing dashboard card visual pattern where possible;
  remove or neutralize fields that would require unsupported data.

## 4. Interfaces & Data Contracts

The dashboard consumes the existing `HealthTasksRepository` through
`HealthTasksProvider`. It shall use the following identifiers:

| Dashboard card | Task identifier(s) | State source |
| --- | --- | --- |
| Third-trimester ultrasound | `echo3` | `HealthTaskEntity.isCompleted` |
| Second-trimester biological assessment | `blood2` | `HealthTaskEntity.isCompleted` |
| VAT | `vat1`, then `vat2` | `HealthTaskEntity.isCompleted` |

The card title shall come from `HealthTaskEntity.title`. The status label shall
be `À suivre` or `Déclaré fait` as specified in REQ-005. No task due date,
completion date, or inferred medical result may be rendered in this section.

The card action and the section-level `Tout voir` action shall navigate to the
existing `HealthTasksPage`, which remains the authoritative checklist UI for
viewing and changing task completion state.

## 5. Acceptance Criteria

- **AC-001**: Given an `echo3` task is loaded and incomplete, when the dashboard
  renders, then the ultrasound card shows its task title and `À suivre`.
- **AC-002**: Given a `blood2` task is loaded and complete, when the dashboard
  renders, then the biological-assessment card shows its task title and
  `Déclaré fait`.
- **AC-003**: Given `vat1` is incomplete, when both VAT tasks are loaded, then
  the VAT card reflects `vat1`, regardless of `vat2` state.
- **AC-004**: Given `vat1` is complete and `vat2` is incomplete, when both VAT
  tasks are loaded, then the VAT card reflects `vat2` with `À suivre`.
- **AC-005**: Given both VAT tasks are complete, when the dashboard renders,
  then the VAT card reflects `vat2` with `Déclaré fait`.
- **AC-006**: Given a non-VAT task is absent, when the dashboard finishes
  loading, then its corresponding card is not shown.
- **AC-007**: Given both VAT tasks are absent, when the dashboard finishes
  loading, then the VAT card is not shown.
- **AC-008**: Given tasks have due dates or completion dates, when any card
  renders, then no date, gestational-week claim, laboratory value, result,
  facility count, booking control, or PDF/report action is displayed.
- **AC-009**: Given the user activates a card's `Voir le suivi` action or the
  section's `Tout voir` action, when navigation occurs, then the existing
  health-task list is opened.
- **AC-010**: Given task loading fails, when the dashboard renders, then it
  displays an explicit error and retry control instead of treating tasks as
  absent.
- **AC-011**: Given the session changes between guest and authenticated
  accounts, when the dashboard reloads tasks, then only the repository for the
  currently active session supplies card state.
- **AC-012**: Given a user marks a task complete in the health-task list, when
  the dashboard reloads its task state, then it displays `Déclaré fait`
  without calling the state medically validated.

## 6. Test Automation Strategy

- **Test Levels**: Widget tests for dashboard card rendering and navigation;
  provider/repository tests remain responsible for persistence behavior.
- **Frameworks**: Existing Flutter test framework and repository fakes.
- **Test Data Management**: Inject deterministic health-task repository
  fixtures with controlled identifiers and completion states.
- **CI/CD Integration**: Run the focused maternity dashboard widget tests and
  Flutter analysis using the repository's existing commands.
- **Coverage Requirements**: Cover all acceptance criteria involving card
  mapping, VAT sequence selection, omitted tasks, error/retry behavior,
  navigation, and session changes.
- **Performance Testing**: Not required; no new high-volume operation is
  introduced.

## 7. Rationale & Context

The current dashboard shows hard-coded appointment details, a laboratory
result, a facility count, and non-functional booking/PDF actions. The task
checklist is the only existing persisted source for the completion state of
these items. Using that state makes the dashboard consistent with the existing
guest and authenticated task flows while avoiding the implication that a
checklist entry is a verified medical record. Template-generated due dates are
excluded because they are not clinician-provided scheduling data.

## 8. Dependencies & External Integrations

### External Systems
- **EXT-001**: Firebase Authentication - Supplies the current account identity
  used to select the task repository.

### Third-Party Services
- **SVC-001**: Cloud Firestore - Stores authenticated users' maternity tasks
  through the existing owner-scoped repository.

### Infrastructure Dependencies
- **INF-001**: Existing local persistence for guest-mode maternity tasks.

### Data Dependencies
- **DAT-001**: Existing health-task templates and persisted completion state,
  identified by `echo3`, `blood2`, `vat1`, and `vat2`.

### Technology Platform Dependencies
- **PLT-001**: Existing Flutter and Riverpod application architecture.

### Compliance Dependencies
- **COM-001**: Do not label a user-declared checklist completion as a
  clinician-confirmed examination or test result.

## 9. Examples & Edge Cases

| Loaded tasks | Dashboard result |
| --- | --- |
| `echo3`: incomplete | Ultrasound card: task title, `À suivre` |
| `blood2`: complete | Biological assessment card: task title, `Déclaré fait` |
| `vat1`: complete; `vat2`: incomplete | VAT card reflects `vat2`, `À suivre` |
| `vat1`: complete; `vat2`: complete | VAT card reflects `vat2`, `Déclaré fait` |
| No `echo3` or `blood2` | Corresponding cards are omitted |
| No `vat1` or `vat2` | VAT card is omitted |
| Task repository returns an error | Show an explicit error and retry action |

## 10. Validation Criteria

- Every card state is derived from a matching loaded task, never a hard-coded
  completion label.
- The VAT sequence follows REQ-004 for complete, incomplete, and missing tasks.
- No generated dates, laboratory measurements, report links, facility counts,
  or booking claims remain in the examination section.
- Card and `Tout voir` navigation reach the existing health-task list.
- Guest and authenticated task states remain isolated according to their
  existing repositories.
- Focused dashboard tests and Flutter analysis pass.

## 11. Related Specifications / Further Reading

- [Maternity Firestore synchronization](./2026-10-05-maternity-firestore-sync-design.md)
- [Maternity dashboard recommendation design](./2026-10-06-maternity-remove-demo-appointment-design.md)
