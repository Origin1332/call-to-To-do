import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [AuditLog, Candidates, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 테스트용: 메모리 DB 등 임의의 실행기를 주입한다.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'call_to_todo');

  // ---- audit_log --------------------------------------------------------

  Future<void> insertAudit(AuditLogCompanion entry) =>
      into(auditLog).insert(entry);

  Stream<List<AuditLogData>> watchRecentAudit({int limit = 50}) {
    return (select(auditLog)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .watch();
  }

  // ---- candidates ---------------------------------------------------------

  Future<void> upsertCandidate(CandidatesCompanion row) =>
      into(candidates).insertOnConflictUpdate(row);

  Future<Candidate?> getCandidate(String id) =>
      (select(candidates)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Candidate>> watchCandidates() {
    return (select(
      candidates,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<void> updateCandidateStatus(
    String id,
    String status, {
    String? calendarEventId,
  }) {
    return (update(candidates)..where((t) => t.id.equals(id))).write(
      CandidatesCompanion(
        status: Value(status),
        calendarEventId: Value(calendarEventId),
      ),
    );
  }

  // ---- settings -----------------------------------------------------------

  Future<String?> readSetting(String key) async {
    final row = await (select(
      settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> watchSetting(String key) {
    return (select(settings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<void> writeSetting(String key, String value) => into(settings)
      .insertOnConflictUpdate(
        SettingsCompanion(key: Value(key), value: Value(value)),
      );
}
