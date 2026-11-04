// Pigeon 정의: Dart ↔ Kotlin 메신저/SMS 수집 채널 (3단계).
//
// 생성:  dart run pigeon --input pigeons/capture_api.dart
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/pigeon/capture_api.g.dart',
    kotlinOut: 'android/app/src/main/kotlin/com/calltotodo/call_to_todo/CaptureApi.g.kt',
    // CalendarApi.g.kt 와 같은 패키지라 오류 클래스 이름이 겹치지 않게 바꾼다.
    kotlinOptions: KotlinOptions(
      package: 'com.calltotodo.call_to_todo',
      errorClassName: 'CaptureFlutterError',
    ),
    dartPackageName: 'call_to_todo',
  ),
)
library;

import 'package:pigeon/pigeon.dart';

/// 메시지가 어느 경로로 들어왔는지.
enum CaptureSource {
  /// NotificationListenerService 가 가로챈 알림.
  notification,

  /// `content://sms` ContentObserver 가 읽은 수신 SMS.
  sms,
}

/// 네이티브 수집기가 Dart 파이프라인으로 넘기는 메시지 하나.
///
/// 텍스트는 기기 밖으로 나가지 않는다. Dart 쪽에서 중복 제거 → 규칙 파서 →
/// 프리필터를 거친 조각만 (설정이 허용할 때) Gemini 로 전송된다.
class CapturedMessage {
  CapturedMessage({
    required this.sourceApp,
    required this.text,
    required this.timestampMillis,
    required this.source,
    this.sender,
  });

  /// 알림이면 패키지 이름(`com.kakao.talk`), SMS 옵저버면 `sms`.
  String sourceApp;

  /// 보낸 사람(대화방 이름·전화번호). 없을 수 있다.
  String? sender;

  /// 본문. MessagingStyle/InboxStyle 알림은 메시지 한 줄씩 `\n` 으로 이어 붙인다.
  String text;

  /// 알림 게시 시각 또는 SMS 수신 시각 (epoch millis).
  int timestampMillis;

  CaptureSource source;
}

/// Dart 가 메시지 하나를 처리한 결과. 네이티브 로그와 WorkManager 재시도 판단에 쓴다.
class CaptureProcessResult {
  CaptureProcessResult({
    required this.candidateCount,
    required this.status,
    this.error,
  });

  int candidateCount;

  /// `processed` | `duplicate` | `disabled` | `empty` | `error`
  String status;
  String? error;
}

/// 네이티브 수집기가 Dart 엔진 없이도 알아야 하는 설정.
/// Dart 의 설정 저장소가 원본이며, 바뀔 때마다 [CaptureHostApi.setCaptureConfig] 로 밀어 넣는다.
class CaptureConfig {
  CaptureConfig({
    required this.captureEnabled,
    required this.notificationsEnabled,
    required this.smsEnabled,
    required this.allowedPackages,
  });

  /// 마스터 스위치. 켜져 있으면 부팅 시 Foreground Service 를 다시 띄운다.
  bool captureEnabled;
  bool notificationsEnabled;
  bool smsEnabled;
  List<String> allowedPackages;
}

/// 수집 관련 권한·서비스 상태 묶음 (설정 화면 표시용).
class CaptureStatus {
  CaptureStatus({
    required this.notificationListenerEnabled,
    required this.smsPermissionGranted,
    required this.ignoringBatteryOptimizations,
    required this.serviceRunning,
  });

  bool notificationListenerEnabled;
  bool smsPermissionGranted;
  bool ignoringBatteryOptimizations;
  bool serviceRunning;
}

@HostApi()
abstract class CaptureHostApi {
  CaptureStatus getStatus();

  /// 네이티브 SharedPreferences 에 설정을 저장하고, 마스터 스위치에 따라
  /// Foreground Service 를 시작/중지한다.
  void setCaptureConfig(CaptureConfig config);

  /// 시스템 "알림 접근" 설정 화면을 연다.
  void openNotificationListenerSettings();

  /// 배터리 최적화 제외 요청 대화상자(또는 설정 화면)를 연다.
  void openBatteryOptimizationSettings();

  /// READ_SMS 런타임 권한 요청. 사용자가 응답하면 결과를 돌려준다.
  @async
  bool requestSmsPermission();

  /// 백그라운드 Dart 엔진이 [CaptureFlutterApi] 핸들러를 등록했음을 알린다.
  void signalDartReady();
}

@FlutterApi()
abstract class CaptureFlutterApi {
  /// 메시지 하나를 중복 제거 → 추출 파이프라인에 넣고 결과를 돌려준다.
  @async
  CaptureProcessResult processMessage(CapturedMessage message);
}
