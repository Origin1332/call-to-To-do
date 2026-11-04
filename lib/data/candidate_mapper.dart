import 'package:drift/drift.dart';

import '../core/privacy/audit_sink.dart';
import '../features/extraction/models/schedule_candidate.dart';
import 'database.dart';

/// 검토 상태 값. drift 컬럼은 문자열이므로 여기서 상수로 고정한다.
abstract final class CandidateStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
}

/// 후보 + 검토 상태. drift 행(`Candidate`)을 화면/프로바이더에 직접 노출하지 않기
/// 위한 도메인 레코드다.
class CandidateRecord {
  const CandidateRecord({
    required this.candidate,
    required this.status,
    required this.createdAt,
    this.calendarEventId,
  });

  final ScheduleCandidate candidate;
  final String status;
  final DateTime createdAt;
  final String? calendarEventId;

  bool get isPending => status == CandidateStatus.pending;
}

extension ScheduleCandidateToRow on ScheduleCandidate {
  CandidatesCompanion toCompanion({DateTime? createdAt}) {
    return CandidatesCompanion.insert(
      id: id,
      title: title,
      start: start,
      end: end,
      allDay: Value(allDay),
      recurrence: Value(recurrence),
      details: Value(details),
      sourceText: sourceText,
      sourceApp: sourceApp,
      extractor: extractor.name,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension CandidateRowToModel on Candidate {
  CandidateRecord toRecord() => CandidateRecord(
    candidate: toModel(),
    status: status,
    createdAt: createdAt,
    calendarEventId: calendarEventId,
  );

  ScheduleCandidate toModel() {
    return ScheduleCandidate(
      id: id,
      title: title,
      start: start,
      end: end,
      allDay: allDay,
      recurrence: recurrence,
      details: details,
      sourceText: sourceText,
      sourceApp: sourceApp,
      extractor: ExtractorKind.values.firstWhere(
        (k) => k.name == extractor,
        orElse: () => ExtractorKind.rule,
      ),
    );
  }
}

extension AuditRowToEntry on AuditLogData {
  AuditEntry toEntry() => AuditEntry(
    timestamp: timestamp,
    host: host,
    method: method,
    allowed: allowed,
    requestBytes: requestBytes,
    reason: reason,
  );
}
