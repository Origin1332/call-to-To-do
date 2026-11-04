import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/providers.dart';
import '../../core/pigeon/capture_api.g.dart';
import 'capture_controller.dart';
import 'capture_log_entry.dart';
import 'capture_service.dart';
import 'capture_settings.dart';

part 'capture_providers.g.dart';

@Riverpod(keepAlive: true)
CaptureHostApi captureHostApi(Ref ref) => CaptureHostApi();

/// 네이티브에서 온 메시지를 처리하는 서비스. UI 엔진과 백그라운드 엔진 양쪽 컨테이너에서 쓴다.
@Riverpod(keepAlive: true)
CaptureService captureService(Ref ref) => CaptureService(
  db: ref.watch(appDatabaseProvider),
  pipeline: CandidatePipelineRunner(ref.watch(candidatePipelineProvider)),
  readSettings: ref.watch(settingsRepositoryProvider).readCaptureSettings,
);

@Riverpod(keepAlive: true)
CaptureController captureController(Ref ref) => CaptureController(
  settings: ref.watch(settingsRepositoryProvider),
  hostApi: ref.watch(captureHostApiProvider),
);

@riverpod
Stream<CaptureSettings> captureSettings(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watchCaptureSettings();

/// 권한·서비스 상태. 시스템 설정에서 돌아오면 `ref.invalidate` 로 다시 읽는다.
@riverpod
Future<CaptureStatus> captureStatus(Ref ref) =>
    ref.watch(captureControllerProvider).status();

@riverpod
Stream<List<CaptureLogEntry>> captureLog(Ref ref) => ref
    .watch(appDatabaseProvider)
    .watchRecentCaptureLog()
    .map((rows) => [for (final r in rows) r.toEntry()]);
