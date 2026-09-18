# Timetable King App

Timetable King is a powerful and user friendly application designed to help people manage their weekly schedules effectively. With its intuitive and compact interface, Timetable King allows users to create, organize and customize their timetables with ease. Tasks can repeat on one or more fixed weekdays, with a shortcut for every day. Repetitions can be edited or deleted as a series without changing historical entries.

## Onboarding

New users see a short introduction and can create their first weekly task from an editable morning routine, training or household template, or enter their own task. Templates include suitable weekday repetitions that remain fully editable. The introduction can be skipped and reopened from Settings. Existing users with saved tasks go straight to their dashboard.

Debug builds use persistent data by default. These launch arguments support manual checks and UI tests:

* `--demo-data`: use an in-memory store with the existing sample timetable and history.
* `--empty-store`: use an empty in-memory store without changing saved tasks.
* `--reset-onboarding`: clear only the onboarding completion flag. Combine with `--empty-store` to test a first launch.

## Reminders and task outcomes

Tasks support optional local reminders at the scheduled time or ten minutes beforehand. Notification permission is requested when a reminder is enabled. The app schedules the next 64 upcoming reminders across all tasks and refreshes them when opened or when tasks change. Open the app regularly to replenish the queue. Editing, deleting, completing or skipping a task updates its pending reminders. Tapping a reminder opens the task if it belongs to today, otherwise the current task list.

Delivered reminders for unresolved tasks remain in Notification Center when other tasks change. Reminder links identify the exact schedule and occurrence date, so an older reminder cannot open a later repetition or another task with the same title and time.

Tasks can be skipped for the current day from the dashboard, task details or daily review. Skipped occurrences stay in history but are excluded from completion scores, including widgets. They can be changed back to open or another outcome during the same day.

Deleting a recurring task requires confirmation, both in the editor and through swipe actions. Previously recorded history and occurrences that are already due remain available.
