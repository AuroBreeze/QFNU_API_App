// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'QFNU Student Portal';

  @override
  String get loginTitle => 'QFNU Exam Login';

  @override
  String get loginSubtitle =>
      'Sign in with your student account to check exam schedule.';

  @override
  String get proxyUrlLabel => 'Proxy URL (Web only)';

  @override
  String get proxyUrlHint => 'http://localhost:8080';

  @override
  String get proxyUrlRequired => 'Proxy URL is required for web testing.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get rememberAccount => 'Remember account';

  @override
  String get rememberPassword => 'Remember password';

  @override
  String get captchaLabel => 'Captcha';

  @override
  String get captchaHint => 'Tap refresh to load';

  @override
  String get loginButton => 'Login';

  @override
  String get checkingSession => 'Checking session...';

  @override
  String get fillCredentialsError =>
      'Please fill in username, password, and captcha.';

  @override
  String get loginFailed => 'Login failed.';

  @override
  String loadCaptchaFailed(Object error) {
    return 'Failed to load captcha: $error';
  }

  @override
  String failedToLoadTerms(Object error) {
    return 'Failed to load terms: $error';
  }

  @override
  String failedToLoadExams(Object error) {
    return 'Failed to load exams: $error';
  }

  @override
  String failedToLoadOptions(Object error) {
    return 'Failed to load options: $error';
  }

  @override
  String failedToLoadGrades(Object error) {
    return 'Failed to load grades: $error';
  }

  @override
  String failedToLoadSchedule(Object error) {
    return 'Failed to load schedule: $error';
  }

  @override
  String failedToLoadTrainingPlan(Object error) {
    return 'Failed to load training plan: $error';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String welcomeUser(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get logout => 'Logout';

  @override
  String get examScheduleCardTitle => 'Exam Schedule';

  @override
  String get examScheduleCardSubtitle => 'Tap to view your upcoming exams';

  @override
  String get gradesCardTitle => 'Course Grades';

  @override
  String get gradesCardSubtitle => 'Tap to view your grades';

  @override
  String get timetableCardTitle => 'Timetable';

  @override
  String get timetableCardSubtitle => 'Tap to view your schedule';

  @override
  String get trainingPlanCardTitle => 'Training Plan';

  @override
  String get trainingPlanCardSubtitle =>
      'Tap to view progress by curriculum group';

  @override
  String get examScheduleTitle => 'Exam Schedule';

  @override
  String get gradeQueryTitle => 'Course Grades';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get trainingPlanTitle => 'Training Plan';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get query => 'Query';

  @override
  String get loading => 'Loading';

  @override
  String get refresh => 'Refresh';

  @override
  String get reload => 'Reload';

  @override
  String get filters => 'Filters';

  @override
  String get termLabel => 'Term';

  @override
  String get courseTypeLabel => 'Course Type';

  @override
  String get courseNameLabel => 'Course Name';

  @override
  String get displayLabel => 'Display';

  @override
  String get scoreLabel => 'Score';

  @override
  String get creditLabel => 'Credit';

  @override
  String get gpaLabel => 'GPA';

  @override
  String get averageGpaLabel => 'Average GPA';

  @override
  String averageGpaValue(Object value) {
    return 'Average GPA: $value';
  }

  @override
  String get currentTermLabel => 'Current term';

  @override
  String get allTerms => 'All terms';

  @override
  String get allOption => 'All';

  @override
  String get selectTerm => 'Select term';

  @override
  String get noTermOptions => 'No term options available.';

  @override
  String get noTermOptionsFound => 'No term options found.';

  @override
  String get noExamData => 'No exam data available.';

  @override
  String get noGradeData => 'No grade data available.';

  @override
  String get noClassesForDate => 'No classes scheduled for this date.';

  @override
  String get noTrainingPlanData => 'No training plan data.';

  @override
  String get loadingTrainingPlan => 'Loading training plan...';

  @override
  String get pickDate => 'Pick date';

  @override
  String get classPeriodLabel => 'Class period';

  @override
  String get untitledCourse => 'Untitled course';

  @override
  String completedRequired(Object completed, Object required) {
    return 'Completed $completed / Required $required';
  }

  @override
  String totalHoursLabel(Object hours) {
    return 'Total hours: $hours';
  }

  @override
  String coursesCount(Object count) {
    return 'Courses: $count';
  }

  @override
  String get completedSection => 'Completed';

  @override
  String get pendingSection => 'Pending';

  @override
  String get noCompletedCourses => 'No completed courses.';

  @override
  String get noPendingCourses => 'No pending courses.';

  @override
  String attributeLabel(Object value) {
    return 'Attribute: $value';
  }

  @override
  String creditsLabel(Object value) {
    return 'Credits: $value';
  }

  @override
  String termValueLabel(Object value) {
    return 'Term: $value';
  }

  @override
  String hoursValueLabel(Object value) {
    return 'Hours: $value';
  }

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get trainingPlanCacheTitle => 'Training plan cache';

  @override
  String get trainingPlanCacheSubtitle =>
      'Cache training plan data and update every few days.';

  @override
  String get cacheDaysLabel => 'Refresh interval';

  @override
  String cacheDaysValue(Object days) {
    return 'Update every $days days';
  }

  @override
  String get cacheClearButton => 'Clear training plan cache';

  @override
  String get cacheClearedMessage => 'Training plan cache cleared.';

  @override
  String get gradeNotifySectionTitle => 'Grade notifications';

  @override
  String get gradeNotifySectionSubtitle =>
      'Check in background and notify when new grades appear.';

  @override
  String get gradeNotifyEnabledLabel => 'Enable grade notifications';

  @override
  String get gradeNotifyIntervalLabel => 'Check interval';

  @override
  String gradeNotifyIntervalValue(Object hours) {
    return 'Every $hours hours';
  }

  @override
  String get gradeNotifyTitle => 'New grades available';

  @override
  String gradeNotifyBody(Object count) {
    return '$count new grade(s) detected';
  }

  @override
  String get gradeNotifyChannelName => 'Grade updates';

  @override
  String get gradeNotifyChannelDescription =>
      'Notify when new grades are posted';

  @override
  String get notificationPermissionRequired =>
      'Enable notification permission to receive grade reminders.';

  @override
  String get cloudNotifyTitle => 'Cloud grade reminders';

  @override
  String get cloudNotifySubtitle =>
      'Receive grade notifications even when the app is closed.';

  @override
  String get cloudNotifyEnabledLabel => 'Enable cloud grade reminders';

  @override
  String get cloudNotifyHint =>
      'Requires uploading your current session cookies to Firebase.';

  @override
  String get cloudNotifyDialogTitle => 'Enable cloud reminders?';

  @override
  String get cloudNotifyDialogBody =>
      'To check grades in the cloud, your current session cookies will be uploaded to Firebase. They may expire, and you will need to log in again when that happens.';

  @override
  String get cloudNotifyDialogConfirm => 'Enable';

  @override
  String get cloudNotifyRegisterSuccess => 'Cloud reminders enabled.';

  @override
  String cloudNotifyRegisterFailed(Object error) {
    return 'Cloud reminders failed: $error';
  }

  @override
  String get cloudNotifyLoginRequired =>
      'Please log in before enabling cloud reminders.';

  @override
  String get developerTitle => 'Developer';

  @override
  String get developerSubtitle => 'Advanced testing tools';

  @override
  String get testNotifyTitle => 'Background notification test';

  @override
  String get testNotifySubtitle =>
      'Check if notifications can fire when the app is closed.';

  @override
  String get testNotifyEnabledLabel => 'Enable 1-minute test notifications';

  @override
  String get testNotifyHint =>
      'This is best-effort. Android may delay background work.';

  @override
  String get exactAlarmPermissionRequired =>
      'Enable exact alarms permission to run 1-minute tests.';

  @override
  String get testNotifyNowButton => 'Send test notification now';

  @override
  String get testNotifySent => 'Test notification sent.';

  @override
  String get testNotifyBody => 'Background test notification delivered.';

  @override
  String get testNotifyChannelName => 'Test notifications';

  @override
  String get testNotifyChannelDescription =>
      'Background test notification channel';

  @override
  String get tributeTitle => 'Tribute';

  @override
  String get tributeSubtitle => 'A note of thanks to the original creator.';

  @override
  String get tributeHeadline => 'Tribute & Note';

  @override
  String get tributeBody1 =>
      'Thanks to a senior who built a smoother academic tool and helped many students.';

  @override
  String get tributeBody2 =>
      'This app continues that inspiration and does not diminish the original contribution.';

  @override
  String get tributeBody3 =>
      'If that work helped you, please keep respect and kindness toward the original author.';

  @override
  String get tributeBody4 => 'May more students build to serve and share.';

  @override
  String get tributeContinue => 'Continue to Home';

  @override
  String get tributePromptTitle => 'Login reminder';

  @override
  String get tributePromptSubtitle =>
      'Show the tribute page once after a successful login.';

  @override
  String get tributePromptEnabledLabel => 'Show tribute after login';

  @override
  String get tributeHomeCardTitle => 'Home tribute entry';

  @override
  String get tributeHomeCardSubtitle =>
      'Control whether the tribute entry is shown on Home.';

  @override
  String get tributeHomeCardEnabledLabel => 'Show tribute on Home';
}
