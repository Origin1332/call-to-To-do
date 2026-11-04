/// RRULE(RFC 5545) 생성을 위한 최소 모델.
enum RecurrenceFrequency { daily, weekly, monthly, yearly }

const List<String> _byDayCodes = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

/// [DateTime.weekday](월=1 … 일=7)를 RRULE BYDAY 코드로 바꾼다.
String weekdayToByDay(int weekday) => _byDayCodes[weekday - 1];

class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.byWeekdays = const [],
    this.byMonthDay,
    this.count,
    this.until,
  });

  final RecurrenceFrequency frequency;
  final int interval;

  /// [DateTime.weekday] 값 목록(월=1 … 일=7). WEEKLY 에서만 사용.
  final List<int> byWeekdays;
  final int? byMonthDay;
  final int? count;
  final DateTime? until;

  RecurrenceRule copyWith({
    RecurrenceFrequency? frequency,
    int? interval,
    List<int>? byWeekdays,
    int? byMonthDay,
    int? count,
    DateTime? until,
  }) {
    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      byWeekdays: byWeekdays ?? this.byWeekdays,
      byMonthDay: byMonthDay ?? this.byMonthDay,
      count: count ?? this.count,
      until: until ?? this.until,
    );
  }

  /// `FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE;COUNT=8` 형태의 RRULE 문자열.
  String toRRule() {
    final parts = <String>['FREQ=${frequency.name.toUpperCase()}'];
    if (interval > 1) parts.add('INTERVAL=$interval');
    if (byWeekdays.isNotEmpty) {
      final sorted = [...byWeekdays]..sort();
      parts.add('BYDAY=${sorted.map(weekdayToByDay).join(',')}');
    }
    if (byMonthDay != null) parts.add('BYMONTHDAY=$byMonthDay');
    if (count != null) parts.add('COUNT=$count');
    if (until != null) parts.add('UNTIL=${_formatUntil(until!)}');
    return parts.join(';');
  }

  static String _formatUntil(DateTime until) {
    final utc = until.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}'
        'T${two(utc.hour)}${two(utc.minute)}${two(utc.second)}Z';
  }
}
