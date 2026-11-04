// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScheduleCandidate {

 String get id; String get title; DateTime get start; DateTime get end; bool get allDay;/// iCalendar RRULE (예: `FREQ=WEEKLY;BYDAY=MO`). 단발 일정은 null.
 String? get recurrence; String? get details;/// 후보의 근거가 된 원문(캡처 소스에서 받은 텍스트 전체).
 String get sourceText;/// 원문 출처 (예: `debug`, `kakao`, `sms`, `call`).
 String get sourceApp; ExtractorKind get extractor;
/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleCandidateCopyWith<ScheduleCandidate> get copyWith => _$ScheduleCandidateCopyWithImpl<ScheduleCandidate>(this as ScheduleCandidate, _$identity);

  /// Serializes this ScheduleCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScheduleCandidate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleCandidate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.allDay, _this.allDay) || other.allDay == _this.allDay)&&(identical(other.recurrence, _this.recurrence) || other.recurrence == _this.recurrence)&&(identical(other.details, _this.details) || other.details == _this.details)&&(identical(other.sourceText, _this.sourceText) || other.sourceText == _this.sourceText)&&(identical(other.sourceApp, _this.sourceApp) || other.sourceApp == _this.sourceApp)&&(identical(other.extractor, _this.extractor) || other.extractor == _this.extractor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScheduleCandidate;
  return Object.hash(runtimeType,_this.id,_this.title,_this.start,_this.end,_this.allDay,_this.recurrence,_this.details,_this.sourceText,_this.sourceApp,_this.extractor);
}

@override
String toString() {
  final _this = this as ScheduleCandidate;
  return 'ScheduleCandidate(id: ${_this.id}, title: ${_this.title}, start: ${_this.start}, end: ${_this.end}, allDay: ${_this.allDay}, recurrence: ${_this.recurrence}, details: ${_this.details}, sourceText: ${_this.sourceText}, sourceApp: ${_this.sourceApp}, extractor: ${_this.extractor})';
}


}

/// @nodoc
abstract mixin class $ScheduleCandidateCopyWith<$Res>  {
  factory $ScheduleCandidateCopyWith(ScheduleCandidate value, $Res Function(ScheduleCandidate) _then) = _$ScheduleCandidateCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime start, DateTime end, bool allDay, String? recurrence, String? details, String sourceText, String sourceApp, ExtractorKind extractor
});




}
/// @nodoc
class _$ScheduleCandidateCopyWithImpl<$Res>
    implements $ScheduleCandidateCopyWith<$Res> {
  _$ScheduleCandidateCopyWithImpl(this._self, this._then);

  final ScheduleCandidate _self;
  final $Res Function(ScheduleCandidate) _then;

/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? start = null,Object? end = null,Object? allDay = null,Object? recurrence = freezed,Object? details = freezed,Object? sourceText = null,Object? sourceApp = null,Object? extractor = null,}) {
  return _then(ScheduleCandidate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,sourceText: null == sourceText ? _self.sourceText : sourceText // ignore: cast_nullable_to_non_nullable
as String,sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,extractor: null == extractor ? _self.extractor : extractor // ignore: cast_nullable_to_non_nullable
as ExtractorKind,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleCandidate].
extension ScheduleCandidatePatterns on ScheduleCandidate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleCandidate value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleCandidate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime start,  DateTime end,  bool allDay,  String? recurrence,  String? details,  String sourceText,  String sourceApp,  ExtractorKind extractor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
return $default(_that.id,_that.title,_that.start,_that.end,_that.allDay,_that.recurrence,_that.details,_that.sourceText,_that.sourceApp,_that.extractor);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime start,  DateTime end,  bool allDay,  String? recurrence,  String? details,  String sourceText,  String sourceApp,  ExtractorKind extractor)  $default,) {final _that = this;
switch (_that) {
case _ScheduleCandidate():
return $default(_that.id,_that.title,_that.start,_that.end,_that.allDay,_that.recurrence,_that.details,_that.sourceText,_that.sourceApp,_that.extractor);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime start,  DateTime end,  bool allDay,  String? recurrence,  String? details,  String sourceText,  String sourceApp,  ExtractorKind extractor)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleCandidate() when $default != null:
return $default(_that.id,_that.title,_that.start,_that.end,_that.allDay,_that.recurrence,_that.details,_that.sourceText,_that.sourceApp,_that.extractor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleCandidate extends ScheduleCandidate {
  const _ScheduleCandidate({required this.id, required this.title, required this.start, required this.end, this.allDay = false, this.recurrence, this.details, required this.sourceText, required this.sourceApp, this.extractor = ExtractorKind.rule}): super._();
  factory _ScheduleCandidate.fromJson(Map<String, dynamic> json) => _$ScheduleCandidateFromJson(json);

@override final  String id;
@override final  String title;
@override final  DateTime start;
@override final  DateTime end;
@override@JsonKey() final  bool allDay;
/// iCalendar RRULE (예: `FREQ=WEEKLY;BYDAY=MO`). 단발 일정은 null.
@override final  String? recurrence;
@override final  String? details;
/// 후보의 근거가 된 원문(캡처 소스에서 받은 텍스트 전체).
@override final  String sourceText;
/// 원문 출처 (예: `debug`, `kakao`, `sms`, `call`).
@override final  String sourceApp;
@override@JsonKey() final  ExtractorKind extractor;

/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleCandidateCopyWith<_ScheduleCandidate> get copyWith => __$ScheduleCandidateCopyWithImpl<_ScheduleCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleCandidate&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.allDay, allDay) || other.allDay == allDay)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.details, details) || other.details == details)&&(identical(other.sourceText, sourceText) || other.sourceText == sourceText)&&(identical(other.sourceApp, sourceApp) || other.sourceApp == sourceApp)&&(identical(other.extractor, extractor) || other.extractor == extractor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,start,end,allDay,recurrence,details,sourceText,sourceApp,extractor);
}

@override
String toString() {
    return 'ScheduleCandidate(id: $id, title: $title, start: $start, end: $end, allDay: $allDay, recurrence: $recurrence, details: $details, sourceText: $sourceText, sourceApp: $sourceApp, extractor: $extractor)';
}


}

/// @nodoc
abstract mixin class _$ScheduleCandidateCopyWith<$Res> implements $ScheduleCandidateCopyWith<$Res> {
  factory _$ScheduleCandidateCopyWith(_ScheduleCandidate value, $Res Function(_ScheduleCandidate) _then) = __$ScheduleCandidateCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime start, DateTime end, bool allDay, String? recurrence, String? details, String sourceText, String sourceApp, ExtractorKind extractor
});




}
/// @nodoc
class __$ScheduleCandidateCopyWithImpl<$Res>
    implements _$ScheduleCandidateCopyWith<$Res> {
  __$ScheduleCandidateCopyWithImpl(this._self, this._then);

  final _ScheduleCandidate _self;
  final $Res Function(_ScheduleCandidate) _then;

/// Create a copy of ScheduleCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? start = null,Object? end = null,Object? allDay = null,Object? recurrence = freezed,Object? details = freezed,Object? sourceText = null,Object? sourceApp = null,Object? extractor = null,}) {
  return _then(_ScheduleCandidate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,allDay: null == allDay ? _self.allDay : allDay // ignore: cast_nullable_to_non_nullable
as bool,recurrence: freezed == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String?,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,sourceText: null == sourceText ? _self.sourceText : sourceText // ignore: cast_nullable_to_non_nullable
as String,sourceApp: null == sourceApp ? _self.sourceApp : sourceApp // ignore: cast_nullable_to_non_nullable
as String,extractor: null == extractor ? _self.extractor : extractor // ignore: cast_nullable_to_non_nullable
as ExtractorKind,
  ));
}


}

// dart format on
