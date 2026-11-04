/// 규칙 파서가 텍스트에서 찾아낸 일정 표현 하나.
///
/// [start]/[end] 는 참조 시각(`now`) 기준으로 해석된 로컬 시각이다.
/// 시간 표현이 없으면 [hasTime] 이 false 이고 [start] 는 해당 날짜 00:00 이다.
class ParsedSchedule {
  const ParsedSchedule({
    required this.start,
    required this.end,
    required this.hasDate,
    required this.hasTime,
    required this.matchedText,
    required this.startOffset,
    required this.endOffset,
    this.rrule,
  });

  final DateTime start;

  /// 범위 표현("3시부터 5시까지")이 있을 때만 채워진다.
  final DateTime? end;

  /// 날짜 표현이 명시되었는지 (없으면 오늘/다음 발생일로 추정한 것).
  final bool hasDate;

  /// 시각 표현이 명시되었는지.
  final bool hasTime;

  /// iCalendar RRULE (예: `FREQ=WEEKLY;BYDAY=MO,WE`). 반복 표현이 없으면 null.
  final String? rrule;

  /// 원문에서 이 일정에 해당하는 표현들을 합친 구간의 텍스트.
  final String matchedText;

  /// 원문 내 [matchedText] 시작/끝 오프셋 (끝은 exclusive).
  final int startOffset;
  final int endOffset;

  bool get isRecurring => rrule != null;

  @override
  String toString() =>
      'ParsedSchedule(start: $start, end: $end, rrule: $rrule, '
      'hasDate: $hasDate, hasTime: $hasTime, text: "$matchedText")';
}
