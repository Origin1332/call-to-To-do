import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../../core/korean_datetime_parser/korean_datetime_parser.dart';
import 'models/schedule_candidate.dart';
import 'rule_extractor.dart';

/// Gemini 가 돌려준 응답을 해석할 수 없을 때.
class GeminiExtractionException implements Exception {
  const GeminiExtractionException(this.message);
  final String message;

  @override
  String toString() => 'GeminiExtractionException: $message';
}

/// Gemini Flash 로 일정 후보를 추출한다.
///
/// * 전송되는 텍스트는 [Prefilter] 를 통과한 문장 조각뿐이다.
/// * 반드시 [PolicyHttpClient] 를 [httpClient] 로 주입해야 하며, 그 덕분에
///   허용 호스트 검사와 감사 로그가 자동으로 적용된다.
/// * JSON 스키마 응답 모드를 사용해 파싱 실패를 줄인다.
class GeminiExtractor {
  GeminiExtractor({
    required String apiKey,
    required http.Client httpClient,
    this.modelName = defaultModel,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _model = GenerativeModel(
         model: modelName,
         apiKey: apiKey,
         httpClient: httpClient,
         systemInstruction: Content.system(_systemPrompt),
         generationConfig: GenerationConfig(
           temperature: 0.1,
           responseMimeType: 'application/json',
           responseSchema: _responseSchema,
         ),
       );

  static const String defaultModel = 'gemini-2.5-flash';

  final String modelName;
  final GenerativeModel _model;
  final DateTime Function() _clock;

  static const String _systemPrompt = '''
당신은 한국어 대화/메시지에서 캘린더 일정을 추출하는 도우미입니다.
입력은 통화 내용이나 메신저 메시지의 일부 문장입니다. 일정으로 볼 수 있는 약속·예약·수업·회의·마감 등을 모두 찾아 JSON 배열로 반환하세요.
규칙:
- start/end 는 "YYYY-MM-DDTHH:mm:ss" 형식의 현지 시각(타임존 표기 없음)으로 쓰세요.
- 시각이 없으면 all_day 를 true 로 하고 start 는 그날 00:00:00, end 는 다음날 00:00:00 으로 쓰세요.
- 종료 시각이 없으면 시작 1시간 후로 쓰세요.
- 반복 일정이면 recurrence 에 RFC 5545 RRULE 문자열(예: FREQ=WEEKLY;BYDAY=MO,WE)을 쓰고, 아니면 null.
- title 은 20자 이내의 간결한 한국어 제목, details 에는 장소·참석자·준비물 등 부가 정보를 쓰세요.
- 일정이 없으면 빈 배열을 반환하세요. 추측으로 일정을 만들지 마세요.
''';

  static final Schema _responseSchema = Schema.array(
    items: Schema.object(
      properties: {
        'title': Schema.string(description: '일정 제목'),
        'start': Schema.string(description: 'YYYY-MM-DDTHH:mm:ss 현지 시각'),
        'end': Schema.string(description: 'YYYY-MM-DDTHH:mm:ss 현지 시각'),
        'all_day': Schema.boolean(description: '종일 일정 여부'),
        'recurrence': Schema.string(
          description: 'RFC 5545 RRULE 또는 null',
          nullable: true,
        ),
        'details': Schema.string(description: '부가 정보', nullable: true),
      },
      requiredProperties: ['title', 'start', 'end', 'all_day'],
    ),
  );

  /// [snippets] 를 보내 후보를 받는다. [hints] 는 규칙 파서 결과로, 모델이
  /// 상대 날짜를 해석할 때 참고하도록 프롬프트에 함께 넣는다.
  Future<List<ScheduleCandidate>> extract({
    required List<String> snippets,
    required String sourceText,
    required String sourceApp,
    List<ParsedSchedule> hints = const [],
  }) async {
    if (snippets.isEmpty) return const [];

    final response = await _model.generateContent([
      Content.text(buildPrompt(snippets: snippets, hints: hints)),
    ]);
    final raw = response.text;
    if (raw == null || raw.trim().isEmpty) {
      throw const GeminiExtractionException('빈 응답');
    }
    return parseResponse(raw, sourceText: sourceText, sourceApp: sourceApp);
  }

  /// 모델에 보내는 사용자 프롬프트. 테스트에서 내용 확인을 위해 공개한다.
  String buildPrompt({
    required List<String> snippets,
    required List<ParsedSchedule> hints,
  }) {
    final now = _clock();
    final buffer = StringBuffer()
      ..writeln('현재 시각: ${_iso(now)} (${_weekdayLabel(now.weekday)})')
      ..writeln('타임존: ${now.timeZoneName}');
    if (hints.isNotEmpty) {
      buffer.writeln('규칙 파서 힌트:');
      for (final h in hints) {
        buffer.writeln(
          '- "${h.matchedText}" → ${_iso(h.start)}${h.rrule != null ? ' / ${h.rrule}' : ''}',
        );
      }
    }
    buffer.writeln('--- 텍스트 ---');
    for (final s in snippets) {
      buffer.writeln(s);
      buffer.writeln('---');
    }
    return buffer.toString();
  }

  /// Gemini JSON 응답 → 후보 목록. 형식이 틀린 항목은 건너뛴다.
  List<ScheduleCandidate> parseResponse(
    String raw, {
    required String sourceText,
    required String sourceApp,
  }) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (e) {
      throw GeminiExtractionException('JSON 파싱 실패: ${e.message}');
    }
    if (decoded is! List) {
      throw const GeminiExtractionException('배열이 아닌 응답');
    }

    final candidates = <ScheduleCandidate>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      final start = DateTime.tryParse(item['start'] as String? ?? '');
      if (start == null) continue;
      final allDay = item['all_day'] == true;
      final end =
          DateTime.tryParse(item['end'] as String? ?? '') ??
          start.add(
            allDay ? const Duration(days: 1) : const Duration(hours: 1),
          );
      final recurrence = (item['recurrence'] as String?)?.trim();
      final title = (item['title'] as String?)?.trim();

      candidates.add(
        ScheduleCandidate(
          id: newCandidateId(),
          title: title == null || title.isEmpty ? '일정' : title,
          start: start,
          end: end.isAfter(start) ? end : start.add(const Duration(hours: 1)),
          allDay: allDay,
          recurrence: recurrence == null || recurrence.isEmpty
              ? null
              : recurrence,
          details: (item['details'] as String?)?.trim(),
          sourceText: sourceText,
          sourceApp: sourceApp,
          extractor: ExtractorKind.gemini,
        ),
      );
    }
    return candidates;
  }

  static String _iso(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)}'
        'T${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  static String _weekdayLabel(int weekday) =>
      '${const ['월', '화', '수', '목', '금', '토', '일'][weekday - 1]}요일';
}
