import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'QFNU Student Portal'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'QFNU Exam Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your student account to check exam schedule.'**
  String get loginSubtitle;

  /// No description provided for @proxyUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Proxy URL (Web only)'**
  String get proxyUrlLabel;

  /// No description provided for @proxyUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http://localhost:8080'**
  String get proxyUrlHint;

  /// No description provided for @proxyUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Proxy URL is required for web testing.'**
  String get proxyUrlRequired;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @rememberAccount.
  ///
  /// In en, this message translates to:
  /// **'Remember account'**
  String get rememberAccount;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember password'**
  String get rememberPassword;

  /// No description provided for @captchaLabel.
  ///
  /// In en, this message translates to:
  /// **'Captcha'**
  String get captchaLabel;

  /// No description provided for @captchaHint.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh to load'**
  String get captchaHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @checkingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking session...'**
  String get checkingSession;

  /// No description provided for @fillCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in username, password, and captcha.'**
  String get fillCredentialsError;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get loginFailed;

  /// No description provided for @loadCaptchaFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load captcha: {error}'**
  String loadCaptchaFailed(Object error);

  /// No description provided for @failedToLoadTerms.
  ///
  /// In en, this message translates to:
  /// **'Failed to load terms: {error}'**
  String failedToLoadTerms(Object error);

  /// No description provided for @failedToLoadExams.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exams: {error}'**
  String failedToLoadExams(Object error);

  /// No description provided for @failedToLoadOptions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load options: {error}'**
  String failedToLoadOptions(Object error);

  /// No description provided for @failedToLoadGrades.
  ///
  /// In en, this message translates to:
  /// **'Failed to load grades: {error}'**
  String failedToLoadGrades(Object error);

  /// No description provided for @failedToLoadSchedule.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schedule: {error}'**
  String failedToLoadSchedule(Object error);

  /// No description provided for @failedToLoadTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Failed to load training plan: {error}'**
  String failedToLoadTrainingPlan(Object error);

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeUser(Object name);

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @examScheduleCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Schedule'**
  String get examScheduleCardTitle;

  /// No description provided for @examScheduleCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to view your upcoming exams'**
  String get examScheduleCardSubtitle;

  /// No description provided for @gradesCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Grades'**
  String get gradesCardTitle;

  /// No description provided for @gradesCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to view your grades'**
  String get gradesCardSubtitle;

  /// No description provided for @timetableCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetableCardTitle;

  /// No description provided for @timetableCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to view your schedule'**
  String get timetableCardSubtitle;

  /// No description provided for @trainingPlanCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Plan'**
  String get trainingPlanCardTitle;

  /// No description provided for @trainingPlanCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to view progress by curriculum group'**
  String get trainingPlanCardSubtitle;

  /// No description provided for @examScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Schedule'**
  String get examScheduleTitle;

  /// No description provided for @gradeQueryTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Grades'**
  String get gradeQueryTitle;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleTitle;

  /// No description provided for @trainingPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Plan'**
  String get trainingPlanTitle;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @query.
  ///
  /// In en, this message translates to:
  /// **'Query'**
  String get query;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @termLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get termLabel;

  /// No description provided for @courseTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Course Type'**
  String get courseTypeLabel;

  /// No description provided for @courseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseNameLabel;

  /// No description provided for @displayLabel.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displayLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @creditLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get creditLabel;

  /// No description provided for @gpaLabel.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gpaLabel;

  /// No description provided for @averageGpaLabel.
  ///
  /// In en, this message translates to:
  /// **'Average GPA'**
  String get averageGpaLabel;

  /// No description provided for @averageGpaValue.
  ///
  /// In en, this message translates to:
  /// **'Average GPA: {value}'**
  String averageGpaValue(Object value);

  /// No description provided for @currentTermLabel.
  ///
  /// In en, this message translates to:
  /// **'Current term'**
  String get currentTermLabel;

  /// No description provided for @allTerms.
  ///
  /// In en, this message translates to:
  /// **'All terms'**
  String get allTerms;

  /// No description provided for @allOption.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allOption;

  /// No description provided for @selectTerm.
  ///
  /// In en, this message translates to:
  /// **'Select term'**
  String get selectTerm;

  /// No description provided for @noTermOptions.
  ///
  /// In en, this message translates to:
  /// **'No term options available.'**
  String get noTermOptions;

  /// No description provided for @noTermOptionsFound.
  ///
  /// In en, this message translates to:
  /// **'No term options found.'**
  String get noTermOptionsFound;

  /// No description provided for @noExamData.
  ///
  /// In en, this message translates to:
  /// **'No exam data available.'**
  String get noExamData;

  /// No description provided for @noGradeData.
  ///
  /// In en, this message translates to:
  /// **'No grade data available.'**
  String get noGradeData;

  /// No description provided for @noClassesForDate.
  ///
  /// In en, this message translates to:
  /// **'No classes scheduled for this date.'**
  String get noClassesForDate;

  /// No description provided for @noTrainingPlanData.
  ///
  /// In en, this message translates to:
  /// **'No training plan data.'**
  String get noTrainingPlanData;

  /// No description provided for @loadingTrainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Loading training plan...'**
  String get loadingTrainingPlan;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @classPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Class period'**
  String get classPeriodLabel;

  /// No description provided for @untitledCourse.
  ///
  /// In en, this message translates to:
  /// **'Untitled course'**
  String get untitledCourse;

  /// No description provided for @completedRequired.
  ///
  /// In en, this message translates to:
  /// **'Completed {completed} / Required {required}'**
  String completedRequired(Object completed, Object required);

  /// No description provided for @totalHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Total hours: {hours}'**
  String totalHoursLabel(Object hours);

  /// No description provided for @coursesCount.
  ///
  /// In en, this message translates to:
  /// **'Courses: {count}'**
  String coursesCount(Object count);

  /// No description provided for @completedSection.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedSection;

  /// No description provided for @pendingSection.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingSection;

  /// No description provided for @noCompletedCourses.
  ///
  /// In en, this message translates to:
  /// **'No completed courses.'**
  String get noCompletedCourses;

  /// No description provided for @noPendingCourses.
  ///
  /// In en, this message translates to:
  /// **'No pending courses.'**
  String get noPendingCourses;

  /// No description provided for @attributeLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute: {value}'**
  String attributeLabel(Object value);

  /// No description provided for @creditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits: {value}'**
  String creditsLabel(Object value);

  /// No description provided for @termValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Term: {value}'**
  String termValueLabel(Object value);

  /// No description provided for @hoursValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours: {value}'**
  String hoursValueLabel(Object value);

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
