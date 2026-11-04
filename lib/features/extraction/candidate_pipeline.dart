import '../../data/candidate_mapper.dart';
import '../../data/database.dart';
import '../review/review_notifications.dart';
import 'extraction_service.dart';

/// 텍스트 입력 → 추출 → 후보 저장 → 확인 알림. 모든 캡처 소스가 공유하는 진입점.
///
/// 3단계(알림/SMS 수집)와 4단계(통화 녹음 STT)는 이 클래스의 [run] 만 호출하면 된다.
class CandidatePipeline {
  const CandidatePipeline({
    required this.extraction,
    required this.db,
    required this.notifications,
  });

  final ExtractionService extraction;
  final AppDatabase db;
  final ReviewNotifications notifications;

  Future<ExtractionResult> run(
    String text, {
    required String sourceApp,
    bool notify = true,
  }) async {
    final result = await extraction.extract(text, sourceApp: sourceApp);
    final createdAt = DateTime.now();
    for (final candidate in result.candidates) {
      await db.upsertCandidate(candidate.toCompanion(createdAt: createdAt));
      if (notify) await notifications.showForCandidate(candidate);
    }
    return result;
  }
}
