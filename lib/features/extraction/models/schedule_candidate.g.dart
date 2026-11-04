// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_candidate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleCandidate _$ScheduleCandidateFromJson(Map<String, dynamic> json) =>
    _ScheduleCandidate(
      id: json['id'] as String,
      title: json['title'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      allDay: json['allDay'] as bool? ?? false,
      recurrence: json['recurrence'] as String?,
      details: json['details'] as String?,
      sourceText: json['sourceText'] as String,
      sourceApp: json['sourceApp'] as String,
      extractor:
          $enumDecodeNullable(_$ExtractorKindEnumMap, json['extractor']) ??
          ExtractorKind.rule,
    );

Map<String, dynamic> _$ScheduleCandidateToJson(_ScheduleCandidate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'allDay': instance.allDay,
      'recurrence': instance.recurrence,
      'details': instance.details,
      'sourceText': instance.sourceText,
      'sourceApp': instance.sourceApp,
      'extractor': _$ExtractorKindEnumMap[instance.extractor]!,
    };

const _$ExtractorKindEnumMap = {
  ExtractorKind.rule: 'rule',
  ExtractorKind.gemini: 'gemini',
};
