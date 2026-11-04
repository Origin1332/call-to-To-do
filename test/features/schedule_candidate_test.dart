import 'dart:convert';

import 'package:call_to_todo/core/pigeon/calendar_api.g.dart';
import 'package:call_to_todo/data/candidate_mapper.dart';
import 'package:call_to_todo/data/database.dart';
import 'package:call_to_todo/features/calendar/calendar_repository.dart';
import 'package:call_to_todo/features/extraction/models/schedule_candidate.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final candidate = ScheduleCandidate(
    id: 'abc-123',
    title: '팀 워크숍',
    start: DateTime(2026, 11, 20, 10),
    end: DateTime(2026, 11, 20, 12),
    recurrence: 'FREQ=WEEKLY;BYDAY=FR;COUNT=4',
    details: '회의실 A',
    sourceText: '11월 20일 오전 10시부터 12시까지 팀 워크숍 있습니다.',
    sourceApp: 'debug',
    extractor: ExtractorKind.gemini,
  );

  group('ScheduleCandidate JSON', () {
    test('toJson/fromJson 왕복', () {
      final json =
          jsonDecode(jsonEncode(candidate.toJson())) as Map<String, dynamic>;
      expect(json['title'], '팀 워크숍');
      expect(json['extractor'], 'gemini');
      expect(json['allDay'], isFalse);
      expect(ScheduleCandidate.fromJson(json), candidate);
    });

    test('기본값: allDay=false, extractor=rule, recurrence=null', () {
      final c = ScheduleCandidate.fromJson({
        'id': 'x',
        'title': '일정',
        'start': '2026-11-05T15:00:00.000',
        'end': '2026-11-05T16:00:00.000',
        'sourceText': 't',
        'sourceApp': 'sms',
      });
      expect(c.allDay, isFalse);
      expect(c.extractor, ExtractorKind.rule);
      expect(c.isRecurring, isFalse);
      expect(c.duration, const Duration(hours: 1));
    });
  });

  group('drift 매핑', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.withExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('후보 저장 → 조회 → 모델 복원 및 상태 갱신', () async {
      await db.upsertCandidate(
        candidate.toCompanion(createdAt: DateTime(2026, 11, 4, 10)),
      );

      final row = await db.getCandidate('abc-123');
      expect(row, isNotNull);
      final record = row!.toRecord();
      expect(record.candidate, candidate);
      expect(record.status, CandidateStatus.pending);
      expect(record.isPending, isTrue);

      await db.updateCandidateStatus(
        'abc-123',
        CandidateStatus.confirmed,
        calendarEventId: '42',
      );
      final updated = (await db.getCandidate('abc-123'))!.toRecord();
      expect(updated.status, CandidateStatus.confirmed);
      expect(updated.calendarEventId, '42');

      final list = await db.watchCandidates().first;
      expect(list.map((r) => r.id), ['abc-123']);
    });
  });

  group('CalendarEventInput 변환', () {
    test('시간 지정 이벤트는 epoch millis 와 RRULE 을 그대로 넘긴다', () {
      final input = CalendarRepository.toEventInput(candidate, calendarId: 7);
      expect(input, isA<CalendarEventInput>());
      expect(input.calendarId, 7);
      expect(input.title, '팀 워크숍');
      expect(input.allDay, isFalse);
      expect(input.startMillis, candidate.start.millisecondsSinceEpoch);
      expect(input.endMillis, candidate.end.millisecondsSinceEpoch);
      expect(input.rrule, 'FREQ=WEEKLY;BYDAY=FR;COUNT=4');
      expect(input.description, contains('회의실 A'));
      expect(input.description, contains('debug'));
    });

    test('종일 이벤트는 UTC 자정으로 변환', () {
      final allDay = candidate.copyWith(
        allDay: true,
        start: DateTime(2026, 11, 20),
        end: DateTime(2026, 11, 21),
        recurrence: null,
      );
      final input = CalendarRepository.toEventInput(allDay, calendarId: 1);
      expect(input.allDay, isTrue);
      expect(
        input.startMillis,
        DateTime.utc(2026, 11, 20).millisecondsSinceEpoch,
      );
      expect(
        input.endMillis,
        DateTime.utc(2026, 11, 21).millisecondsSinceEpoch,
      );
      expect(input.rrule, isNull);
    });
  });
}
