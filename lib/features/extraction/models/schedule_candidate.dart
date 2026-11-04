import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_candidate.freezed.dart';
part 'schedule_candidate.g.dart';

/// 후보를 만든 추출기.
enum ExtractorKind {
  /// 로컬 한국어 규칙 파서만 사용 (외부 전송 없음).
  rule,

  /// Gemini API 로 추출 (프리필터를 거친 문장만 전송).
  gemini,
}

/// 텍스트에서 추출된 일정 후보. Review 화면에서 사용자가 확인/수정한 뒤
/// 캘린더에 기록된다.
@freezed
abstract class ScheduleCandidate with _$ScheduleCandidate {
  const ScheduleCandidate._();

  const factory ScheduleCandidate({
    required String id,
    required String title,
    required DateTime start,
    required DateTime end,
    @Default(false) bool allDay,

    /// iCalendar RRULE (예: `FREQ=WEEKLY;BYDAY=MO`). 단발 일정은 null.
    String? recurrence,
    String? details,

    /// 후보의 근거가 된 원문(캡처 소스에서 받은 텍스트 전체).
    required String sourceText,

    /// 원문 출처 (예: `debug`, `kakao`, `sms`, `call`).
    required String sourceApp,
    @Default(ExtractorKind.rule) ExtractorKind extractor,
  }) = _ScheduleCandidate;

  factory ScheduleCandidate.fromJson(Map<String, dynamic> json) =>
      _$ScheduleCandidateFromJson(json);

  Duration get duration => end.difference(start);

  bool get isRecurring => recurrence != null && recurrence!.isNotEmpty;
}
