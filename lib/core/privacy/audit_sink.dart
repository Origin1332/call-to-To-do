import 'package:drift/drift.dart';

import '../../data/database.dart';

/// 외부 네트워크 시도 한 건의 기록. 본문은 포함하지 않는다.
class AuditEntry {
  const AuditEntry({
    required this.timestamp,
    required this.host,
    required this.method,
    required this.allowed,
    required this.requestBytes,
    this.reason,
  });

  final DateTime timestamp;
  final String host;
  final String method;
  final bool allowed;
  final int requestBytes;
  final String? reason;

  @override
  String toString() =>
      'AuditEntry($timestamp $method $host allowed=$allowed '
      'bytes=$requestBytes reason=$reason)';
}

abstract interface class AuditSink {
  Future<void> record(AuditEntry entry);
}

/// drift `audit_log` 테이블에 기록하는 기본 구현.
class DriftAuditSink implements AuditSink {
  const DriftAuditSink(this._db);

  final AppDatabase _db;

  @override
  Future<void> record(AuditEntry entry) {
    return _db.insertAudit(
      AuditLogCompanion.insert(
        timestamp: entry.timestamp,
        host: entry.host,
        method: entry.method,
        allowed: entry.allowed,
        reason: Value(entry.reason),
        requestBytes: Value(entry.requestBytes),
      ),
    );
  }
}

/// 테스트용: 메모리에 쌓아 두는 구현.
class InMemoryAuditSink implements AuditSink {
  final List<AuditEntry> entries = [];

  @override
  Future<void> record(AuditEntry entry) async => entries.add(entry);
}
