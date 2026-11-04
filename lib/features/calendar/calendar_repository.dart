import '../../core/pigeon/calendar_api.g.dart';
import '../extraction/models/schedule_candidate.dart';

export '../../core/pigeon/calendar_api.g.dart' show DeviceCalendar;

/// 캘린더 권한이 없을 때.
class CalendarPermissionDeniedException implements Exception {
  const CalendarPermissionDeniedException();

  @override
  String toString() => '캘린더 권한이 거부되었습니다.';
}

/// Pigeon [CalendarHostApi] 를 감싸 Dart 모델로 노출한다.
///
/// 기기 캘린더(CalendarContract)에만 쓰며, 구글 REST API 는 사용하지 않는다.
class CalendarRepository {
  CalendarRepository({CalendarHostApi? api}) : _api = api ?? CalendarHostApi();

  final CalendarHostApi _api;

  Future<bool> hasPermission() => _api.hasCalendarPermission();

  /// 권한이 없으면 요청하고, 최종적으로 허용됐는지 돌려준다.
  Future<bool> ensurePermission() async {
    if (await _api.hasCalendarPermission()) return true;
    return _api.requestCalendarPermission();
  }

  Future<List<DeviceCalendar>> listWritableCalendars() async {
    if (!await ensurePermission()) {
      throw const CalendarPermissionDeniedException();
    }
    return _api.listWritableCalendars();
  }

  /// [candidate] 를 [calendarId] 캘린더에 삽입하고 이벤트 ID 를 돌려준다.
  Future<String> insertCandidate(
    ScheduleCandidate candidate, {
    required int calendarId,
  }) async {
    if (!await ensurePermission()) {
      throw const CalendarPermissionDeniedException();
    }
    return _api.insertEvent(toEventInput(candidate, calendarId: calendarId));
  }

  /// 후보 → CalendarContract 입력. 종일 이벤트는 UTC 자정 기준으로 변환한다.
  static CalendarEventInput toEventInput(
    ScheduleCandidate candidate, {
    required int calendarId,
  }) {
    final start = candidate.start;
    final end = candidate.end;
    final startMillis = candidate.allDay
        ? DateTime.utc(
            start.year,
            start.month,
            start.day,
          ).millisecondsSinceEpoch
        : start.millisecondsSinceEpoch;
    final endMillis = candidate.allDay
        ? DateTime.utc(end.year, end.month, end.day).millisecondsSinceEpoch
        : end.millisecondsSinceEpoch;

    return CalendarEventInput(
      calendarId: calendarId,
      title: candidate.title,
      description: _description(candidate),
      startMillis: startMillis,
      endMillis: endMillis,
      allDay: candidate.allDay,
      rrule: candidate.recurrence,
    );
  }

  static String? _description(ScheduleCandidate candidate) {
    final parts = <String>[
      if (candidate.details != null && candidate.details!.trim().isNotEmpty)
        candidate.details!.trim(),
      '출처: ${candidate.sourceApp} (Call to To-do)',
    ];
    return parts.join('\n\n');
  }
}
