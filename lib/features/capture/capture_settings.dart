import 'dart:convert';

import '../../core/pigeon/capture_api.g.dart';
import 'capture_sources.dart';

/// 수집 설정. drift `settings` 테이블에 키별로 저장되고, 바뀔 때마다 네이티브
/// `CapturePrefs` 로 복사된다 ([toConfig]).
class CaptureSettings {
  const CaptureSettings({
    this.captureEnabled = false,
    this.notificationsEnabled = true,
    this.smsEnabled = true,
    this.allowedPackages = CaptureSources.defaultAllowedPackages,
  });

  /// 마스터 스위치. 켜면 Foreground Service 가 돌고 부팅 후에도 재시작된다.
  final bool captureEnabled;

  /// NotificationListener 로 받은 알림을 처리할지.
  final bool notificationsEnabled;

  /// SMS 수신함 옵저버를 쓸지 (READ_SMS 필요).
  final bool smsEnabled;

  /// 알림을 읽을 패키지. 비어 있으면 아무 알림도 처리하지 않는다.
  final List<String> allowedPackages;

  static const String captureEnabledKey = 'capture_enabled';
  static const String notificationsEnabledKey = 'capture_notifications_enabled';
  static const String smsEnabledKey = 'capture_sms_enabled';
  static const String allowedPackagesKey = 'capture_allowed_packages';

  static const Set<String> keys = {
    captureEnabledKey,
    notificationsEnabledKey,
    smsEnabledKey,
    allowedPackagesKey,
  };

  /// `settings` 테이블의 키-값 맵으로부터 복원한다. 없는 키는 기본값.
  factory CaptureSettings.fromMap(Map<String, String?> map) {
    const defaults = CaptureSettings();
    return CaptureSettings(
      captureEnabled: _parseBool(
        map[captureEnabledKey],
        fallback: defaults.captureEnabled,
      ),
      notificationsEnabled: _parseBool(
        map[notificationsEnabledKey],
        fallback: defaults.notificationsEnabled,
      ),
      smsEnabled: _parseBool(map[smsEnabledKey], fallback: defaults.smsEnabled),
      allowedPackages: decodePackages(map[allowedPackagesKey]),
    );
  }

  Map<String, String> toMap() => {
    captureEnabledKey: captureEnabled.toString(),
    notificationsEnabledKey: notificationsEnabled.toString(),
    smsEnabledKey: smsEnabled.toString(),
    allowedPackagesKey: encodePackages(allowedPackages),
  };

  CaptureSettings copyWith({
    bool? captureEnabled,
    bool? notificationsEnabled,
    bool? smsEnabled,
    List<String>? allowedPackages,
  }) {
    return CaptureSettings(
      captureEnabled: captureEnabled ?? this.captureEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      allowedPackages: allowedPackages ?? this.allowedPackages,
    );
  }

  bool isPackageAllowed(String packageName) =>
      allowedPackages.contains(packageName);

  /// 네이티브 쪽으로 넘길 Pigeon 구조체.
  CaptureConfig toConfig() => CaptureConfig(
    captureEnabled: captureEnabled,
    notificationsEnabled: notificationsEnabled,
    smsEnabled: smsEnabled,
    allowedPackages: List.of(allowedPackages),
  );

  /// JSON 배열 문자열 → 패키지 목록. 값이 없거나 깨졌으면 기본 목록.
  static List<String> decodePackages(String? raw) {
    if (raw == null) return CaptureSources.defaultAllowedPackages;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return CaptureSources.defaultAllowedPackages;
      final packages = <String>[];
      for (final item in decoded) {
        final normalized = item is String
            ? CaptureSources.normalizePackage(item)
            : null;
        if (normalized != null && !packages.contains(normalized)) {
          packages.add(normalized);
        }
      }
      return packages;
    } on FormatException {
      return CaptureSources.defaultAllowedPackages;
    }
  }

  static String encodePackages(List<String> packages) => jsonEncode(packages);

  static bool _parseBool(String? raw, {required bool fallback}) =>
      switch (raw) {
        'true' => true,
        'false' => false,
        _ => fallback,
      };

  @override
  bool operator ==(Object other) =>
      other is CaptureSettings &&
      other.captureEnabled == captureEnabled &&
      other.notificationsEnabled == notificationsEnabled &&
      other.smsEnabled == smsEnabled &&
      _listEquals(other.allowedPackages, allowedPackages);

  @override
  int get hashCode => Object.hash(
    captureEnabled,
    notificationsEnabled,
    smsEnabled,
    Object.hashAll(allowedPackages),
  );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'CaptureSettings(capture=$captureEnabled, notifications=$notificationsEnabled, '
      'sms=$smsEnabled, packages=$allowedPackages)';
}
