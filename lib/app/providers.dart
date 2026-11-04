import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/privacy/audit_sink.dart';
import '../core/privacy/network_policy.dart';
import '../core/privacy/policy_http_client.dart';
import '../data/candidate_mapper.dart';
import '../data/database.dart';
import '../features/calendar/calendar_repository.dart';
import '../features/extraction/candidate_pipeline.dart';
import '../features/extraction/extraction_service.dart';
import '../features/extraction/gemini_extractor.dart';
import '../features/review/review_notifications.dart';
import '../features/settings/settings_repository.dart';

part 'providers.g.dart';

// ---------------------------------------------------------------------------
// 인프라
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) => const FlutterSecureStorage();

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SettingsRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(secureStorageProvider),
);

// ---------------------------------------------------------------------------
// 프라이버시 레이어: 앱 전체에서 유일한 HTTP 클라이언트
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
NetworkPolicy networkPolicy(Ref ref) => const NetworkPolicy();

@Riverpod(keepAlive: true)
AuditSink auditSink(Ref ref) => DriftAuditSink(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
http.Client policyHttpClient(Ref ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  final client = PolicyHttpClient(
    policy: ref.watch(networkPolicyProvider),
    auditSink: ref.watch(auditSinkProvider),
    isExternalTransferEnabled: () => settings.externalTransferEnabled,
  );
  ref.onDispose(client.close);
  return client;
}

// ---------------------------------------------------------------------------
// 추출 / 캘린더 / 알림
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
ExtractionService extractionService(Ref ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  final client = ref.watch(policyHttpClientProvider);

  Future<GeminiExtractor?> geminiProvider() async {
    if (!settings.externalTransferEnabled) return null;
    final apiKey = await settings.readGeminiApiKey();
    if (apiKey == null) return null;
    return GeminiExtractor(
      apiKey: apiKey,
      httpClient: client,
      modelName: await settings.readGeminiModel(),
    );
  }

  return ExtractionService(geminiProvider: geminiProvider);
}

@Riverpod(keepAlive: true)
CandidatePipeline candidatePipeline(Ref ref) => CandidatePipeline(
  extraction: ref.watch(extractionServiceProvider),
  db: ref.watch(appDatabaseProvider),
  notifications: ref.watch(reviewNotificationsProvider),
);

@Riverpod(keepAlive: true)
CalendarRepository calendarRepository(Ref ref) => CalendarRepository();

@Riverpod(keepAlive: true)
ReviewNotifications reviewNotifications(Ref ref) => ReviewNotifications();

// ---------------------------------------------------------------------------
// 화면에서 구독하는 스트림/퓨처
// ---------------------------------------------------------------------------

@riverpod
Stream<bool> externalTransferEnabled(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watchExternalTransferEnabled();

@riverpod
Stream<String> geminiModel(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watchGeminiModel();

@riverpod
Future<String?> geminiApiKey(Ref ref) =>
    ref.watch(settingsRepositoryProvider).readGeminiApiKey();

@riverpod
Stream<List<CandidateRecord>> candidateList(Ref ref) => ref
    .watch(appDatabaseProvider)
    .watchCandidates()
    .map((rows) => [for (final r in rows) r.toRecord()]);

@riverpod
Future<CandidateRecord?> candidateById(Ref ref, String id) async {
  final row = await ref.watch(appDatabaseProvider).getCandidate(id);
  return row?.toRecord();
}

@riverpod
Stream<List<AuditEntry>> recentAuditLog(Ref ref) => ref
    .watch(appDatabaseProvider)
    .watchRecentAudit()
    .map((rows) => [for (final r in rows) r.toEntry()]);

@riverpod
Future<List<DeviceCalendar>> writableCalendars(Ref ref) =>
    ref.watch(calendarRepositoryProvider).listWritableCalendars();
