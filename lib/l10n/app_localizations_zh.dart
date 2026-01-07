// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'QFNU教务';

  @override
  String get loginTitle => 'QFNU教务登录';

  @override
  String get loginSubtitle => '登录后查看考试、成绩、课表与培养方案。';

  @override
  String get proxyUrlLabel => '代理地址（仅 Web）';

  @override
  String get proxyUrlHint => 'http://localhost:8080';

  @override
  String get proxyUrlRequired => 'Web 调试需要填写代理地址。';

  @override
  String get usernameLabel => '账号';

  @override
  String get passwordLabel => '密码';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get rememberAccount => '记住账号';

  @override
  String get rememberPassword => '记住密码';

  @override
  String get captchaLabel => '验证码';

  @override
  String get captchaHint => '点击刷新获取';

  @override
  String get loginButton => '登录';

  @override
  String get checkingSession => '正在检查会话...';

  @override
  String get fillCredentialsError => '请填写账号、密码和验证码。';

  @override
  String get loginFailed => '登录失败。';

  @override
  String loadCaptchaFailed(Object error) {
    return '验证码加载失败：$error';
  }

  @override
  String failedToLoadTerms(Object error) {
    return '加载学期失败：$error';
  }

  @override
  String failedToLoadExams(Object error) {
    return '加载考试失败：$error';
  }

  @override
  String failedToLoadOptions(Object error) {
    return '加载选项失败：$error';
  }

  @override
  String failedToLoadGrades(Object error) {
    return '加载成绩失败：$error';
  }

  @override
  String failedToLoadSchedule(Object error) {
    return '加载课表失败：$error';
  }

  @override
  String failedToLoadTrainingPlan(Object error) {
    return '加载培养方案失败：$error';
  }

  @override
  String get dashboardTitle => '首页';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String welcomeUser(Object name) {
    return '欢迎，$name';
  }

  @override
  String get logout => '退出登录';

  @override
  String get examScheduleCardTitle => '考试安排';

  @override
  String get examScheduleCardSubtitle => '查看你的考试安排';

  @override
  String get gradesCardTitle => '成绩查询';

  @override
  String get gradesCardSubtitle => '查看你的成绩';

  @override
  String get timetableCardTitle => '课表';

  @override
  String get timetableCardSubtitle => '查看课表';

  @override
  String get trainingPlanCardTitle => '培养方案';

  @override
  String get trainingPlanCardSubtitle => '查看课程体系进度';

  @override
  String get examScheduleTitle => '考试安排';

  @override
  String get gradeQueryTitle => '成绩查询';

  @override
  String get scheduleTitle => '课表';

  @override
  String get trainingPlanTitle => '培养方案';

  @override
  String get close => '关闭';

  @override
  String get cancel => '取消';

  @override
  String get apply => '应用';

  @override
  String get query => '查询';

  @override
  String get loading => '加载中';

  @override
  String get refresh => '刷新';

  @override
  String get reload => '重新加载';

  @override
  String get filters => '筛选';

  @override
  String get termLabel => '学期';

  @override
  String get courseTypeLabel => '课程类别';

  @override
  String get courseNameLabel => '课程名称';

  @override
  String get displayLabel => '显示方式';

  @override
  String get scoreLabel => '成绩';

  @override
  String get creditLabel => '学分';

  @override
  String get gpaLabel => '绩点';

  @override
  String get averageGpaLabel => '平均绩点';

  @override
  String averageGpaValue(Object value) {
    return '平均绩点：$value';
  }

  @override
  String get currentTermLabel => '当前学期';

  @override
  String get allTerms => '全部学期';

  @override
  String get allOption => '全部';

  @override
  String get selectTerm => '选择学期';

  @override
  String get noTermOptions => '暂无学期选项。';

  @override
  String get noTermOptionsFound => '未找到学期选项。';

  @override
  String get noExamData => '暂无考试数据。';

  @override
  String get noGradeData => '暂无成绩数据。';

  @override
  String get noClassesForDate => '该日期没有课程安排。';

  @override
  String get noTrainingPlanData => '暂无培养方案数据。';

  @override
  String get loadingTrainingPlan => '正在加载培养方案...';

  @override
  String get pickDate => '选择日期';

  @override
  String get classPeriodLabel => '节次';

  @override
  String get untitledCourse => '未命名课程';

  @override
  String completedRequired(Object completed, Object required) {
    return '已修 $completed / 应修 $required';
  }

  @override
  String totalHoursLabel(Object hours) {
    return '总学时：$hours';
  }

  @override
  String coursesCount(Object count) {
    return '课程数：$count';
  }

  @override
  String get completedSection => '已完成';

  @override
  String get pendingSection => '未完成';

  @override
  String get noCompletedCourses => '暂无已完成课程。';

  @override
  String get noPendingCourses => '暂无未完成课程。';

  @override
  String attributeLabel(Object value) {
    return '课程属性：$value';
  }

  @override
  String creditsLabel(Object value) {
    return '学分：$value';
  }

  @override
  String termValueLabel(Object value) {
    return '开设学期：$value';
  }

  @override
  String hoursValueLabel(Object value) {
    return '总学时：$value';
  }

  @override
  String get statusCompleted => '已完成';

  @override
  String get statusPending => '未完成';

  @override
  String get settingsTitle => '设置';

  @override
  String get trainingPlanCacheTitle => '培养方案缓存';

  @override
  String get trainingPlanCacheSubtitle => '缓存培养方案数据，按天数自动更新。';

  @override
  String get cacheDaysLabel => '更新间隔';

  @override
  String cacheDaysValue(Object days) {
    return '每 $days 天更新';
  }

  @override
  String get cacheClearButton => '清除培养方案缓存';

  @override
  String get cacheClearedMessage => '培养方案缓存已清除。';
}
