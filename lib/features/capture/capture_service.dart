import 'package:drift/drift.dart';

import '../../core/pigeon/capture_api.g.dart';
import '../../data/database.dart';
import '../extraction/candidate_pipeline.dart';
import '../extraction/extraction_service.dart';
import 'capture_settings.dart';
import 'capture_sources.dart';
import 'message_deduper.dart';

/// 수집 로그 상태 값 (`capture_log.status`).
abstract final class CaptureStatusValues {
  static const String processed = 'processed';
  static const String duplicate = 'duplicate';
  static const String disabled = 'disabled';
  static const String empty = 'empty';
  static const String error = 'error';
}

/// [CandidatePipeline.run] 호출만 떼어 낸 인터페이스 (테스트에서 가짜로 대체).
abstract interface class PipelineRunner {
  Future<ExtractionResult> run(String text, {required String sourceApp});
}

class CandidatePipelineRunner implements PipelineRunner {
  const CandidatePipelineRunner(this._pipeline);

  final CandidatePipeline _pipeline;

  @override
  Future<ExtractionResult> run(String text, {required String sourceApp}) =>
      _pipeline.run(text, sourceApp: sourceApp);
}

/// 네이티브 수집기에서 온 [CapturedMessage] 하나를 처리한다.
///
/// 순서: 설정 확인(소스 on/off·허용 앱) → 중복 제거(메모리 + `capture_log`) →
/// [CandidatePipeline] (규칙 파서 → 프리필터 → Gemini(설정 시) → 후보 저장 → 확인 알림)
/// → 수집 로그 기록. 로그에는 본문이 들어가지 않는다.
class CaptureService {
  CaptureService({
    required this.db,
    required this.pipeline,
    required this.readSettings,
    MessageDeduper? deduper,
    this.dedupeWindow = const Duration(minutes: 10),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       deduper = deduper ?? MessageDeduper(clock: clock);

  final AppDatabase db;
  final PipelineRunner pipeline;
  final Future<CaptureSettings> Function() readSettings;
  final MessageDeduper deduper;
  final Duration dedupeWindow;
  final DateTime Function() _clock;

  Future<CaptureProcessResult> process(CapturedMessage message) async {
    final settings = await readSettings();
    final messageAt = DateTime.fromMillisecondsSinceEpoch(
      message.timestampMillis,
    );

    if (!_isSourceEnabled(settings, message)) {
      return _finish(
        message,
        messageAt,
        status: CaptureStatusValues.disabled,
        dedupeKey: MessageDeduper.messageKey(
          message.sourceApp,
          MessageDeduper.splitLines(message.text),
        ),
      );
    }

    final newLines = deduper.takeNewLines(message);
    if (newLines.isEmpty) {
      return _finish(
        message,
        messageAt,
        status: CaptureStatusValues.duplicate,
        dedupeKey: MessageDeduper.messageKey(
          message.sourceApp,
          MessageDeduper.splitLines(message.text),
        ),
      );
    }

    final dedupeKey = MessageDeduper.messageKey(message.sourceApp, newLines);
    final since = _clock().subtract(dedupeWindow);
    if (await db.hasRecentCapture(dedupeKey, since)) {
      return _finish(
        message,
        messageAt,
        status: CaptureStatusValues.duplicate,
        dedupeKey: dedupeKey,
      );
    }

    final text = buildPipelineText(newLines);
    if (text.isEmpty) {
      return _finish(
        message,
        messageAt,
        status: CaptureStatusValues.empty,
        dedupeKey: dedupeKey,
      );
    }

    try {
      final result = await pipeline.run(
        text,
        sourceApp: CaptureSources.pipelineLabel(message.sourceApp),
      );
      return await _finish(
        message,
        messageAt,
        status: CaptureStatusValues.processed,
        dedupeKey: dedupeKey,
        candidateIds: [for (final c in result.candidates) c.id],
        textLength: text.length,
      );
    } on Exception catch (e) {
      return _finish(
        message,
        messageAt,
        status: CaptureStatusValues.error,
        dedupeKey: dedupeKey,
        textLength: text.length,
        error: e.toString(),
      );
    }
  }

  /// 파이프라인에 넘길 텍스트: 새 줄들을 줄바꿈으로 잇는다. 규칙 파서는 줄바꿈을 문장
  /// 경계로 보므로 메시지 사이 경계가 그대로 보존된다.
  static String buildPipelineText(List<String> lines) =>
      lines.join('\n').trim();

  bool _isSourceEnabled(CaptureSettings settings, CapturedMessage message) {
    if (!settings.captureEnabled) return false;
    return switch (message.source) {
      CaptureSource.sms => settings.smsEnabled,
      CaptureSource.notification =>
        settings.notificationsEnabled &&
            settings.isPackageAllowed(message.sourceApp),
    };
  }

  Future<CaptureProcessResult> _finish(
    CapturedMessage message,
    DateTime messageAt, {
    required String status,
    required String dedupeKey,
    List<String> candidateIds = const [],
    int textLength = 0,
    String? error,
  }) async {
    await db.insertCaptureLog(
      CaptureLogCompanion.insert(
        source: message.source.name,
        sourceApp: message.sourceApp,
        messageAt: messageAt,
        processedAt: _clock(),
        status: status,
        candidateCount: Value(candidateIds.length),
        candidateIds: Value(
          candidateIds.isEmpty ? null : candidateIds.join(','),
        ),
        textLength: Value(textLength),
        dedupeKey: dedupeKey,
      ),
    );
    return CaptureProcessResult(
      candidateCount: candidateIds.length,
      status: status,
      error: error,
    );
  }
}
