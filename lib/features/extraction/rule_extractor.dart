import 'dart:math';

import '../../core/korean_datetime_parser/korean_datetime_parser.dart';
import 'models/schedule_candidate.dart';

/// 외부 전송 없이 규칙 파서 결과만으로 [ScheduleCandidate] 를 만든다.
///
/// 제목은 일정 표현이 들어 있는 문장에서 날짜/시간 표현을 뺀 나머지로 추정하고,
/// 비어 있으면 "일정" 으로 둔다. 사용자가 Review 화면에서 바로 고칠 수 있다.
class RuleExtractor {
  const RuleExtractor({
    this.defaultDuration = const Duration(hours: 1),
    this.maxTitleLength = 40,
  });

  final Duration defaultDuration;
  final int maxTitleLength;

  static final RegExp _boundary = RegExp(r'[.!?\n。]');
  static final RegExp _particles = RegExp(
    r'^(에|에서|부터|까지|쯤|경|에는|은|는|이|가|을|를|로|으로)\s*',
  );

  List<ScheduleCandidate> toCandidates(
    String text,
    List<ParsedSchedule> schedules, {
    required String sourceApp,
    ExtractorKind extractor = ExtractorKind.rule,
  }) {
    return [
      for (final s in schedules)
        ScheduleCandidate(
          id: newCandidateId(),
          title: _titleFor(text, s),
          start: s.start,
          end: _endFor(s),
          allDay: !s.hasTime,
          recurrence: s.rrule,
          details: _sentenceAround(text, s).trim(),
          sourceText: text,
          sourceApp: sourceApp,
          extractor: extractor,
        ),
    ];
  }

  DateTime _endFor(ParsedSchedule s) {
    if (s.end != null) return s.end!;
    if (!s.hasTime) return s.start.add(const Duration(days: 1));
    return s.start.add(defaultDuration);
  }

  String _titleFor(String text, ParsedSchedule s) {
    final sentence = _sentenceAround(text, s);
    final matchIndex = sentence.indexOf(s.matchedText);
    var remainder = matchIndex < 0
        ? sentence
        : sentence.substring(matchIndex + s.matchedText.length);
    remainder = remainder.replaceFirst(_particles, '').trim();
    if (remainder.isEmpty && matchIndex > 0) {
      remainder = sentence.substring(0, matchIndex).trim();
    }
    remainder = remainder.replaceAll(RegExp(r'\s+'), ' ');
    if (remainder.isEmpty) return '일정';
    return remainder.length > maxTitleLength
        ? '${remainder.substring(0, maxTitleLength)}…'
        : remainder;
  }

  String _sentenceAround(String text, ParsedSchedule s) {
    var begin = s.startOffset;
    while (begin > 0 && !_boundary.hasMatch(text[begin - 1])) {
      begin--;
    }
    var finish = s.endOffset;
    while (finish < text.length && !_boundary.hasMatch(text[finish])) {
      finish++;
    }
    return text.substring(begin, finish);
  }
}

final Random _random = Random.secure();

/// 시각 + 난수 기반의 짧은 고유 ID (외부 패키지 없이).
String newCandidateId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final salt = _random.nextInt(1 << 32).toRadixString(36);
  return '$time-$salt';
}
