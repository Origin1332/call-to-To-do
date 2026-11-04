import '../../data/database.dart';

/// `capture_log` 행의 도메인 표현. 본문은 애초에 저장되지 않으므로 여기에도 없다.
class CaptureLogEntry {
  const CaptureLogEntry({
    required this.id,
    required this.source,
    required this.sourceApp,
    required this.messageAt,
    required this.processedAt,
    required this.status,
    required this.candidateCount,
    required this.candidateIds,
    required this.textLength,
  });

  final int id;
  final String source;
  final String sourceApp;
  final DateTime messageAt;
  final DateTime processedAt;
  final String status;
  final int candidateCount;
  final List<String> candidateIds;
  final int textLength;

  bool get producedCandidate => candidateIds.isNotEmpty;
}

extension CaptureLogRowToEntry on CaptureLogData {
  CaptureLogEntry toEntry() => CaptureLogEntry(
    id: id,
    source: source,
    sourceApp: sourceApp,
    messageAt: messageAt,
    processedAt: processedAt,
    status: status,
    candidateCount: candidateCount,
    candidateIds: [
      for (final part in (candidateIds ?? '').split(','))
        if (part.trim().isNotEmpty) part.trim(),
    ],
    textLength: textLength,
  );
}
