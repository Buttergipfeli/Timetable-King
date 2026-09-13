# Timetable King App

Timetable King is a powerful and user friendly application designed to help people manage their weekly schedules effectively. With its intuitive and compact interface, Timetable King allows users to create, organize and customize their timetables with ease.

## Onboarding

New users see a short introduction and can create their first weekly task from an editable morning routine, training or household template, or enter their own task. The introduction can be skipped and reopened from Settings. Existing users with saved tasks go straight to their dashboard.

Debug builds use persistent data by default. These launch arguments support manual checks and UI tests:

* `--demo-data`: use an in-memory store with the existing sample timetable and history.
* `--empty-store`: use an empty in-memory store without changing saved tasks.
* `--reset-onboarding`: clear only the onboarding completion flag. Combine with `--empty-store` to test a first launch.
