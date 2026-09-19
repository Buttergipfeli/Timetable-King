# Graph Report - Timetable King  (2026-09-19)

## Corpus Check
- Corpus is ~25,137 words - fits in a single context window. You may not need a graph.

## Summary
- 1109 nodes · 2527 edges · 73 communities (65 shown, 8 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 375 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- App Coordination and Navigation
- Weekly History Summaries
- Daily Task Review
- Recurring Task Persistence
- Reminder Delivery and Deep Links
- Weekly Summary Models
- End to End UI Tests
- Repository Graphify Policies
- Widget Snapshot Progress
- Test Infrastructure Imports
- Model Container History
- Dashboard Today Overview
- Dashboard UI Foundations
- Reminder Delivery Validation
- App Palette Model
- Page Control Gestures
- Weekday Calendar Logic
- Task History Regression Tests
- Weekday Digest Building
- Review Resolution and Test Data
- SwiftUI Navigation Extensions
- Widget Snapshot Metrics
- Widget Timeline Provider
- Onboarding Unit Tests
- Task Status Controls
- Widget Snapshot Sync
- Dashboard Weekly Progress
- Today Task Details
- Today Task Lists
- Task Editing Reminders
- Dashboard Layout
- Palette Generation
- Weekday Habit Model
- Add Task Flow
- Repository Build Policies
- Weekly Summary Picker
- Widget Task Deep Links
- Today Task Sections
- Accessory Widgets
- Widget Bundle Configuration
- Digest Builder Models
- Today Task Status Model
- Reminder Options
- Palette Preferences Tests
- Task Status Badges
- Progress Ring
- Weekly Plan Dashboard
- Onboarding Introduction
- Medium Widget Layout
- Dashboard Header
- Dashboard Surface Styling
- App Bootstrap and Seeds
- Weekday Sorting
- Palette Storage
- Dashboard Snapshot Metrics
- Onboarding Routine Builder
- Settings Screen
- Large Widget Layout
- Widget Theme Container
- App Theme
- Weekly Task Errors
- Reminder Documentation
- Demo History Data
- Weekday Selection
- Seeded Random Generator
- Reminder System Dependencies
- History State Model
- Habit Result Model
- Today Tasks Dashboard
- Weekly Summary Dashboard
- Agent Graphify Reporting
- Claude Graphify Reporting
- Dashboard Documentation

## God Nodes (most connected - your core abstractions)
1. `WeekdayHabit` - 75 edges
2. `Weekday` - 72 edges
3. `TimetableKingAppViewModel` - 46 edges
4. `TimetableWidgetSnapshot` - 44 edges
5. `TodayTaskEntry` - 39 edges
6. `WeekdayDigest` - 38 edges
7. `ModelContainerService` - 38 edges
8. `WeekdayHabitResult` - 34 edges
9. `HabitState` - 30 edges
10. `TaskReminder` - 29 edges

## Surprising Connections (you probably didn't know these)
- `.tasks` --references--> `TimetableWidgetSnapshot`  [INFERRED]
  Timetable King Widgets/Home/TimetableMediumWidgetView.swift → Timetable King Shared/TimetableWidgetSnapshot.swift
- `TimetableWidgetProvider` --calls--> `AppPaletteStorage`  [INFERRED]
  Timetable King Widgets/TimetableWidgetProvider.swift → Timetable King Shared/AppPaletteStorage.swift
- `.body` --references--> `TimetableWidgetTask`  [INFERRED]
  Timetable King Widgets/Home/TimetableMediumWidgetView.swift → Timetable King Shared/TimetableWidgetSnapshot.swift
- `TimetableWidgetProvider` --calls--> `TimetableWidgetSnapshotStore`  [INFERRED]
  Timetable King Widgets/TimetableWidgetProvider.swift → Timetable King Shared/TimetableWidgetSnapshot.swift
- `AppPalette` --references--> `String`  [EXTRACTED]
  Timetable King Shared/AppPalette.swift → Timetable King/Extension/String+Extensions.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Graphify Knowledge Navigation Workflow** — agents_graphify_knowledge_graph, agents_graphify_query_workflow, agents_graphify_wiki, agents_graph_report, agents_graphify_update [EXTRACTED 1.00]
- **Graphify Knowledge Navigation Workflow** — claude_graphify_knowledge_graph, claude_graphify_query_workflow, claude_graphify_wiki, claude_graph_report, claude_graphify_update [EXTRACTED 1.00]
- **Reminder Lifecycle** — readme_local_reminders, readme_notification_permission, readme_reminder_queue, readme_reminder_refresh, readme_reminder_deep_links [EXTRACTED 1.00]

## Communities (73 total, 8 thin omitted)

### Community 0 - "App Coordination and Navigation"
Cohesion: 0.07
Nodes (27): Bool, .not, CardPage, todayTasks, .transitionID, weeklySummary, weeklyTasks, OnboardingStore (+19 more)

### Community 1 - "Weekly History Summaries"
Cohesion: 0.07
Nodes (32): CompletionScore, .completionPercentage, .performanceEmoji, Double, Int, Calendar, Date, DateInterval (+24 more)

### Community 2 - "Daily Task Review"
Cohesion: 0.06
Nodes (39): CGFloat, Gesture, Hashable, Date, TodayTaskReviewEntry, .id, .timeString, .title (+31 more)

### Community 3 - "Recurring Task Persistence"
Cohesion: 0.14
Nodes (14): TaskReminderPlanner, Calendar, Date, Int, Set, WeeklyTaskService, Calendar, Date (+6 more)

### Community 4 - "Reminder Delivery and Deep Links"
Cohesion: 0.06
Nodes (30): Never, Task, PlannedTaskReminder, .notificationUserInfo, Any, AnyHashable, Calendar, Date (+22 more)

### Community 5 - "Weekly Summary Models"
Cohesion: 0.06
Nodes (33): WeekdayDigest, .id, .isEmpty, Date, Int, WeeklySummaryEntry, .completedCount, .completionScore (+25 more)

### Community 6 - "End to End UI Tests"
Cohesion: 0.08
Nodes (11): OnboardingUITests, XCUIApplication, XCUIApplication, TaskFeaturesUITests, XCUIApplication, Timetable_KingUITests, Timetable_KingUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration (+3 more)

### Community 7 - "Repository Graphify Policies"
Cohesion: 0.07
Nodes (30): AppStorage, Build Testing Policy, Debug Build, Dirty Graph Tolerance, Graphify Explain, Graphify Knowledge Graph, Graphify Path, Graphify Query Workflow (+22 more)

### Community 8 - "Widget Snapshot Progress"
Cohesion: 0.18
Nodes (12): Calendar, Date, TimetableWidgetSnapshot, .completedTodayCount, .dailyProgress, .isTodayComplete, .nextTask, .today (+4 more)

### Community 9 - "Test Infrastructure Imports"
Cohesion: 0.21
Nodes (6): Foundation, SwiftData, Testing, Timetable_King, TimetableKingAppGroup, DashboardSnapshotTests

### Community 10 - "Model Container History"
Cohesion: 0.13
Nodes (11): HistoryState, HistoryStateService, .historyDeletedAt, .historyDeletedDayStart, Calendar, Date, ModelContainerService, .context (+3 more)

### Community 11 - "Dashboard Today Overview"
Cohesion: 0.11
Nodes (21): TodayTaskDisplayStatus, TodayTaskEntry, .id, .statusDescription, .statusTitle, .timeString, .title, .widgetIdentifier (+13 more)

### Community 12 - "Dashboard UI Foundations"
Cohesion: 0.09
Nodes (12): SwiftUI, EnvironmentValues, Namespace, CGFloat, CGFloat, Int, CGFloat, CGFloat (+4 more)

### Community 13 - "Reminder Delivery Validation"
Cohesion: 0.17
Nodes (12): Schedule, Any, AnyHashable, Calendar, Date, Set, UUID, TaskReminderDeliveryState (+4 more)

### Community 14 - "App Palette Model"
Cohesion: 0.18
Nodes (17): Codable, Equatable, Sendable, .color, AppPalette, AppPaletteVariant, HSLColor, .normalizedHue (+9 more)

### Community 15 - "Page Control Gestures"
Cohesion: 0.14
Nodes (12): NSObject, Coordinator, Context, Int, Void, WeeklySummaryPageControl, UIGestureRecognizer, UIGestureRecognizerDelegate (+4 more)

### Community 16 - "Weekday Calendar Logic"
Cohesion: 0.11
Nodes (16): Date, Int, Weekday, .current, friday, .isFuture, .isToday, .label (+8 more)

### Community 17 - "Task History Regression Tests"
Cohesion: 0.30
Nodes (4): Habit, Date, Timetable_KingTests, TimetableKingTestsWidgetSnapshotService

### Community 18 - "Weekday Digest Building"
Cohesion: 0.24
Nodes (5): WeekdayHabitResult, Date, DateInterval, Item, WeekdayDigestService

### Community 19 - "Review Resolution and Test Data"
Cohesion: 0.25
Nodes (5): Date, Int, TodayTaskReviewService, DebugTestDataTests, ModelContainer

### Community 20 - "SwiftUI Navigation Extensions"
Cohesion: 0.22
Nodes (10): CVarArg, String, .localized, init(), MatchedTransitionSourceViewModifier, NavigationZoomTransitionViewModifier, Content, Namespace (+2 more)

### Community 21 - "Widget Snapshot Metrics"
Cohesion: 0.17
Nodes (13): Identifiable, Double, Int, TimetableWidgetConstants, TimetableWidgetDay, .completedCount, .progress, .totalCount (+5 more)

### Community 22 - "Widget Timeline Provider"
Cohesion: 0.19
Nodes (10): Timeline, TimelineEntry, TimelineProvider, AppPalette, Date, TimetableWidgetEntry, Context, Date (+2 more)

### Community 23 - "Onboarding Unit Tests"
Cohesion: 0.26
Nodes (6): OnboardingFixture, .store, OnboardingTests, OnboardingWidgetSnapshotService, Date, UserDefaults

### Community 24 - "Task Status Controls"
Cohesion: 0.16
Nodes (11): HabitState, done, failed, none, Int, WeeklySummaryView, DashboardTaskStatusControl, .body (+3 more)

### Community 25 - "Widget Snapshot Sync"
Cohesion: 0.21
Nodes (5): Date, TodayTaskDisplayStatus, WidgetSnapshotService, UserDefaults, TimetableWidgetSnapshotStore

### Community 26 - "Dashboard Weekly Progress"
Cohesion: 0.20
Nodes (10): DashboardWeekdayProgress, .displayValue, .isComplete, Int, DashboardWeeklySummaryView, .header, .progressDescription, .weekdayValues (+2 more)

### Community 27 - "Today Task Details"
Cohesion: 0.23
Nodes (8): LocalizedStringKey, TodayTaskDisplayStatus, TodayTaskDetailView, .body, .currentDetailDescription, .statusCard, TodayTaskDisplayStatus, TodayTaskDetailViewModel

### Community 28 - "Today Task Lists"
Cohesion: 0.18
Nodes (7): CGFloat, TodayTasksView, .body, TodayTasksViewModel, DismissToolbarItem, .body, ToolbarContent

### Community 29 - "Task Editing Reminders"
Cohesion: 0.18
Nodes (9): Int, Set, WeeklyTaskEditView, .body, Int, Set, WeeklyTaskEditViewModel, .isSaveable (+1 more)

### Community 30 - "Dashboard Layout"
Cohesion: 0.15
Nodes (12): CGFloat, DashboardAddTaskButton, .body, Double, Void, CGFloat, DashboardView, .compactContent (+4 more)

### Community 31 - "Palette Generation"
Cohesion: 0.24
Nodes (7): Generator, AppPaletteGenerator, AppPalette, Double, AppPaletteRepository, AppPaletteStore, AppPalette

### Community 32 - "Weekday Habit Model"
Cohesion: 0.19
Nodes (11): Date, Int, UUID, WeekdayHabit, .activeRecurrenceSchedules, .isDeleted, .reminder, .timeString (+3 more)

### Community 33 - "Add Task Flow"
Cohesion: 0.19
Nodes (8): AddWeeklyTaskView, .body, Int, Set, AddWeeklyTaskViewModel, .isSaveable, Int, Set

### Community 34 - "Repository Build Policies"
Cohesion: 0.17
Nodes (12): AppStorage, Build Testing Policy, Debug Build, Graphify Explain, Graphify Knowledge Graph, Graphify Path, Graphify Query Workflow, Graphify Update (+4 more)

### Community 35 - "Weekly Summary Picker"
Cohesion: 0.31
Nodes (7): DateIntervalFormatter, CGFloat, DateInterval, Int, Void, WeeklySummaryWeekPickerView, .body

### Community 36 - "Widget Task Deep Links"
Cohesion: 0.18
Nodes (7): TimetableAccessoryInlineView, .body, TimetableSmallWidgetView, .body, .resolvedStateIcon, .resolvedStateTitle, .defaultURL

### Community 37 - "Today Task Sections"
Cohesion: 0.18
Nodes (11): Void, TodayTaskRowView, .body, LocalizedStringKey, TodayTasksEmptyStateView, .body, LocalizedStringKey, Void (+3 more)

### Community 38 - "Accessory Widgets"
Cohesion: 0.20
Nodes (7): TimetableAccessoryCircularView, .body, TimetableAccessoryRectangularView, .body, .progressContent, .content, WidgetKit

### Community 39 - "Widget Bundle Configuration"
Cohesion: 0.20
Nodes (10): TimetableKingWidget, .body, .supportedFamilies, Widget, TimetableKingWidgetBundle, .body, Widget, WidgetBundle (+2 more)

### Community 40 - "Digest Builder Models"
Cohesion: 0.27
Nodes (4): Item, WeekdayBucket, .id, WeekdayDigestBuilder

### Community 41 - "Today Task Status Model"
Cohesion: 0.20
Nodes (7): TodayTaskDisplayStatus, done, failed, future, .title, todo, .detailDescription

### Community 42 - "Reminder Options"
Cohesion: 0.22
Nodes (8): CaseIterable, Int, TaskReminder, atTime, .minutesBefore, off, tenMinutesBefore, .title

### Community 43 - "Palette Preferences Tests"
Cohesion: 0.33
Nodes (4): AppPalette, UserDefaults, UserDefaultsAppPaletteRepository, AppPaletteTests

### Community 44 - "Task Status Badges"
Cohesion: 0.28
Nodes (7): CGFloat, Color, TodayTaskDisplayStatus, .color, TodayTaskStatusBadge, .badgeLabel, .body

### Community 45 - "Progress Ring"
Cohesion: 0.22
Nodes (8): CGFloat, DashboardProgressRing, .body, .progress, Double, Double, Int, .body

### Community 46 - "Weekly Plan Dashboard"
Cohesion: 0.22
Nodes (7): .weeklyPlan, CGFloat, DashboardWeeklyPlanView, .body, .weekdayDots, Double, Void

### Community 47 - "Onboarding Introduction"
Cohesion: 0.25
Nodes (7): OnboardingView, .body, .introduction, Int, LocalizedStringKey, Set, Void

### Community 48 - "Medium Widget Layout"
Cohesion: 0.25
Nodes (8): TimetableMediumWidgetView, .body, .resolvedStateIcon, .resolvedStateTitle, .taskCountLabel, .tasks, TimetableWidgetTaskRow, .body

### Community 49 - "Dashboard Header"
Cohesion: 0.25
Nodes (7): CGFloat, DashboardHeaderView, .body, .brandMark, Date, Void, .body

### Community 50 - "Dashboard Surface Styling"
Cohesion: 0.25
Nodes (7): CGFloat, DashboardSurface, .body, Double, Content, .body, .body

### Community 51 - "App Bootstrap and Seeds"
Cohesion: 0.29
Nodes (4): App, Scene, ModelContainer, Timetable_KingApp

### Community 52 - "Weekday Sorting"
Cohesion: 0.29
Nodes (5): ComparisonResult, Habitable, SortComparator, SortOrder, WeekdayHabitableComparator

### Community 53 - "Palette Storage"
Cohesion: 0.38
Nodes (3): AppPaletteStorage, AppPalette, UserDefaults

### Community 54 - "Dashboard Snapshot Metrics"
Cohesion: 0.29
Nodes (6): DashboardSnapshot, .weeklyCompletionPercentage, Double, Set, .percentageDescription, Date

### Community 55 - "Onboarding Routine Builder"
Cohesion: 0.43
Nodes (5): OnboardingRoutineView, .body, Int, Set, Void

### Community 56 - "Settings Screen"
Cohesion: 0.29
Nodes (6): CGFloat, SettingsView, .body, .palettePreview, Int, Set

### Community 57 - "Large Widget Layout"
Cohesion: 0.33
Nodes (6): TimetableLargeWidgetView, .body, .emptyState, .weeklyOverview, TimetableWidgetDayProgressRow, .body

### Community 58 - "Widget Theme Container"
Cohesion: 0.33
Nodes (7): Color, URL, TimetableWidgetView, .accentColor, .body, .containerBackground, .paletteVariant

### Community 59 - "App Theme"
Cohesion: 0.40
Nodes (4): ColorScheme, AppPalette, AppTheme, Color

### Community 60 - "Weekly Task Errors"
Cohesion: 0.33
Nodes (5): Error, WeeklyTaskServiceError, duplicateTask, missingTask, missingWeekday

### Community 61 - "Reminder Documentation"
Cohesion: 0.33
Nodes (6): Local Reminders, Notification Center Retention, Notification Permission, Reminder Queue, Reminder Refresh, Task Outcomes

### Community 62 - "Demo History Data"
Cohesion: 0.47
Nodes (3): Date, Int, ModelContext

### Community 63 - "Weekday Selection"
Cohesion: 0.40
Nodes (4): Set, Void, WeekdaySelectionView, .body

### Community 64 - "Seeded Random Generator"
Cohesion: 0.60
Nodes (3): RandomNumberGenerator, SeededRandomNumberGenerator, UInt64

## Knowledge Gaps
- **205 isolated node(s):** `.relativeLuminance`, `.normalizedHue`, `todayTasks`, `weeklySummary`, `task` (+200 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 368 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `String` connect `SwiftUI Navigation Extensions` to `App Coordination and Navigation`, `Weekly History Summaries`, `Daily Task Review`, `Recurring Task Persistence`, `Reminder Delivery and Deep Links`, `Weekly Summary Models`, `End to End UI Tests`, `Widget Snapshot Progress`, `Dashboard Today Overview`, `Reminder Delivery Validation`, `App Palette Model`, `Weekday Calendar Logic`, `Widget Snapshot Metrics`, `Task Status Controls`, `Widget Snapshot Sync`, `Dashboard Weekly Progress`, `Today Task Details`, `Today Task Lists`, `Task Editing Reminders`, `Weekday Habit Model`, `Add Task Flow`, `Weekly Summary Picker`, `Widget Task Deep Links`, `Digest Builder Models`, `Today Task Status Model`, `Reminder Options`, `Palette Preferences Tests`, `Task Status Badges`, `Onboarding Introduction`, `Medium Widget Layout`, `Palette Storage`, `Onboarding Routine Builder`, `Settings Screen`, `Weekday Selection`?**
  _High betweenness centrality (0.244) - this node is a cross-community bridge._
- **Why does `Bool` connect `App Coordination and Navigation` to `Weekly History Summaries`, `Daily Task Review`, `Recurring Task Persistence`, `Weekly Summary Models`, `End to End UI Tests`, `Widget Snapshot Progress`, `Dashboard Today Overview`, `Reminder Delivery Validation`, `Page Control Gestures`, `Weekday Calendar Logic`, `Weekday Digest Building`, `Review Resolution and Test Data`, `Widget Timeline Provider`, `Task Status Controls`, `Dashboard Weekly Progress`, `Today Task Details`, `Today Task Lists`, `Task Editing Reminders`, `Dashboard Layout`, `Weekday Habit Model`, `Add Task Flow`, `Today Task Sections`, `Task Status Badges`, `Weekly Plan Dashboard`, `Onboarding Introduction`, `Onboarding Routine Builder`, `Settings Screen`, `Weekday Selection`?**
  _High betweenness centrality (0.174) - this node is a cross-community bridge._
- **Why does `Weekday` connect `Weekday Calendar Logic` to `App Coordination and Navigation`, `Weekly History Summaries`, `Recurring Task Persistence`, `Weekly Summary Models`, `App Palette Model`, `Task History Regression Tests`, `Weekday Digest Building`, `Review Resolution and Test Data`, `SwiftUI Navigation Extensions`, `Widget Snapshot Sync`, `Dashboard Weekly Progress`, `Task Editing Reminders`, `Dashboard Layout`, `Weekday Habit Model`, `Add Task Flow`, `Digest Builder Models`, `Reminder Options`, `Weekly Plan Dashboard`, `Onboarding Introduction`, `Dashboard Snapshot Metrics`, `Onboarding Routine Builder`, `Settings Screen`, `Demo History Data`, `Weekday Selection`?**
  _High betweenness centrality (0.125) - this node is a cross-community bridge._
- **Are the 16 inferred relationships involving `WeekdayHabit` (e.g. with `.fetchWeeklyTaskDigests()` and `.exposesCompletedAndTotalValuesForEachWeekday()`) actually correct?**
  _`WeekdayHabit` has 16 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `Weekday` (e.g. with `.fetchPendingReviewEntries()` and `.scheduledDate()`) actually correct?**
  _`Weekday` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `.relativeLuminance`, `.normalizedHue`, `todayTasks` to the rest of the system?**
  _205 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App Coordination and Navigation` be split into smaller, more focused modules?**
  _Cohesion score 0.07259528130671507 - nodes in this community are weakly interconnected._