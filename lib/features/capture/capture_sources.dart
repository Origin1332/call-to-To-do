/// 수집 소스(패키지) 목록과 파이프라인용 출처 라벨.
abstract final class CaptureSources {
  /// Kotlin `CapturePrefs.DEFAULT_ALLOWED_PACKAGES` 와 같은 목록. 순서는 설정 화면 표시 순서.
  static const List<String> defaultAllowedPackages = [
    kakaoTalk,
    googleMessages,
    samsungMessages,
    sktDialer,
    androidDialer,
    samsungDialer,
  ];

  static const String kakaoTalk = 'com.kakao.talk';
  static const String googleMessages = 'com.google.android.apps.messaging';
  static const String samsungMessages = 'com.samsung.android.messaging';
  static const String sktDialer = 'com.skt.prod.dialer';
  static const String androidDialer = 'com.android.dialer';
  static const String samsungDialer = 'com.samsung.android.dialer';

  /// SMS ContentObserver 가 보내는 `sourceApp` 값 (Kotlin `SmsCaptureController.SOURCE_APP`).
  static const String smsObserverSourceApp = 'sms';

  /// 표시용 이름. 모르는 패키지는 패키지 이름 그대로.
  static String displayName(String packageName) => switch (packageName) {
    kakaoTalk => '카카오톡',
    googleMessages => 'Google 메시지',
    samsungMessages => '삼성 메시지',
    sktDialer => 'A. 전화 (T전화)',
    androidDialer => '기본 전화',
    samsungDialer => '삼성 전화',
    smsObserverSourceApp => 'SMS 수신함',
    _ => packageName,
  };

  /// `ScheduleCandidate.sourceApp` 에 들어가는 짧은 라벨.
  ///
  /// 같은 문자를 메시지 앱 알림과 SMS 옵저버 두 경로로 받는 경우를 하나의 라벨(`sms`)로
  /// 묶어, 중복 제거가 경로와 무관하게 동작하도록 한다.
  static String pipelineLabel(String sourceApp) => switch (sourceApp) {
    kakaoTalk => 'kakao',
    googleMessages || samsungMessages || smsObserverSourceApp => 'sms',
    sktDialer || androidDialer || samsungDialer => 'dialer',
    _ => sourceApp,
  };

  /// 설정 입력값을 패키지 이름으로 정리한다. 형식이 틀리면 null.
  static String? normalizePackage(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return null;
    final valid = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$');
    return valid.hasMatch(value) ? value : null;
  }
}
