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

/// 수집 로그 (3단계). 메시지 **본문은 저장하지 않는다** — 출처·시각·결과만.
/// 후보가 만들어졌으면 `candidates` 행 ID 로 이어지며, 원문은 거기서만 볼 수 있다.
class CaptureLog extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `notification` | `sms`
  TextColumn get source => text()();

  /// 패키지 이름(알림) 또는 `sms`(옵저버).
  TextColumn get sourceApp => text()();

  /// 메시지 시각(알림 게시·SMS 수신).
  DateTimeColumn get messageAt => dateTime()();

  /// 파이프라인이 처리한 시각.
  DateTimeColumn get processedAt => dateTime()();

  /// `processed` | `duplicate` | `disabled` | `empty` | `error`
  TextColumn get status => text()();
  IntColumn get candidateCount => integer().withDefault(const Constant(0))();

  /// 만들어진 후보 ID 들 (`,` 구분). 없으면 null.
  TextColumn get candidateIds => text().nullable()();

  /// 본문 글자 수(본문 자체가 아님).
  IntColumn get textLength => integer().withDefault(const Constant(0))();

  /// 중복 판정용 해시. 본문을 복원할 수 없다.
  TextColumn get dedupeKey => text()();
}

/// 단순 키-값 설정 (민감하지 않은 값만; Gemini 키는 flutter_secure_storage).
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
