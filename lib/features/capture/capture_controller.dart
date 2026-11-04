import '../../core/pigeon/capture_api.g.dart';
import '../settings/settings_repository.dart';
import 'capture_settings.dart';
import 'capture_sources.dart';

/// 설정 화면과 네이티브 수집기 사이의 접착제.
///
/// 설정의 원본은 drift(`SettingsRepository`)다. 값이 바뀔 때마다 Pigeon 으로 네이티브
/// `CapturePrefs` 에 복사하고, 마스터 스위치에 따라 Foreground Service 를 켜고 끈다.
class CaptureController {
  const CaptureController({required this.settings, required this.hostApi});

  final SettingsRepository settings;
  final CaptureHostApi hostApi;

  /// 앱 시작 시 한 번: 저장된 설정을 네이티브에 다시 밀어 넣는다 (앱 업데이트·데이터 복원 대비).
  Future<void> syncToNative() async {
    final current = await settings.readCaptureSettings();
    await hostApi.setCaptureConfig(current.toConfig());
  }

  Future<void> update(CaptureSettings next) async {
    await settings.writeCaptureSettings(next);
    await hostApi.setCaptureConfig(next.toConfig());
  }

  Future<void> setCaptureEnabled(bool enabled) async => update(
    (await settings.readCaptureSettings()).copyWith(captureEnabled: enabled),
  );

  Future<void> setNotificationsEnabled(bool enabled) async => update(
    (await settings.readCaptureSettings()).copyWith(
      notificationsEnabled: enabled,
    ),
  );

  Future<void> setSmsEnabled(bool enabled) async => update(
    (await settings.readCaptureSettings()).copyWith(smsEnabled: enabled),
  );

  /// 패키지를 허용 목록에 추가한다. 형식이 틀리면 false.
  Future<bool> addPackage(String raw) async {
    final normalized = CaptureSources.normalizePackage(raw);
    if (normalized == null) return false;
    final current = await settings.readCaptureSettings();
    if (current.isPackageAllowed(normalized)) return true;
    await update(
      current.copyWith(
        allowedPackages: [...current.allowedPackages, normalized],
      ),
    );
    return true;
  }

  Future<void> removePackage(String packageName) async {
    final current = await settings.readCaptureSettings();
    await update(
      current.copyWith(
        allowedPackages: [
          for (final p in current.allowedPackages)
            if (p != packageName) p,
        ],
      ),
    );
  }

  Future<void> restoreDefaultPackages() async {
    final current = await settings.readCaptureSettings();
    await update(
      current.copyWith(allowedPackages: CaptureSources.defaultAllowedPackages),
    );
  }

  Future<CaptureStatus> status() => hostApi.getStatus();

  Future<void> openNotificationListenerSettings() =>
      hostApi.openNotificationListenerSettings();

  Future<void> openBatteryOptimizationSettings() =>
      hostApi.openBatteryOptimizationSettings();

  Future<bool> requestSmsPermission() => hostApi.requestSmsPermission();
}
