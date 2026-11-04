import 'package:call_to_todo/data/database.dart';
import 'package:call_to_todo/features/capture/capture_settings.dart';
import 'package:call_to_todo/features/capture/capture_sources.dart';
import 'package:call_to_todo/features/settings/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('CaptureSettings', () {
    test('기본값: 수집 꺼짐, 두 소스 켜짐, 기본 허용 앱 6개', () {
      const s = CaptureSettings();
      expect(s.captureEnabled, isFalse);
      expect(s.notificationsEnabled, isTrue);
      expect(s.smsEnabled, isTrue);
      expect(s.allowedPackages, [
        'com.kakao.talk',
        'com.google.android.apps.messaging',
        'com.samsung.android.messaging',
        'com.skt.prod.dialer',
        'com.android.dialer',
        'com.samsung.android.dialer',
      ]);
    });

    test('toMap/fromMap 왕복', () {
      const s = CaptureSettings(
        captureEnabled: true,
        notificationsEnabled: false,
        smsEnabled: true,
        allowedPackages: ['com.kakao.talk', 'com.example.app'],
      );
      expect(CaptureSettings.fromMap(s.toMap()), s);
      expect(
        s.toMap()[CaptureSettings.allowedPackagesKey],
        '["com.kakao.talk","com.example.app"]',
      );
    });

    test('없는 키·깨진 값은 기본값으로', () {
      final s = CaptureSettings.fromMap({
        CaptureSettings.captureEnabledKey: 'maybe',
        CaptureSettings.allowedPackagesKey: 'not json',
      });
      expect(s, const CaptureSettings());
      expect(
        CaptureSettings.decodePackages('{"a":1}'),
        CaptureSources.defaultAllowedPackages,
      );
    });

    test('decodePackages 는 형식이 틀린 항목과 중복을 버린다', () {
      expect(
        CaptureSettings.decodePackages(
          '["com.kakao.talk"," COM.Kakao.Talk ","bad package",42,"com.x.y"]',
        ),
        ['com.kakao.talk', 'com.x.y'],
      );
      expect(CaptureSettings.decodePackages('[]'), isEmpty);
    });

    test('toConfig 는 네이티브 구조체에 값을 그대로 옮긴다', () {
      const s = CaptureSettings(
        captureEnabled: true,
        smsEnabled: false,
        allowedPackages: ['com.kakao.talk'],
      );
      final c = s.toConfig();
      expect(c.captureEnabled, isTrue);
      expect(c.notificationsEnabled, isTrue);
      expect(c.smsEnabled, isFalse);
      expect(c.allowedPackages, ['com.kakao.talk']);
    });
  });

  group('CaptureSources', () {
    test('파이프라인 라벨', () {
      expect(CaptureSources.pipelineLabel('com.kakao.talk'), 'kakao');
      expect(
        CaptureSources.pipelineLabel('com.google.android.apps.messaging'),
        'sms',
      );
      expect(
        CaptureSources.pipelineLabel('com.samsung.android.messaging'),
        'sms',
      );
      expect(CaptureSources.pipelineLabel('sms'), 'sms');
      expect(CaptureSources.pipelineLabel('com.skt.prod.dialer'), 'dialer');
      expect(CaptureSources.pipelineLabel('com.android.dialer'), 'dialer');
      expect(
        CaptureSources.pipelineLabel('com.samsung.android.dialer'),
        'dialer',
      );
      expect(
        CaptureSources.pipelineLabel('com.example.app'),
        'com.example.app',
      );
    });

    test('표시 이름', () {
      expect(CaptureSources.displayName('com.kakao.talk'), '카카오톡');
      expect(CaptureSources.displayName('sms'), 'SMS 수신함');
      expect(CaptureSources.displayName('com.foo.bar'), 'com.foo.bar');
    });

    test('normalizePackage', () {
      expect(
        CaptureSources.normalizePackage(' Com.Kakao.Talk '),
        'com.kakao.talk',
      );
      expect(
        CaptureSources.normalizePackage('com.android.shell'),
        'com.android.shell',
      );
      expect(CaptureSources.normalizePackage('kakao'), isNull);
      expect(CaptureSources.normalizePackage('com.kakao talk'), isNull);
      expect(CaptureSources.normalizePackage(''), isNull);
      expect(CaptureSources.normalizePackage('1com.kakao'), isNull);
    });
  });

  group('SettingsRepository 수집 설정', () {
    late AppDatabase db;
    late SettingsRepository repo;

    setUp(() {
      db = AppDatabase.withExecutor(NativeDatabase.memory());
      repo = SettingsRepository(db, MockSecureStorage());
    });

    tearDown(() => db.close());

    test('저장 전에는 기본값', () async {
      expect(await repo.readCaptureSettings(), const CaptureSettings());
    });

    test('쓰고 읽기, 스트림 반영', () async {
      const next = CaptureSettings(
        captureEnabled: true,
        notificationsEnabled: true,
        smsEnabled: false,
        allowedPackages: ['com.kakao.talk', 'com.android.shell'],
      );
      final emitted = <CaptureSettings>[];
      final subscription = repo.watchCaptureSettings().listen(emitted.add);
      await pumpEventQueue();

      await repo.writeCaptureSettings(next);
      await pumpEventQueue();
      expect(await repo.readCaptureSettings(), next);
      // 트랜잭션으로 쓰므로 중간 상태(일부 키만 바뀐 값)는 보이지 않는다.
      expect(emitted, [const CaptureSettings(), next]);
      await subscription.cancel();
    });

    test('다른 설정 키와 섞이지 않는다', () async {
      await repo.setExternalTransferEnabled(false);
      await repo.writeCaptureSettings(
        const CaptureSettings(captureEnabled: true),
      );
      await repo.load();
      expect(repo.externalTransferEnabled, isFalse);
      expect((await repo.readCaptureSettings()).captureEnabled, isTrue);
    });
  });
}
