# Maternity Dashboard Recommendation Design

Date: 2026-10-06

## Goal

Remove fictional pregnancy and appointment details from the maternity dashboard
while continuing to show the real CPN recommendation data available in the
reference calendar.

## Existing behavior

`PregnancySummaryCard` currently displays hard-coded pregnancy week, trimester,
estimated due date, next-appointment date/time, facility, and practitioner.
It also shows an appointment countdown, presence-confirmation control, and
itinerary action. Only the CPN name/week and completion status come from the
maternity schedule; the other displayed appointment and pregnancy values are
not recorded user data.

## Chosen design

- Replace the fictitious pregnancy timeline with a neutral heading that does
  not imply gestational age or due date is known.
- Show the next uncompleted `CpnEntity` as a recommendation using its actual
  name and recommended week.
- Label the item explicitly as a calendar recommendation, not a confirmed
  appointment.
- Remove the fabricated appointment countdown, date/time, facility,
  practitioner, presence-confirmation control, and itinerary action.
- If all CPN recommendations are completed or none are available, show a
  neutral message rather than inventing appointment data.
- Keep guest mode and local CPN completion available; do not require
  authentication or add new pregnancy-profile fields.

## Validation

- Update dashboard tests to confirm the next available CPN recommendation and
  recommended week are shown.
- Assert the old demo pregnancy week, term date, appointment date, facility,
  practitioner, countdown, confirmation, and itinerary are not shown.
- Verify completed CPN recommendations are skipped and the empty/all-completed
  state is neutral.
- Run focused maternity dashboard tests and Flutter analysis.
