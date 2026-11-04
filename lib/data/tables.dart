import 'package:drift/drift.dart';

/// 모든 외부 네트워크 시도 기록. 요청/응답 본문은 절대 저장하지 않는다.
class AuditLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get host => text()();
  TextColumn get method => text()();
  BoolColumn get allowed => boolean()();

  /// 차단 사유 (`host_not_allowed`, `external_transfer_disabled`, …). 허용 시 null.
  TextColumn get reason => text().nullable()();

  /// 요청 본문 바이트 수(본문 자체가 아님).
  IntColumn get requestBytes => integer().withDefault(const Constant(0))();
}

/// 추출된 일정 후보와 사용자 검토 상태.
class Candidates extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime()();
  BoolColumn get allDay => boolean().withDefault(const Constant(false))();
  TextColumn get recurrence => text().nullable()();
  TextColumn get details => text().nullable()();
  TextColumn get sourceText => text()();
  TextColumn get sourceApp => text()();

  /// `rule` | `gemini`
  TextColumn get extractor => text()();

  /// `pending` | `confirmed` | `cancelled`
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get calendarEventId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 단순 키-값 설정 (민감하지 않은 값만; Gemini 키는 flutter_secure_storage).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
