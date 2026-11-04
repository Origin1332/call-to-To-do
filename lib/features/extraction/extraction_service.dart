import '../../core/korean_datetime_parser/korean_datetime_parser.dart';
import '../../core/privacy/policy_http_client.dart';
import 'gemini_extractor.dart';
import 'models/schedule_candidate.dart';
import 'prefilter.dart';
import 'rule_extractor.dart';

/// 추출 한 번의 결과와 어떤 경로를 탔는지에 대한 설명.
class ExtractionResult {
  const ExtractionResult({
    required this.candidates,
    required this.extractor,
    required this.sentChars,
    this.note,
  });

  final List<ScheduleCandidate> candidates;

  /// 실제로 후보를 만든 추출기.
  final ExtractorKind extractor;

  /// 외부로 전송된 글자 수 (규칙 파서만 썼으면 0).
  final int sentChars;

  /// 사용자에게 보여 줄 보조 설명 (예: Gemini 실패로 규칙 파서 사용).
  final String? note;
}

/// 텍스트 → 규칙 파서 → (프리필터 → Gemini | 규칙 추출기) → 후보.
///
/// Gemini 는 다음 조건이 모두 맞을 때만 호출된다.
/// 1. 규칙 파서가 일정 표현을 하나 이상 찾았다 (아니면 아무것도 전송하지 않음).
/// 2. 설정의 "외부 전송 끄기" 가 꺼져 있다 (= 외부 전송 허용).
/// 3. Gemini API 키가 저장되어 있다.
class ExtractionService {
  ExtractionService({
    required this.geminiProvider,
    this.parser = const KoreanDateTimeParser(),
    this.prefilter = const Prefilter(),
    this.ruleExtractor = const RuleExtractor(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final KoreanDateTimeParser parser;
  final Prefilter prefilter;
  final RuleExtractor ruleExtractor;

  /// 사용 가능한 Gemini 추출기를 돌려준다. 외부 전송이 꺼져 있거나 키가 없으면 null.
  final Future<GeminiExtractor?> Function() geminiProvider;
  final DateTime Function() _clock;

  Future<ExtractionResult> extract(
    String text, {
    required String sourceApp,
  }) async {
    final now = _clock();
    final schedules = parser.parse(text, now: now);
    if (schedules.isEmpty) {
      return const ExtractionResult(
        candidates: [],
        extractor: ExtractorKind.rule,
        sentChars: 0,
        note: '일정 표현을 찾지 못했습니다.',
      );
    }

    final gemini = await geminiProvider();
    if (gemini == null) {
      return _ruleOnly(
        text,
        schedules,
        sourceApp,
        note: '외부 전송이 꺼져 있거나 API 키가 없어 규칙 파서만 사용했습니다.',
      );
    }

    final filtered = prefilter.select(text, schedules);
    if (filtered.isEmpty) {
      return _ruleOnly(text, schedules, sourceApp);
    }

    try {
      final candidates = await gemini.extract(
        snippets: filtered.snippets,
        sourceText: text,
        sourceApp: sourceApp,
        hints: schedules,
      );
      if (candidates.isEmpty) {
        return _ruleOnly(
          text,
          schedules,
          sourceApp,
          sentChars: filtered.sentLength,
          note: 'Gemini 가 일정을 찾지 못해 규칙 파서 결과를 사용했습니다.',
        );
      }
      return ExtractionResult(
        candidates: candidates,
        extractor: ExtractorKind.gemini,
        sentChars: filtered.sentLength,
      );
    } on BlockedRequestException catch (e) {
      return _ruleOnly(
        text,
        schedules,
        sourceApp,
        note: '네트워크 정책이 요청을 차단했습니다 (${e.reason.code}).',
      );
    } on Exception catch (e) {
      return _ruleOnly(
        text,
        schedules,
        sourceApp,
        sentChars: filtered.sentLength,
        note: 'Gemini 호출 실패로 규칙 파서 결과를 사용했습니다: $e',
      );
    }
  }

  ExtractionResult _ruleOnly(
    String text,
    List<ParsedSchedule> schedules,
    String sourceApp, {
    int sentChars = 0,
    String? note,
  }) {
    return ExtractionResult(
      candidates: ruleExtractor.toCandidates(
        text,
        schedules,
        sourceApp: sourceApp,
      ),
      extractor: ExtractorKind.rule,
      sentChars: sentChars,
      note: note,
    );
  }
}
