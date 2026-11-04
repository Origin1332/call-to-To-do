/// 한국어 날짜·시간·반복 표현 규칙 파서.
///
/// 네트워크를 전혀 쓰지 않는 순수 Dart 코드다. 추출 파이프라인에서
/// 1) 일정 후보가 있는지 판단(프리필터), 2) 외부 전송이 꺼졌을 때의 유일한
/// 추출기, 3) Gemini 응답 검증용 힌트의 세 가지 역할을 한다.
library;

import 'korean_numbers.dart';
import 'parsed_schedule.dart';
import 'recurrence_rule.dart';

export 'parsed_schedule.dart';
export 'recurrence_rule.dart';

const Map<String, int> _weekdayChars = {
  '월': DateTime.monday,
  '화': DateTime.tuesday,
  '수': DateTime.wednesday,
  '목': DateTime.thursday,
  '금': DateTime.friday,
  '토': DateTime.saturday,
  '일': DateTime.sunday,
};

const String _meridiemWords = '오전|오후|아침|저녁|밤|새벽|낮';
final RegExp _sentenceBoundary = RegExp(r'[.!?\n。]');
final RegExp _pmContext = RegExp('오후|저녁|밤|낮');
final RegExp _amContext = RegExp('오전|아침|새벽');
final RegExp _rangeConnector = RegExp(r'^\s*(?:부터|에서|~|∼|〜|-|–|—)\s*$');
final RegExp _weekdaySeparator = RegExp(
  r'^[\s,·/]*(?:와|과|및|하고|랑|이나|또는)?[\s,·/]*$',
);

// ---------------------------------------------------------------------------
// 토큰
// ---------------------------------------------------------------------------

sealed class _Token {
  _Token(this.start, this.end);
  final int start;
  final int end;
  int get length => end - start;
}

/// 날짜 표현. [resolve] 는 참조일(자정)을 받아 날짜(자정)를 돌려준다.
class _DateToken extends _Token {
  _DateToken(
    super.start,
    super.end,
    this.resolve, {
    this.weekday,
    this.dayOfMonth,
  });
  final DateTime Function(DateTime today) resolve;

  /// "화요일" 처럼 요일만 지정한 경우 (반복 규칙의 BYDAY 로 흡수될 수 있음).
  final int? weekday;

  /// "15일", "3월 15일" 처럼 일(日)을 지정한 경우 (매월 반복의 BYMONTHDAY 후보).
  final int? dayOfMonth;

  bool get isWeekdayOnly => weekday != null;
}

enum _Meridiem { am, pm, none, exact }

class _TimeToken extends _Token {
  _TimeToken(
    super.start,
    super.end, {
    required this.hour,
    required this.minute,
    required this.meridiem,
  });
  final int hour;
  final int minute;
  final _Meridiem meridiem;
}

class _RecurrenceToken extends _Token {
  _RecurrenceToken(super.start, super.end, this.rule);
  final RecurrenceRule rule;
}

class _CountToken extends _Token {
  _CountToken(super.start, super.end, this.count);
  final int count;
}

class _DurationToken extends _Token {
  _DurationToken(super.start, super.end, {this.weeks = 0, this.months = 0});
  final int weeks;
  final int months;
}

typedef _TokenBuilder = _Token? Function(Match m);

class _Rule {
  _Rule(String pattern, this.build) : regex = RegExp(pattern);
  final RegExp regex;
  final _TokenBuilder build;
}

// ---------------------------------------------------------------------------
// 파서
// ---------------------------------------------------------------------------

class KoreanDateTimeParser {
  const KoreanDateTimeParser({this.maxGroupGap = 16});

  /// 같은 일정으로 묶을 수 있는 토큰 사이의 최대 글자 수(문장 경계가 없을 때).
  final int maxGroupGap;

  /// [text] 에서 일정 표현을 모두 찾아 [now] 기준으로 해석한다. 원문 순서대로 반환.
  List<ParsedSchedule> parse(String text, {required DateTime now}) {
    final tokens = _scan(text);
    final groups = _group(text, tokens);
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (final group in groups) ..._resolveGroup(text, group, now, today),
    ];
  }

  // ---------------------------------------------------------------- 스캔

  List<_Token> _scan(String text) {
    final found = <_Token>[];
    for (final rule in _rules) {
      for (final m in rule.regex.allMatches(text)) {
        final token = rule.build(m);
        if (token != null) found.add(token);
      }
    }
    // 겹치는 토큰은 더 긴 쪽만 남긴다 ("11월 5일" 이 "5일" 을 이김).
    found.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      return byStart != 0 ? byStart : b.length.compareTo(a.length);
    });
    final kept = <_Token>[];
    for (final token in found) {
      if (kept.isNotEmpty && token.start < kept.last.end) continue;
      kept.add(token);
    }
    return kept;
  }

  // ---------------------------------------------------------------- 그룹화

  List<List<_Token>> _group(String text, List<_Token> tokens) {
    final groups = <List<_Token>>[];
    var current = <_Token>[];

    for (final token in tokens) {
      if (current.isEmpty) {
        current.add(token);
        continue;
      }
      final previous = current.last;
      final gap = text.substring(previous.end, token.start);
      final crossesSentence = _sentenceBoundary.hasMatch(gap);
      final tooFar = gap.trim().length > maxGroupGap;
      final conflicts = _conflicts(current, previous, token, gap);

      // "매주 월수금 수영. 총 12회." 처럼 횟수/기간이 다음 문장으로 넘어가도
      // 직전 반복 일정에 붙인다.
      final trailingModifier =
          crossesSentence &&
          !tooFar &&
          !conflicts &&
          (token is _CountToken || token is _DurationToken) &&
          current.any((t) => t is _RecurrenceToken);

      if ((crossesSentence && !trailingModifier) || tooFar || conflicts) {
        groups.add(current);
        current = [token];
      } else {
        current.add(token);
      }
    }
    if (current.isNotEmpty) groups.add(current);
    // 횟수/기간만 있는 그룹은 일정이 아니다 ("총 3회 통화했어").
    return groups
        .where(
          (g) => g.any(
            (t) => t is _DateToken || t is _TimeToken || t is _RecurrenceToken,
          ),
        )
        .toList();
  }

  /// 새 토큰이 현재 그룹과 같은 일정으로 보기 어려운지 판단한다.
  bool _conflicts(
    List<_Token> group,
    _Token previous,
    _Token token,
    String gap,
  ) {
    switch (token) {
      case _DateToken():
        final dates = group.whereType<_DateToken>().toList();
        if (dates.isEmpty) return false;
        // "월요일, 수요일" 처럼 요일 나열은 하나의 그룹으로 허용한다.
        final weekdayList =
            token.isWeekdayOnly &&
            dates.every((d) => d.isWeekdayOnly) &&
            previous is _DateToken &&
            _weekdaySeparator.hasMatch(gap);
        return !weekdayList;
      case _TimeToken():
        final times = group.whereType<_TimeToken>().toList();
        if (times.isEmpty) return false;
        if (times.length >= 2) return true;
        return !_isRange(previous, gap);
      case _RecurrenceToken():
        return group.any((t) => t is _RecurrenceToken);
      case _CountToken():
        return group.any((t) => t is _CountToken);
      case _DurationToken():
        return group.any((t) => t is _DurationToken);
    }
  }

  bool _isRange(_Token previous, String gap) =>
      previous is _TimeToken && _rangeConnector.hasMatch(gap);

  // ---------------------------------------------------------------- 해석

  List<ParsedSchedule> _resolveGroup(
    String text,
    List<_Token> group,
    DateTime now,
    DateTime today,
  ) {
    final dates = group.whereType<_DateToken>().toList();
    final times = group.whereType<_TimeToken>().toList();
    final recurrenceToken = group.whereType<_RecurrenceToken>().firstOrNull;
    final countToken = group.whereType<_CountToken>().firstOrNull;
    final durationToken = group.whereType<_DurationToken>().firstOrNull;

    final startOffset = group.map((t) => t.start).reduce(_min);
    final endOffset = group.map((t) => t.end).reduce(_max);
    final matchedText = text.substring(startOffset, endOffset);

    // 반복 없이 요일이 여러 개 나열되면 요일별로 별도 일정을 만든다.
    if (recurrenceToken == null &&
        dates.length >= 2 &&
        dates.every((d) => d.isWeekdayOnly)) {
      return [
        for (final date in dates)
          _buildSchedule(
            text: text,
            date: date,
            times: times,
            rule: null,
            now: now,
            today: today,
            matchedText: matchedText,
            startOffset: startOffset,
            endOffset: endOffset,
          ),
      ];
    }

    var rule = recurrenceToken?.rule;
    if (rule != null) {
      rule = _mergeRuleWithDates(rule, dates);
      if (countToken != null) rule = rule.copyWith(count: countToken.count);
    }

    final schedule = _buildSchedule(
      text: text,
      date: dates.firstOrNull,
      times: times,
      rule: rule,
      now: now,
      today: today,
      matchedText: matchedText,
      startOffset: startOffset,
      endOffset: endOffset,
    );

    if (rule != null && durationToken != null && countToken == null) {
      final limited = _applyDuration(rule, durationToken, schedule.start);
      return [
        ParsedSchedule(
          start: schedule.start,
          end: schedule.end,
          hasDate: schedule.hasDate,
          hasTime: schedule.hasTime,
          rrule: limited.toRRule(),
          matchedText: matchedText,
          startOffset: startOffset,
          endOffset: endOffset,
        ),
      ];
    }
    return [schedule];
  }

  RecurrenceRule _mergeRuleWithDates(
    RecurrenceRule rule,
    List<_DateToken> dates,
  ) {
    switch (rule.frequency) {
      case RecurrenceFrequency.weekly:
        final weekdays = {
          ...rule.byWeekdays,
          for (final d in dates)
            if (d.weekday != null) d.weekday!,
        }.toList();
        return rule.copyWith(byWeekdays: weekdays);
      case RecurrenceFrequency.monthly:
        final day = dates.map((d) => d.dayOfMonth).whereType<int>().firstOrNull;
        return rule.byMonthDay == null && day != null
            ? rule.copyWith(byMonthDay: day)
            : rule;
      case RecurrenceFrequency.daily:
      case RecurrenceFrequency.yearly:
        return rule;
    }
  }

  RecurrenceRule _applyDuration(
    RecurrenceRule rule,
    _DurationToken duration,
    DateTime start,
  ) {
    if (duration.weeks > 0 && rule.frequency == RecurrenceFrequency.weekly) {
      final perWeek = rule.byWeekdays.isEmpty ? 1 : rule.byWeekdays.length;
      return rule.copyWith(count: duration.weeks * perWeek);
    }
    if (duration.months > 0 && rule.frequency == RecurrenceFrequency.monthly) {
      return rule.copyWith(count: duration.months);
    }
    final until = DateTime(
      start.year,
      start.month + duration.months,
      start.day + duration.weeks * 7,
      23,
      59,
      59,
    );
    return rule.copyWith(until: until);
  }

  ParsedSchedule _buildSchedule({
    required String text,
    required _DateToken? date,
    required List<_TimeToken> times,
    required RecurrenceRule? rule,
    required DateTime now,
    required DateTime today,
    required String matchedText,
    required int startOffset,
    required int endOffset,
  }) {
    var day = _resolveStartDay(date, rule, today);
    final hasDate = date != null;
    final hasTime = times.isNotEmpty;

    var start = day;
    DateTime? end;
    if (hasTime) {
      final first = _resolveTime(text, times.first);
      start = DateTime(
        day.year,
        day.month,
        day.day + first.dayOffset,
        first.hour,
        first.minute,
      );
      if (times.length >= 2) {
        final second = _resolveTime(text, times[1], inheritFrom: first);
        var candidate = DateTime(
          day.year,
          day.month,
          day.day + second.dayOffset,
          second.hour,
          second.minute,
        );
        if (!candidate.isAfter(start)) {
          candidate = candidate.add(const Duration(hours: 12));
        }
        if (!candidate.isAfter(start)) {
          candidate = candidate.add(const Duration(hours: 12));
        }
        end = candidate;
      }
      // 날짜·반복 없이 시각만 있고 이미 지난 시각이면 내일로 본다.
      if (!hasDate && rule == null && !start.isAfter(now)) {
        day = day.add(const Duration(days: 1));
        start = start.add(const Duration(days: 1));
        end = end?.add(const Duration(days: 1));
      }
    }

    return ParsedSchedule(
      start: start,
      end: end,
      hasDate: hasDate,
      hasTime: hasTime,
      rrule: rule?.toRRule(),
      matchedText: matchedText,
      startOffset: startOffset,
      endOffset: endOffset,
    );
  }

  DateTime _resolveStartDay(
    _DateToken? date,
    RecurrenceRule? rule,
    DateTime today,
  ) {
    // 요일 반복(BYDAY)은 가장 가까운 해당 요일부터 시작해야 첫 회차를 놓치지 않는다.
    final weekdayRecurrence =
        rule != null &&
        rule.frequency == RecurrenceFrequency.weekly &&
        rule.byWeekdays.isNotEmpty &&
        (date == null || date.isWeekdayOnly);
    if (date != null && !weekdayRecurrence) return date.resolve(today);
    if (rule == null) return today;
    switch (rule.frequency) {
      case RecurrenceFrequency.weekly when rule.byWeekdays.isNotEmpty:
        final offsets =
            rule.byWeekdays.map((w) => (w - today.weekday + 7) % 7).toList()
              ..sort();
        return today.add(Duration(days: offsets.first));
      case RecurrenceFrequency.monthly when rule.byMonthDay != null:
        final day = rule.byMonthDay!;
        final monthOffset = day >= today.day ? 0 : 1;
        return DateTime(today.year, today.month + monthOffset, day);
      default:
        return today;
    }
  }

  ({int hour, int minute, int dayOffset}) _resolveTime(
    String text,
    _TimeToken token, {
    ({int hour, int minute, int dayOffset})? inheritFrom,
  }) {
    var hour = token.hour;
    final minute = token.minute;
    var dayOffset = 0;

    switch (token.meridiem) {
      case _Meridiem.am:
        if (hour == 12) hour = 0;
      case _Meridiem.pm:
        if (hour < 12) hour += 12;
        if (hour == 24) {
          hour = 0;
          dayOffset = 1;
        }
      case _Meridiem.exact:
        break;
      case _Meridiem.none:
        if (inheritFrom != null) {
          // 범위의 끝: 시작과 같은 오전/오후로 두고, 앞서지 않도록 호출자가 보정.
          if (inheritFrom.hour >= 12 && hour < 12) hour += 12;
        } else {
          hour = _guessHourFromContext(text, token, hour);
        }
    }
    return (hour: hour, minute: minute, dayOffset: dayOffset);
  }

  /// 오전/오후 표기가 없는 시각: 같은 문장의 단서(저녁/아침 등) → 없으면
  /// 1~6시는 오후로 추정한다.
  int _guessHourFromContext(String text, _TimeToken token, int hour) {
    if (hour >= 13 || hour == 0) return hour;
    final sentence = _sentenceAround(text, token);
    if (_pmContext.hasMatch(sentence)) return hour == 12 ? 12 : hour + 12;
    if (_amContext.hasMatch(sentence)) return hour == 12 ? 0 : hour;
    if (hour >= 1 && hour <= 6) return hour + 12;
    return hour;
  }

  String _sentenceAround(String text, _Token token) {
    var begin = token.start;
    while (begin > 0 && !_sentenceBoundary.hasMatch(text[begin - 1])) {
      begin--;
    }
    var finish = token.end;
    while (finish < text.length && !_sentenceBoundary.hasMatch(text[finish])) {
      finish++;
    }
    return text.substring(begin, finish);
  }

  static int _min(int a, int b) => a < b ? a : b;
  static int _max(int a, int b) => a > b ? a : b;
}

// ---------------------------------------------------------------------------
// 규칙 테이블
// ---------------------------------------------------------------------------

_Meridiem _meridiemOf(String? word) {
  switch (word) {
    case '오전' || '아침' || '새벽':
      return _Meridiem.am;
    case '오후' || '저녁' || '밤' || '낮':
      return _Meridiem.pm;
    default:
      return _Meridiem.none;
  }
}

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

bool _validMonthDay(int month, int day) =>
    month >= 1 && month <= 12 && day >= 1 && day <= 31;

DateTime _mondayOfWeek(DateTime today) =>
    today.subtract(Duration(days: today.weekday - DateTime.monday));

DateTime _nextWeekday(DateTime today, int weekday) =>
    today.add(Duration(days: (weekday - today.weekday + 7) % 7));

int _weekOffsetOf(String word) {
  final compact = word.replaceAll(RegExp(r'\s'), '');
  if (compact.startsWith('다다음')) return 2;
  if (compact.startsWith('다음') || compact.startsWith('담')) return 1;
  return 0;
}

/// 월/일만 주어진 날짜: 올해 기준, 이미 지났으면 내년으로 본다.
DateTime _monthDayThisYearOrNext(DateTime today, int month, int day) {
  var candidate = DateTime(today.year, month, day);
  if (candidate.isBefore(today)) {
    candidate = DateTime(today.year + 1, month, day);
  }
  return candidate;
}

final List<_Rule> _rules = [
  // ---- 날짜: 절대 -------------------------------------------------------
  _Rule(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일', (m) {
    final year = int.parse(m[1]!);
    final month = int.parse(m[2]!);
    final day = int.parse(m[3]!);
    if (!_validMonthDay(month, day)) return null;
    return _DateToken(
      m.start,
      m.end,
      (_) => DateTime(year, month, day),
      dayOfMonth: day,
    );
  }),
  _Rule(r'(\d{1,2})월\s*(\d{1,2})일', (m) {
    final month = int.parse(m[1]!);
    final day = int.parse(m[2]!);
    if (!_validMonthDay(month, day)) return null;
    return _DateToken(
      m.start,
      m.end,
      (today) => _monthDayThisYearOrNext(today, month, day),
      dayOfMonth: day,
    );
  }),
  _Rule(r'(?<![\d/])(\d{1,2})/(\d{1,2})(?![\d/])', (m) {
    final month = int.parse(m[1]!);
    final day = int.parse(m[2]!);
    if (!_validMonthDay(month, day)) return null;
    return _DateToken(
      m.start,
      m.end,
      (today) => _monthDayThisYearOrNext(today, month, day),
      dayOfMonth: day,
    );
  }),
  _Rule(r'다음\s*달\s*(\d{1,2})일', (m) {
    final day = int.parse(m[1]!);
    if (day < 1 || day > 31) return null;
    return _DateToken(
      m.start,
      m.end,
      (today) => DateTime(today.year, today.month + 1, day),
      dayOfMonth: day,
    );
  }),
  // "15일" 단독: 이달(이미 지났으면 다음 달)의 해당 일. "3일 동안/뒤/마다" 등은 제외.
  _Rule(r'(?<!\d)(\d{1,2})일(?![간째\d])(?!\s*(?:동안|전|후|뒤|마다|씩))', (m) {
    final day = int.parse(m[1]!);
    if (day < 1 || day > 31) return null;
    return _DateToken(m.start, m.end, (today) {
      final monthOffset = day >= today.day ? 0 : 1;
      final month = today.month + monthOffset;
      final year = today.year;
      if (day > _daysInMonth(year, month)) {
        return DateTime(year, month + 1, day);
      }
      return DateTime(year, month, day);
    }, dayOfMonth: day);
  }),
  // ---- 날짜: 상대 -------------------------------------------------------
  _Rule(r'오늘|내일|모레|글피', (m) {
    const offsets = {'오늘': 0, '내일': 1, '모레': 2, '글피': 3};
    final offset = offsets[m[0]]!;
    return _DateToken(
      m.start,
      m.end,
      (today) => today.add(Duration(days: offset)),
    );
  }),
  _Rule(r'(\d+)일\s*(?:뒤|후)', (m) {
    final days = int.parse(m[1]!);
    return _DateToken(
      m.start,
      m.end,
      (today) => today.add(Duration(days: days)),
    );
  }),
  _Rule(r'(\d+)주\s*(?:뒤|후)', (m) {
    final weeks = int.parse(m[1]!);
    return _DateToken(
      m.start,
      m.end,
      (today) => today.add(Duration(days: weeks * 7)),
    );
  }),
  _Rule(r'(이번\s*주|다음\s*주|다다음\s*주|담주|이번주|다음주)\s*([월화수목금토일])요일', (m) {
    final offset = _weekOffsetOf(m[1]!);
    final weekday = _weekdayChars[m[2]!]!;
    // 주(週)가 명시된 요일은 구체적 날짜로 취급한다 (BYDAY 로 흡수하지 않음).
    return _DateToken(
      m.start,
      m.end,
      (today) =>
          _mondayOfWeek(today)
              .add(Duration(days: offset * 7 + (weekday - DateTime.monday))),
    );
  }),
  _Rule(r'(다음\s*주|다다음\s*주|담주|다음주)(?!\s*[월화수목금토일]요일)', (m) {
    final offset = _weekOffsetOf(m[1]!);
    return _DateToken(
      m.start,
      m.end,
      (today) => _mondayOfWeek(today).add(Duration(days: offset * 7)),
    );
  }),
  _Rule(r'(이번\s*|다음\s*|다다음\s*)?주말', (m) {
    final offset = m[1] == null ? 0 : _weekOffsetOf(m[1]!);
    return _DateToken(m.start, m.end, (today) {
      if (offset == 0) return _nextWeekday(today, DateTime.saturday);
      return _mondayOfWeek(today)
          .add(Duration(days: offset * 7 + (DateTime.saturday - 1)));
    });
  }),
  _Rule(r'([월화수목금토일])요일', (m) {
    final weekday = _weekdayChars[m[1]!]!;
    return _DateToken(
      m.start,
      m.end,
      (today) => _nextWeekday(today, weekday),
      weekday: weekday,
    );
  }),
  // ---- 시각 -------------------------------------------------------------
  _Rule('(?:($_meridiemWords)\\s*)?($hourNumberPattern)\\s*시(?![간작적])'
      r'(?:\s*(\d{1,2})\s*분|\s*(반))?', (m) {
    final hour = parseHourNumber(m[2]!);
    if (hour == null || hour > 24) return null;
    final minute = m[4] != null ? 30 : int.tryParse(m[3] ?? '') ?? 0;
    if (minute > 59) return null;
    return _TimeToken(
      m.start,
      m.end,
      hour: hour,
      minute: minute,
      meridiem: _meridiemOf(m[1]),
    );
  }),
  _Rule('(?:($_meridiemWords)\\s*)?(?<!\\d)(\\d{1,2}):(\\d{2})(?!\\d)', (m) {
    final hour = int.parse(m[2]!);
    final minute = int.parse(m[3]!);
    if (hour > 24 || minute > 59) return null;
    return _TimeToken(
      m.start,
      m.end,
      hour: hour,
      minute: minute,
      meridiem: _meridiemOf(m[1]),
    );
  }),
  _Rule(r'정오|자정', (m) {
    final isNoon = m[0] == '정오';
    return _TimeToken(
      m.start,
      m.end,
      hour: isNoon ? 12 : 0,
      minute: 0,
      meridiem: _Meridiem.exact,
    );
  }),
  // ---- 반복 -------------------------------------------------------------
  _Rule(r'매일|날마다', (m) {
    return _RecurrenceToken(
      m.start,
      m.end,
      const RecurrenceRule(frequency: RecurrenceFrequency.daily),
    );
  }),
  // "매주 월수금", "격주 화·목요일" 처럼 요일을 나열한 경우까지 한 토큰으로 잡는다.
  _Rule(r'(매주|격주|주마다)(?:\s*((?:[월화수목금토일][\s,·/]*){2,7})(?:요일)?)?', (m) {
    final interval = m[1] == '격주' ? 2 : 1;
    final weekdays = [
      for (final ch in (m[2] ?? '').split(''))
        if (_weekdayChars.containsKey(ch)) _weekdayChars[ch]!,
    ];
    return _RecurrenceToken(
      m.start,
      m.end,
      RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: interval,
        byWeekdays: weekdays,
      ),
    );
  }),
  _Rule(r'(매월|매달|달마다)(?:\s*(\d{1,2})일)?', (m) {
    final day = m[2] != null ? int.parse(m[2]!) : null;
    if (day != null && (day < 1 || day > 31)) return null;
    return _RecurrenceToken(
      m.start,
      m.end,
      RecurrenceRule(frequency: RecurrenceFrequency.monthly, byMonthDay: day),
    );
  }),
  _Rule(r'매년|매해|해마다', (m) {
    return _RecurrenceToken(
      m.start,
      m.end,
      const RecurrenceRule(frequency: RecurrenceFrequency.yearly),
    );
  }),
  _Rule(r'(\d+)주\s*(?:마다|에\s*한\s*번)', (m) {
    return _RecurrenceToken(
      m.start,
      m.end,
      RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: int.parse(m[1]!),
      ),
    );
  }),
  _Rule(r'(\d+)일\s*마다', (m) {
    return _RecurrenceToken(
      m.start,
      m.end,
      RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: int.parse(m[1]!),
      ),
    );
  }),
  _Rule(r'(\d+)(?:개월|달)\s*마다', (m) {
    return _RecurrenceToken(
      m.start,
      m.end,
      RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        interval: int.parse(m[1]!),
      ),
    );
  }),
  // "주 2회": 주간 반복이지만 요일은 알 수 없다 → 사용자가 Review 에서 지정.
  _Rule(r'주\s*(\d+)\s*회', (m) {
    return _RecurrenceToken(
      m.start,
      m.end,
      const RecurrenceRule(frequency: RecurrenceFrequency.weekly),
    );
  }),
  // ---- 횟수 / 기간 ------------------------------------------------------
  _Rule(r'(?:총\s*)?(\d+)\s*회(?!차)', (m) {
    final count = int.parse(m[1]!);
    return count > 0 ? _CountToken(m.start, m.end, count) : null;
  }),
  _Rule(r'(\d+)주\s*(?:간|동안)', (m) {
    return _DurationToken(m.start, m.end, weeks: int.parse(m[1]!));
  }),
  _Rule(r'(\d+)(?:개월|달)\s*(?:간|동안)', (m) {
    return _DurationToken(m.start, m.end, months: int.parse(m[1]!));
  }),
];
