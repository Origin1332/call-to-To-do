import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [AuditLog, Candidates, Settings, CaptureLog])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 테스트용: 메모리 DB 등 임의의 실행기를 주입한다.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(captureLog);
    },
  );

  /// UI 엔진과 백그라운드(헤드리스) 수집 엔진이 같은 파일을 쓰므로 한 isolate 가
  /// 서버가 되어 연결을 공유한다. 덕분에 백그라운드에서 넣은 후보가 열려 있는 화면에도 바로 반영된다.
  static QueryExecutor _openConnection() => driftDatabase(
    name: 'call_to_todo',
    native: const DriftNativeOptions(shareAcrossIsolates: true),
  );

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

  // ---- capture_log --------------------------------------------------------

  Future<void> insertCaptureLog(CaptureLogCompanion row) =>
      into(captureLog).insert(row);

  Stream<List<CaptureLogData>> watchRecentCaptureLog({int limit = 100}) {
    return (select(captureLog)
          ..orderBy([
            (t) => OrderingTerm.desc(t.processedAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limit))
        .watch();
  }

  /// [since] 이후에 같은 중복 키로 처리된(중복 아닌) 기록이 있으면 true.
  Future<bool> hasRecentCapture(String dedupeKey, DateTime since) async {
    final row =
        await (select(captureLog)
              ..where(
                (t) =>
                    t.dedupeKey.equals(dedupeKey) &
                    t.processedAt.isBiggerOrEqualValue(since) &
                    t.status.equals('duplicate').not(),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<int> deleteCaptureLogBefore(DateTime cutoff) => (delete(
    captureLog,
  )..where((t) => t.processedAt.isSmallerThanValue(cutoff))).go();

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

  /// 여러 키를 한 번에 구독한다. 없는 키는 맵에 들어가지 않는다.
  Stream<Map<String, String?>> watchSettings(Set<String> keys) {
    return (select(settings)..where((t) => t.key.isIn(keys))).watch().map(
      (rows) => {for (final row in rows) row.key: row.value},
    );
  }

  Future<void> writeSetting(String key, String value) => into(settings)
      .insertOnConflictUpdate(
        SettingsCompanion(key: Value(key), value: Value(value)),
      );
}
