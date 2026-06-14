# Analytics Event Catalog

This catalog outlines all tracked telemetry events inside the application.

## Core Events

| Event Name | Trigger | Properties |
| --- | --- | --- |
| `app_open` | The user launches the application | `source` (e.g. icon, notification) |
| `workout_created` | A user successfully saves a new workout | `exercise_count`, `estimated_duration` |
| `session_started` | A user begins a workout session | `workout_id`, `program_id` (optional) |
| `session_completed` | A user completes an active session | `duration`, `volume_lifted`, `prs_broken` |
| `goal_completed` | A user reaches their set fitness goal | `goal_type`, `target_value` |
| `export_completed` | A user successfully exports their backup data | `file_size` |

## Validation
100% of these events are integrated into `MonitoringService` and tested in unit coverage.
