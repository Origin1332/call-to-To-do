import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../extraction/models/schedule_candidate.dart';

/// 일정 후보 확인을 재촉하는 고우선순위 알림.
///
/// 알림을 탭하면(또는 잠금 화면에서 전체화면 인텐트로) Review 화면이 열린다.
/// payload 는 후보 ID 다.
class ReviewNotifications {
  ReviewNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'schedule_review';
  static const String channelName = '일정 확인';
  static const String channelDescription = '추출된 일정을 확인·수정·취소하는 알림';

  static final DateFormat _timeFormat = DateFormat('M월 d일 (E) HH:mm', 'ko_KR');
  static final DateFormat _dayFormat = DateFormat('M월 d일 (E)', 'ko_KR');

  /// [onSelect] 는 사용자가 알림을 탭했을 때 후보 ID 와 함께 호출된다.
  Future<void> init({required void Function(String candidateId) onSelect}) {
    return _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final id = response.payload;
        if (id != null && id.isNotEmpty) onSelect(id);
      },
    );
  }

  /// 앱이 알림 탭으로 시작됐다면 그 후보 ID 를 돌려준다.
  Future<String?> launchCandidateId() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    final payload = details?.notificationResponse?.payload;
    return payload == null || payload.isEmpty ? null : payload;
  }

  /// Android 13+ 알림 권한과 14+ 전체화면 인텐트 권한을 요청한다.
  Future<void> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    await android.requestNotificationsPermission();
    await android.requestFullScreenIntentPermission();
  }

  Future<void> showForCandidate(ScheduleCandidate candidate) {
    final when = candidate.allDay
        ? _dayFormat.format(candidate.start)
        : _timeFormat.format(candidate.start);
    final recurring = candidate.isRecurring ? ' · 반복' : '';

    return _plugin.show(
      id: notificationId(candidate.id),
      title: '일정 확인: ${candidate.title}',
      body: '$when$recurring — 탭해서 확인/수정/취소',
      payload: candidate.id,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.event,
          fullScreenIntent: true,
          autoCancel: true,
        ),
      ),
    );
  }

  Future<void> cancelForCandidate(String candidateId) =>
      _plugin.cancel(id: notificationId(candidateId));

  static int notificationId(String candidateId) =>
      candidateId.hashCode & 0x7fffffff;
}
