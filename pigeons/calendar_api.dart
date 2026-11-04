// Pigeon 정의: Dart ↔ Kotlin 캘린더 채널.
//
// 생성:  dart run pigeon --input pigeons/calendar_api.dart
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/pigeon/calendar_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/com/calltotodo/call_to_todo/CalendarApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.calltotodo.call_to_todo'),
    dartPackageName: 'call_to_todo',
  ),
)
library;

import 'package:pigeon/pigeon.dart';

/// 기기에 등록된, 쓰기 가능한 캘린더 하나 (CalendarContract.Calendars).
class DeviceCalendar {
  DeviceCalendar({
    required this.id,
    required this.displayName,
    required this.accountName,
    required this.accountType,
    required this.color,
    required this.isPrimary,
  });

  int id;
  String displayName;
  String accountName;
  String accountType;
  int color;
  bool isPrimary;
}

/// 캘린더에 넣을 이벤트. 시각은 epoch millis(UTC 기준), 종일이면 자정(UTC).
/// 타임존은 Dart 와 Kotlin 이 같은 기기에서 돌기 때문에 네이티브 쪽 기본값을 쓴다.
class CalendarEventInput {
  CalendarEventInput({
    required this.calendarId,
    required this.title,
    required this.startMillis,
    required this.endMillis,
    required this.allDay,
    this.description,
    this.rrule,
  });

  int calendarId;
  String title;
  String? description;
  int startMillis;
  int endMillis;
  bool allDay;

  /// RFC 5545 RRULE (`FREQ=WEEKLY;BYDAY=MO`). 없으면 null.
  String? rrule;
}

@HostApi()
abstract class CalendarHostApi {
  bool hasCalendarPermission();

  /// READ/WRITE_CALENDAR 런타임 권한 요청. 사용자가 응답하면 결과를 돌려준다.
  @async
  bool requestCalendarPermission();

  List<DeviceCalendar> listWritableCalendars();

  /// 이벤트를 삽입하고 CalendarContract 의 event id 를 돌려준다.
  String insertEvent(CalendarEventInput event);
}
