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

  @override
  String get gradeNotifySectionTitle => '成绩提醒';

  @override
  String get gradeNotifySectionSubtitle => '后台定时检查新成绩并通知。';

  @override
  String get gradeNotifyEnabledLabel => '启用成绩提醒';

  @override
  String get gradeNotifyIntervalLabel => '检查间隔';

  @override
  String gradeNotifyIntervalValue(Object hours) {
    return '每 $hours 小时检查';
  }

  @override
  String get gradeNotifyTitle => '成绩有更新';

  @override
  String gradeNotifyBody(Object count) {
    return '发现 $count 条新成绩';
  }

  @override
  String get gradeNotifyChannelName => '成绩提醒';

  @override
  String get gradeNotifyChannelDescription => '当有新成绩发布时通知';

  @override
  String get notificationPermissionRequired => '需要开启通知权限才能接收成绩提醒。';

  @override
  String get cloudNotifyTitle => '云端成绩提醒';

  @override
  String get cloudNotifySubtitle => '即使关闭 App 也能接收成绩通知。';

  @override
  String get cloudNotifyEnabledLabel => '启用云端成绩提醒';

  @override
  String get cloudNotifyHint => '需要上传当前登录的会话 Cookie 到 Firebase。';

  @override
  String get cloudNotifyDialogTitle => '开启云端提醒？';

  @override
  String get cloudNotifyDialogBody =>
      '云端检查需要上传当前会话 Cookie。Cookie 可能过期，过期后需重新登录刷新。';

  @override
  String get cloudNotifyDialogConfirm => '开启';

  @override
  String get cloudNotifyRegisterSuccess => '云端提醒已开启。';

  @override
  String cloudNotifyRegisterFailed(Object error) {
    return '云端提醒开启失败：$error';
  }

  @override
  String get cloudNotifyLoginRequired => '请先登录再开启云端提醒。';

  @override
  String get developerTitle => '开发者';

  @override
  String get developerSubtitle => '高级测试工具';

  @override
  String get testNotifyTitle => '后台通知测试';

  @override
  String get testNotifySubtitle => '用于验证 App 关闭后是否仍能推送。';

  @override
  String get testNotifyEnabledLabel => '启用 1 分钟测试通知';

  @override
  String get testNotifyHint => '该测试为尽力而为，系统可能延迟执行。';

  @override
  String get exactAlarmPermissionRequired => '需要开启“精确闹钟”权限才能进行 1 分钟测试。';

  @override
  String get testNotifyNowButton => '立即发送测试通知';

  @override
  String get testNotifySent => '已发送测试通知。';

  @override
  String get testNotifyBody => '后台测试通知已发送。';

  @override
  String get testNotifyChannelName => '测试通知';

  @override
  String get testNotifyChannelDescription => '后台通知测试通道';
}
