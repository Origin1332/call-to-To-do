import 'package:call_to_todo/core/korean_datetime_parser/korean_datetime_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = KoreanDateTimeParser();
  // 2026-11-04 (수) 10:00 을 기준 시각으로 고정한다.
  final now = DateTime(2026, 11, 4, 10, 0);

  ParsedSchedule single(String text) {
    final result = parser.parse(text, now: now);
    expect(result, hasLength(1), reason: '"$text" → $result');
    return result.single;
  }

  group('상대 날짜', () {
    test('오늘/내일/모레/글피', () {
      expect(single('오늘 회의').start, DateTime(2026, 11, 4));
      expect(single('내일 회의').start, DateTime(2026, 11, 5));
      expect(single('모레 회의').start, DateTime(2026, 11, 6));
      expect(single('글피 회의').start, DateTime(2026, 11, 7));
      expect(single('내일 회의').hasTime, isFalse);
      expect(single('내일 회의').hasDate, isTrue);
    });

    test('다음 주 X요일은 다음 주(월요일 시작)의 해당 요일', () {
      expect(single('다음 주 화요일에 보자').start, DateTime(2026, 11, 10));
      expect(single('다음주 금요일').start, DateTime(2026, 11, 13));
      expect(single('다다음 주 월요일').start, DateTime(2026, 11, 16));
      expect(single('이번 주 금요일').start, DateTime(2026, 11, 6));
    });

    test('요일만 있으면 오늘 포함 가장 가까운 해당 요일', () {
      expect(single('수요일에 봐').start, DateTime(2026, 11, 4));
      expect(single('목요일에 봐').start, DateTime(2026, 11, 5));
      expect(single('화요일에 봐').start, DateTime(2026, 11, 10));
    });

    test('다음 주 / 주말', () {
      expect(single('다음 주에 보자').start, DateTime(2026, 11, 9));
      expect(single('이번 주말에 보자').start, DateTime(2026, 11, 7));
      expect(single('다음 주말에 보자').start, DateTime(2026, 11, 14));
    });

    test('N일 뒤 / N주 후', () {
      expect(single('3일 뒤에 결과 나와').start, DateTime(2026, 11, 7));
      expect(single('2주 후 검진').start, DateTime(2026, 11, 18));
    });
  });

  group('절대 날짜', () {
    test('N월 N일 (지났으면 내년)', () {
      expect(single('11월 20일 발표').start, DateTime(2026, 11, 20));
      expect(single('1월 5일 발표').start, DateTime(2027, 1, 5));
    });

    test('YYYY년 N월 N일', () {
      expect(single('2027년 3월 1일 개강').start, DateTime(2027, 3, 1));
    });

    test('N/N 표기', () {
      expect(single('11/20 (금) 회식').start, DateTime(2026, 11, 20));
    });

    test('N일 단독은 이달, 지났으면 다음 달', () {
      expect(single('15일에 입금').start, DateTime(2026, 11, 15));
      expect(single('2일에 입금').start, DateTime(2026, 12, 2));
      expect(single('4일에 입금').start, DateTime(2026, 11, 4));
    });

    test('다음 달 N일', () {
      expect(single('다음 달 3일에 이사').start, DateTime(2026, 12, 3));
    });

    test('기간/상대 표현의 N일은 날짜로 보지 않는다', () {
      expect(parser.parse('3일 동안 출장', now: now), isEmpty);
      expect(parser.parse('5일간 휴가', now: now), isEmpty);
    });

    test('잘못된 날짜는 무시', () {
      expect(parser.parse('13월 40일', now: now), isEmpty);
    });
  });

  group('시각', () {
    test('오전/오후 N시 N분', () {
      final s = single('내일 오후 3시 30분 회의');
      expect(s.start, DateTime(2026, 11, 5, 15, 30));
      expect(s.hasTime, isTrue);
      expect(single('내일 오전 9시').start, DateTime(2026, 11, 5, 9));
      expect(single('내일 오전 12시').start, DateTime(2026, 11, 5, 0));
      expect(single('내일 오후 12시').start, DateTime(2026, 11, 5, 12));
    });

    test('고유어 수사와 반', () {
      expect(single('내일 저녁 일곱시 반').start, DateTime(2026, 11, 5, 19, 30));
      expect(single('내일 아침 여덟 시').start, DateTime(2026, 11, 5, 8));
      expect(single('내일 열두시').start, DateTime(2026, 11, 5, 12));
      expect(single('내일 3시반').start, DateTime(2026, 11, 5, 15, 30));
    });

    test('HH:MM 과 정오/자정', () {
      expect(single('내일 14:30 미팅').start, DateTime(2026, 11, 5, 14, 30));
      expect(single('내일 오전 9:05').start, DateTime(2026, 11, 5, 9, 5));
      expect(single('내일 정오').start, DateTime(2026, 11, 5, 12));
      expect(single('내일 자정').start, DateTime(2026, 11, 5, 0));
    });

    test('오전/오후 없는 1~6시는 오후로, 7~11시는 오전으로 추정', () {
      expect(single('내일 3시').start, DateTime(2026, 11, 5, 15));
      expect(single('내일 9시').start, DateTime(2026, 11, 5, 9));
    });

    test('문장 안의 저녁/아침 단서를 사용', () {
      expect(single('내일 7시에 저녁 먹자').start, DateTime(2026, 11, 5, 19));
      expect(single('내일 7시에 아침 먹자').start, DateTime(2026, 11, 5, 7));
    });

    test('날짜 없이 시각만: 지났으면 내일, 아니면 오늘', () {
      expect(single('오후 3시에 전화할게').start, DateTime(2026, 11, 4, 15));
      expect(single('오전 9시에 전화할게').start, DateTime(2026, 11, 5, 9));
    });

    test('"시간", "시작" 은 시각이 아니다', () {
      expect(parser.parse('3시간 걸려', now: now), isEmpty);
      expect(parser.parse('시작하자', now: now), isEmpty);
    });

    test('시각 범위: 부터/까지, ~, 에서', () {
      final a = single('내일 오후 3시부터 5시까지 회의');
      expect(a.start, DateTime(2026, 11, 5, 15));
      expect(a.end, DateTime(2026, 11, 5, 17));

      final b = single('내일 오전 10시~11시 30분');
      expect(b.start, DateTime(2026, 11, 5, 10));
      expect(b.end, DateTime(2026, 11, 5, 11, 30));

      final c = single('내일 오전 9시에서 오후 6시 사이');
      expect(c.start, DateTime(2026, 11, 5, 9));
      expect(c.end, DateTime(2026, 11, 5, 18));

      final d = single('내일 11시부터 1시까지');
      expect(d.start, DateTime(2026, 11, 5, 11));
      expect(d.end, DateTime(2026, 11, 5, 13));
    });
  });

  group('반복', () {
    test('매일/매주/매월/매년', () {
      expect(single('매일 아침 7시 운동').rrule, 'FREQ=DAILY');
      expect(single('매주 월요일 회의').rrule, 'FREQ=WEEKLY;BYDAY=MO');
      expect(single('매월 25일 월급').rrule, 'FREQ=MONTHLY;BYMONTHDAY=25');
      expect(single('매년 3월 1일 기념').rrule, 'FREQ=YEARLY');
      expect(single('매달 회비').rrule, 'FREQ=MONTHLY');
    });

    test('요일 나열', () {
      expect(single('매주 월수금 수영').rrule, 'FREQ=WEEKLY;BYDAY=MO,WE,FR');
      expect(single('매주 화·목요일 수업').rrule, 'FREQ=WEEKLY;BYDAY=TU,TH');
      expect(single('매주 월요일, 수요일 저녁 7시').rrule, 'FREQ=WEEKLY;BYDAY=MO,WE');
    });

    test('격주 / N주마다 / N일마다', () {
      expect(single('격주 금요일 회식').rrule, 'FREQ=WEEKLY;INTERVAL=2;BYDAY=FR');
      expect(single('2주마다 검진').rrule, 'FREQ=WEEKLY;INTERVAL=2');
      expect(single('3일마다 물 주기').rrule, 'FREQ=DAILY;INTERVAL=3');
      expect(single('3개월마다 정기 점검').rrule, 'FREQ=MONTHLY;INTERVAL=3');
    });

    test('N회는 COUNT', () {
      expect(single('매주 화요일 8회 수업').rrule, 'FREQ=WEEKLY;BYDAY=TU;COUNT=8');
      expect(single('총 10회, 매주 토요일').rrule, 'FREQ=WEEKLY;BYDAY=SA;COUNT=10');
    });

    test('N주간은 COUNT 로 환산', () {
      expect(single('4주간 매주 월수금').rrule, 'FREQ=WEEKLY;BYDAY=MO,WE,FR;COUNT=12');
    });

    test('주 N회는 요일 미정 주간 반복', () {
      expect(single('주 2회 PT').rrule, 'FREQ=WEEKLY');
    });

    test('요일 반복의 시작일은 가장 가까운 해당 요일', () {
      final s = single('매주 화요일 오후 7시 요가');
      expect(s.start, DateTime(2026, 11, 10, 19));
      expect(single('매주 월요일, 수요일 저녁 7시').start, DateTime(2026, 11, 4, 19));
    });

    test('매월 N일 반복의 시작일', () {
      expect(single('매월 25일 월급').start, DateTime(2026, 11, 25));
      expect(single('매월 1일 회비').start, DateTime(2026, 12, 1));
    });

    test('반복 표현만 있으면 오늘부터', () {
      final s = single('매일 운동');
      expect(s.start, DateTime(2026, 11, 4));
      expect(s.hasDate, isFalse);
      expect(s.isRecurring, isTrue);
    });
  });

  group('여러 일정 / 그룹화', () {
    test('문장이 다르면 다른 일정', () {
      final result = parser.parse('내일 3시에 회의야. 모레 오전 10시는 치과.', now: now);
      expect(result, hasLength(2));
      expect(result[0].start, DateTime(2026, 11, 5, 15));
      expect(result[1].start, DateTime(2026, 11, 6, 10));
    });

    test('날짜가 두 번 나오면 별도 일정', () {
      final result = parser.parse('내일 오후 2시 말고 모레 오후 4시 어때', now: now);
      expect(result, hasLength(2));
      expect(result[0].start, DateTime(2026, 11, 5, 14));
      expect(result[1].start, DateTime(2026, 11, 6, 16));
    });

    test('반복 없는 요일 나열은 요일별 일정', () {
      final result = parser.parse('월요일과 수요일 3시에 보자', now: now);
      expect(result, hasLength(2));
      expect(result[0].start, DateTime(2026, 11, 9, 15));
      expect(result[1].start, DateTime(2026, 11, 4, 15));
    });

    test('matchedText 와 오프셋은 원문 구간을 가리킨다', () {
      const text = '그럼 내일 오후 3시에 보자';
      final s = single(text);
      expect(s.matchedText, '내일 오후 3시');
      expect(text.substring(s.startOffset, s.endOffset), s.matchedText);
    });

    test('일정 표현이 없으면 빈 결과', () {
      expect(parser.parse('안녕하세요 잘 지내시죠', now: now), isEmpty);
    });
  });

  group('RecurrenceRule', () {
    test('UNTIL 은 UTC 로 직렬화', () {
      final rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        until: DateTime.utc(2026, 12, 31, 14, 59, 59),
      );
      expect(rule.toRRule(), 'FREQ=WEEKLY;UNTIL=20261231T145959Z');
    });

    test('BYDAY 는 요일 순으로 정렬', () {
      const rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        byWeekdays: [DateTime.friday, DateTime.monday],
      );
      expect(rule.toRRule(), 'FREQ=WEEKLY;BYDAY=MO,FR');
    });
  });
}
