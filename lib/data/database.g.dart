// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AuditLogTable extends AuditLog
    with TableInfo<$AuditLogTable, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowedMeta = const VerificationMeta(
    'allowed',
  );
  @override
  late final GeneratedColumn<bool> allowed = GeneratedColumn<bool>(
    'allowed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allowed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestBytesMeta = const VerificationMeta(
    'requestBytes',
  );
  @override
  late final GeneratedColumn<int> requestBytes = GeneratedColumn<int>(
    'request_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    host,
    method,
    allowed,
    reason,
    requestBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('allowed')) {
      context.handle(
        _allowedMeta,
        allowed.isAcceptableOrUnknown(data['allowed']!, _allowedMeta),
      );
    } else if (isInserting) {
      context.missing(_allowedMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('request_bytes')) {
      context.handle(
        _requestBytesMeta,
        requestBytes.isAcceptableOrUnknown(
          data['request_bytes']!,
          _requestBytesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      allowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allowed'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      requestBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_bytes'],
      )!,
    );
  }

  @override
  $AuditLogTable createAlias(String alias) {
    return $AuditLogTable(attachedDatabase, alias);
  }
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final int id;
  final DateTime timestamp;
  final String host;
  final String method;
  final bool allowed;

  /// 차단 사유 (`host_not_allowed`, `external_transfer_disabled`, …). 허용 시 null.
  final String? reason;

  /// 요청 본문 바이트 수(본문 자체가 아님).
  final int requestBytes;
  const AuditLogData({
    required this.id,
    required this.timestamp,
    required this.host,
    required this.method,
    required this.allowed,
    this.reason,
    required this.requestBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['host'] = Variable<String>(host);
    map['method'] = Variable<String>(method);
    map['allowed'] = Variable<bool>(allowed);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['request_bytes'] = Variable<int>(requestBytes);
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      host: Value(host),
      method: Value(method),
      allowed: Value(allowed),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      requestBytes: Value(requestBytes),
    );
  }

  factory AuditLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      host: serializer.fromJson<String>(json['host']),
      method: serializer.fromJson<String>(json['method']),
      allowed: serializer.fromJson<bool>(json['allowed']),
      reason: serializer.fromJson<String?>(json['reason']),
      requestBytes: serializer.fromJson<int>(json['requestBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'host': serializer.toJson<String>(host),
      'method': serializer.toJson<String>(method),
      'allowed': serializer.toJson<bool>(allowed),
      'reason': serializer.toJson<String?>(reason),
      'requestBytes': serializer.toJson<int>(requestBytes),
    };
  }

  AuditLogData copyWith({
    int? id,
    DateTime? timestamp,
    String? host,
    String? method,
    bool? allowed,
    Value<String?> reason = const Value.absent(),
    int? requestBytes,
  }) => AuditLogData(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    host: host ?? this.host,
    method: method ?? this.method,
    allowed: allowed ?? this.allowed,
    reason: reason.present ? reason.value : this.reason,
    requestBytes: requestBytes ?? this.requestBytes,
  );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      host: data.host.present ? data.host.value : this.host,
      method: data.method.present ? data.method.value : this.method,
      allowed: data.allowed.present ? data.allowed.value : this.allowed,
      reason: data.reason.present ? data.reason.value : this.reason,
      requestBytes: data.requestBytes.present
          ? data.requestBytes.value
          : this.requestBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('host: $host, ')
          ..write('method: $method, ')
          ..write('allowed: $allowed, ')
          ..write('reason: $reason, ')
          ..write('requestBytes: $requestBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, timestamp, host, method, allowed, reason, requestBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.host == this.host &&
          other.method == this.method &&
          other.allowed == this.allowed &&
          other.reason == this.reason &&
          other.requestBytes == this.requestBytes);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<String> host;
  final Value<String> method;
  final Value<bool> allowed;
  final Value<String?> reason;
  final Value<int> requestBytes;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.host = const Value.absent(),
    this.method = const Value.absent(),
    this.allowed = const Value.absent(),
    this.reason = const Value.absent(),
    this.requestBytes = const Value.absent(),
  });
  AuditLogCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required String host,
    required String method,
    required bool allowed,
    this.reason = const Value.absent(),
    this.requestBytes = const Value.absent(),
  }) : timestamp = Value(timestamp),
       host = Value(host),
       method = Value(method),
       allowed = Value(allowed);
  static Insertable<AuditLogData> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? host,
    Expression<String>? method,
    Expression<bool>? allowed,
    Expression<String>? reason,
    Expression<int>? requestBytes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (host != null) 'host': host,
      if (method != null) 'method': method,
      if (allowed != null) 'allowed': allowed,
      if (reason != null) 'reason': reason,
      if (requestBytes != null) 'request_bytes': requestBytes,
    });
  }

  AuditLogCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<String>? host,
    Value<String>? method,
    Value<bool>? allowed,
    Value<String?>? reason,
    Value<int>? requestBytes,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      host: host ?? this.host,
      method: method ?? this.method,
      allowed: allowed ?? this.allowed,
      reason: reason ?? this.reason,
      requestBytes: requestBytes ?? this.requestBytes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (allowed.present) {
      map['allowed'] = Variable<bool>(allowed.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (requestBytes.present) {
      map['request_bytes'] = Variable<int>(requestBytes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('host: $host, ')
          ..write('method: $method, ')
          ..write('allowed: $allowed, ')
          ..write('reason: $reason, ')
          ..write('requestBytes: $requestBytes')
          ..write(')'))
        .toString();
  }
}

class $CandidatesTable extends Candidates
    with TableInfo<$CandidatesTable, Candidate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CandidatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMeta = const VerificationMeta('start');
  @override
  late final GeneratedColumn<DateTime> start = GeneratedColumn<DateTime>(
    'start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMeta = const VerificationMeta('end');
  @override
  late final GeneratedColumn<DateTime> end = GeneratedColumn<DateTime>(
    'end',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allDayMeta = const VerificationMeta('allDay');
  @override
  late final GeneratedColumn<bool> allDay = GeneratedColumn<bool>(
    'all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTextMeta = const VerificationMeta(
    'sourceText',
  );
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
    'source_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceAppMeta = const VerificationMeta(
    'sourceApp',
  );
  @override
  late final GeneratedColumn<String> sourceApp = GeneratedColumn<String>(
    'source_app',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extractorMeta = const VerificationMeta(
    'extractor',
  );
  @override
  late final GeneratedColumn<String> extractor = GeneratedColumn<String>(
    'extractor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _calendarEventIdMeta = const VerificationMeta(
    'calendarEventId',
  );
  @override
  late final GeneratedColumn<String> calendarEventId = GeneratedColumn<String>(
    'calendar_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    start,
    end,
    allDay,
    recurrence,
    details,
    sourceText,
    sourceApp,
    extractor,
    status,
    calendarEventId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'candidates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Candidate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start')) {
      context.handle(
        _startMeta,
        start.isAcceptableOrUnknown(data['start']!, _startMeta),
      );
    } else if (isInserting) {
      context.missing(_startMeta);
    }
    if (data.containsKey('end')) {
      context.handle(
        _endMeta,
        end.isAcceptableOrUnknown(data['end']!, _endMeta),
      );
    } else if (isInserting) {
      context.missing(_endMeta);
    }
    if (data.containsKey('all_day')) {
      context.handle(
        _allDayMeta,
        allDay.isAcceptableOrUnknown(data['all_day']!, _allDayMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('source_text')) {
      context.handle(
        _sourceTextMeta,
        sourceText.isAcceptableOrUnknown(data['source_text']!, _sourceTextMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTextMeta);
    }
    if (data.containsKey('source_app')) {
      context.handle(
        _sourceAppMeta,
        sourceApp.isAcceptableOrUnknown(data['source_app']!, _sourceAppMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceAppMeta);
    }
    if (data.containsKey('extractor')) {
      context.handle(
        _extractorMeta,
        extractor.isAcceptableOrUnknown(data['extractor']!, _extractorMeta),
      );
    } else if (isInserting) {
      context.missing(_extractorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('calendar_event_id')) {
      context.handle(
        _calendarEventIdMeta,
        calendarEventId.isAcceptableOrUnknown(
          data['calendar_event_id']!,
          _calendarEventIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Candidate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Candidate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      start: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start'],
      )!,
      end: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end'],
      )!,
      allDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}all_day'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      ),
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      sourceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_text'],
      )!,
      sourceApp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_app'],
      )!,
      extractor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extractor'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      calendarEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_event_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CandidatesTable createAlias(String alias) {
    return $CandidatesTable(attachedDatabase, alias);
  }
}

class Candidate extends DataClass implements Insertable<Candidate> {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final String? recurrence;
  final String? details;
  final String sourceText;
  final String sourceApp;

  /// `rule` | `gemini`
  final String extractor;

  /// `pending` | `confirmed` | `cancelled`
  final String status;
  final String? calendarEventId;
  final DateTime createdAt;
  const Candidate({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
    this.recurrence,
    this.details,
    required this.sourceText,
    required this.sourceApp,
    required this.extractor,
    required this.status,
    this.calendarEventId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['start'] = Variable<DateTime>(start);
    map['end'] = Variable<DateTime>(end);
    map['all_day'] = Variable<bool>(allDay);
    if (!nullToAbsent || recurrence != null) {
      map['recurrence'] = Variable<String>(recurrence);
    }
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    map['source_text'] = Variable<String>(sourceText);
    map['source_app'] = Variable<String>(sourceApp);
    map['extractor'] = Variable<String>(extractor);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || calendarEventId != null) {
      map['calendar_event_id'] = Variable<String>(calendarEventId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CandidatesCompanion toCompanion(bool nullToAbsent) {
    return CandidatesCompanion(
      id: Value(id),
      title: Value(title),
      start: Value(start),
      end: Value(end),
      allDay: Value(allDay),
      recurrence: recurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrence),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      sourceText: Value(sourceText),
      sourceApp: Value(sourceApp),
      extractor: Value(extractor),
      status: Value(status),
      calendarEventId: calendarEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarEventId),
      createdAt: Value(createdAt),
    );
  }

  factory Candidate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Candidate(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      start: serializer.fromJson<DateTime>(json['start']),
      end: serializer.fromJson<DateTime>(json['end']),
      allDay: serializer.fromJson<bool>(json['allDay']),
      recurrence: serializer.fromJson<String?>(json['recurrence']),
      details: serializer.fromJson<String?>(json['details']),
      sourceText: serializer.fromJson<String>(json['sourceText']),
      sourceApp: serializer.fromJson<String>(json['sourceApp']),
      extractor: serializer.fromJson<String>(json['extractor']),
      status: serializer.fromJson<String>(json['status']),
      calendarEventId: serializer.fromJson<String?>(json['calendarEventId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'start': serializer.toJson<DateTime>(start),
      'end': serializer.toJson<DateTime>(end),
      'allDay': serializer.toJson<bool>(allDay),
      'recurrence': serializer.toJson<String?>(recurrence),
      'details': serializer.toJson<String?>(details),
      'sourceText': serializer.toJson<String>(sourceText),
      'sourceApp': serializer.toJson<String>(sourceApp),
      'extractor': serializer.toJson<String>(extractor),
      'status': serializer.toJson<String>(status),
      'calendarEventId': serializer.toJson<String?>(calendarEventId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Candidate copyWith({
    String? id,
    String? title,
    DateTime? start,
    DateTime? end,
    bool? allDay,
    Value<String?> recurrence = const Value.absent(),
    Value<String?> details = const Value.absent(),
    String? sourceText,
    String? sourceApp,
    String? extractor,
    String? status,
    Value<String?> calendarEventId = const Value.absent(),
    DateTime? createdAt,
  }) => Candidate(
    id: id ?? this.id,
    title: title ?? this.title,
    start: start ?? this.start,
    end: end ?? this.end,
    allDay: allDay ?? this.allDay,
    recurrence: recurrence.present ? recurrence.value : this.recurrence,
    details: details.present ? details.value : this.details,
    sourceText: sourceText ?? this.sourceText,
    sourceApp: sourceApp ?? this.sourceApp,
    extractor: extractor ?? this.extractor,
    status: status ?? this.status,
    calendarEventId: calendarEventId.present
        ? calendarEventId.value
        : this.calendarEventId,
    createdAt: createdAt ?? this.createdAt,
  );
  Candidate copyWithCompanion(CandidatesCompanion data) {
    return Candidate(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      start: data.start.present ? data.start.value : this.start,
      end: data.end.present ? data.end.value : this.end,
      allDay: data.allDay.present ? data.allDay.value : this.allDay,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      details: data.details.present ? data.details.value : this.details,
      sourceText: data.sourceText.present
          ? data.sourceText.value
          : this.sourceText,
      sourceApp: data.sourceApp.present ? data.sourceApp.value : this.sourceApp,
      extractor: data.extractor.present ? data.extractor.value : this.extractor,
      status: data.status.present ? data.status.value : this.status,
      calendarEventId: data.calendarEventId.present
          ? data.calendarEventId.value
          : this.calendarEventId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Candidate(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('allDay: $allDay, ')
          ..write('recurrence: $recurrence, ')
          ..write('details: $details, ')
          ..write('sourceText: $sourceText, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('extractor: $extractor, ')
          ..write('status: $status, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    start,
    end,
    allDay,
    recurrence,
    details,
    sourceText,
    sourceApp,
    extractor,
    status,
    calendarEventId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Candidate &&
          other.id == this.id &&
          other.title == this.title &&
          other.start == this.start &&
          other.end == this.end &&
          other.allDay == this.allDay &&
          other.recurrence == this.recurrence &&
          other.details == this.details &&
          other.sourceText == this.sourceText &&
          other.sourceApp == this.sourceApp &&
          other.extractor == this.extractor &&
          other.status == this.status &&
          other.calendarEventId == this.calendarEventId &&
          other.createdAt == this.createdAt);
}

class CandidatesCompanion extends UpdateCompanion<Candidate> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> start;
  final Value<DateTime> end;
  final Value<bool> allDay;
  final Value<String?> recurrence;
  final Value<String?> details;
  final Value<String> sourceText;
  final Value<String> sourceApp;
  final Value<String> extractor;
  final Value<String> status;
  final Value<String?> calendarEventId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CandidatesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.start = const Value.absent(),
    this.end = const Value.absent(),
    this.allDay = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.details = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.sourceApp = const Value.absent(),
    this.extractor = const Value.absent(),
    this.status = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CandidatesCompanion.insert({
    required String id,
    required String title,
    required DateTime start,
    required DateTime end,
    this.allDay = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.details = const Value.absent(),
    required String sourceText,
    required String sourceApp,
    required String extractor,
    this.status = const Value.absent(),
    this.calendarEventId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       start = Value(start),
       end = Value(end),
       sourceText = Value(sourceText),
       sourceApp = Value(sourceApp),
       extractor = Value(extractor),
       createdAt = Value(createdAt);
  static Insertable<Candidate> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? start,
    Expression<DateTime>? end,
    Expression<bool>? allDay,
    Expression<String>? recurrence,
    Expression<String>? details,
    Expression<String>? sourceText,
    Expression<String>? sourceApp,
    Expression<String>? extractor,
    Expression<String>? status,
    Expression<String>? calendarEventId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (allDay != null) 'all_day': allDay,
      if (recurrence != null) 'recurrence': recurrence,
      if (details != null) 'details': details,
      if (sourceText != null) 'source_text': sourceText,
      if (sourceApp != null) 'source_app': sourceApp,
      if (extractor != null) 'extractor': extractor,
      if (status != null) 'status': status,
      if (calendarEventId != null) 'calendar_event_id': calendarEventId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CandidatesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<DateTime>? start,
    Value<DateTime>? end,
    Value<bool>? allDay,
    Value<String?>? recurrence,
    Value<String?>? details,
    Value<String>? sourceText,
    Value<String>? sourceApp,
    Value<String>? extractor,
    Value<String>? status,
    Value<String?>? calendarEventId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CandidatesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      allDay: allDay ?? this.allDay,
      recurrence: recurrence ?? this.recurrence,
      details: details ?? this.details,
      sourceText: sourceText ?? this.sourceText,
      sourceApp: sourceApp ?? this.sourceApp,
      extractor: extractor ?? this.extractor,
      status: status ?? this.status,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (start.present) {
      map['start'] = Variable<DateTime>(start.value);
    }
    if (end.present) {
      map['end'] = Variable<DateTime>(end.value);
    }
    if (allDay.present) {
      map['all_day'] = Variable<bool>(allDay.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (sourceApp.present) {
      map['source_app'] = Variable<String>(sourceApp.value);
    }
    if (extractor.present) {
      map['extractor'] = Variable<String>(extractor.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (calendarEventId.present) {
      map['calendar_event_id'] = Variable<String>(calendarEventId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CandidatesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('start: $start, ')
          ..write('end: $end, ')
          ..write('allDay: $allDay, ')
          ..write('recurrence: $recurrence, ')
          ..write('details: $details, ')
          ..write('sourceText: $sourceText, ')
          ..write('sourceApp: $sourceApp, ')
          ..write('extractor: $extractor, ')
          ..write('status: $status, ')
          ..write('calendarEventId: $calendarEventId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AuditLogTable auditLog = $AuditLogTable(this);
  late final $CandidatesTable candidates = $CandidatesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    auditLog,
    candidates,
    settings,
  ];
}

typedef $$AuditLogTableCreateCompanionBuilder = AuditLogCompanion Function({
  Value<int> id,
  required DateTime timestamp,
  required String host,
  required String method,
  required bool allowed,
  Value<String?> reason,
  Value<int> requestBytes,
});
typedef $$AuditLogTableUpdateCompanionBuilder = AuditLogCompanion Function({
  Value<int> id,
  Value<DateTime> timestamp,
  Value<String> host,
  Value<String> method,
  Value<bool> allowed,
  Value<String?> reason,
  Value<int> requestBytes,
});

class $$AuditLogTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowed => $composableBuilder(
    column: $table.allowed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestBytes => $composableBuilder(
    column: $table.requestBytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowed => $composableBuilder(
    column: $table.allowed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestBytes => $composableBuilder(
    column: $table.requestBytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogTable> {
  $$AuditLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<bool> get allowed =>
      $composableBuilder(column: $table.allowed, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get requestBytes => $composableBuilder(
    column: $table.requestBytes,
    builder: (column) => column,
  );
}

class $$AuditLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogTable,
          AuditLogData,
          $$AuditLogTableFilterComposer,
          $$AuditLogTableOrderingComposer,
          $$AuditLogTableAnnotationComposer,
          $$AuditLogTableCreateCompanionBuilder,
          $$AuditLogTableUpdateCompanionBuilder,
          (
            AuditLogData,
            BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>,
          ),
          AuditLogData,
          PrefetchHooks Function()
        > {
  $$AuditLogTableTableManager(_$AppDatabase db, $AuditLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<bool> allowed = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int> requestBytes = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                timestamp: timestamp,
                host: host,
                method: method,
                allowed: allowed,
                reason: reason,
                requestBytes: requestBytes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required String host,
                required String method,
                required bool allowed,
                Value<String?> reason = const Value.absent(),
                Value<int> requestBytes = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                timestamp: timestamp,
                host: host,
                method: method,
                allowed: allowed,
                reason: reason,
                requestBytes: requestBytes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogTable, AuditLogData>(table),
                  BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogTable,
      AuditLogData,
      $$AuditLogTableFilterComposer,
      $$AuditLogTableOrderingComposer,
      $$AuditLogTableAnnotationComposer,
      $$AuditLogTableCreateCompanionBuilder,
      $$AuditLogTableUpdateCompanionBuilder,
      (
        AuditLogData,
        BaseReferences<_$AppDatabase, $AuditLogTable, AuditLogData>,
      ),
      AuditLogData,
      PrefetchHooks Function()
    >;
typedef $$CandidatesTableCreateCompanionBuilder = CandidatesCompanion Function({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  Value<bool> allDay,
  Value<String?> recurrence,
  Value<String?> details,
  required String sourceText,
  required String sourceApp,
  required String extractor,
  Value<String> status,
  Value<String?> calendarEventId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CandidatesTableUpdateCompanionBuilder = CandidatesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> start,
  Value<DateTime> end,
  Value<bool> allDay,
  Value<String?> recurrence,
  Value<String?> details,
  Value<String> sourceText,
  Value<String> sourceApp,
  Value<String> extractor,
  Value<String> status,
  Value<String?> calendarEventId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CandidatesTableFilterComposer
    extends Composer<_$AppDatabase, $CandidatesTable> {
  $$CandidatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractor => $composableBuilder(
    column: $table.extractor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CandidatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CandidatesTable> {
  $$CandidatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get start => $composableBuilder(
    column: $table.start,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get end => $composableBuilder(
    column: $table.end,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allDay => $composableBuilder(
    column: $table.allDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceApp => $composableBuilder(
    column: $table.sourceApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractor => $composableBuilder(
    column: $table.extractor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CandidatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CandidatesTable> {
  $$CandidatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get start =>
      $composableBuilder(column: $table.start, builder: (column) => column);

  GeneratedColumn<DateTime> get end =>
      $composableBuilder(column: $table.end, builder: (column) => column);

  GeneratedColumn<bool> get allDay =>
      $composableBuilder(column: $table.allDay, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceApp =>
      $composableBuilder(column: $table.sourceApp, builder: (column) => column);

  GeneratedColumn<String> get extractor =>
      $composableBuilder(column: $table.extractor, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get calendarEventId => $composableBuilder(
    column: $table.calendarEventId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CandidatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CandidatesTable,
          Candidate,
          $$CandidatesTableFilterComposer,
          $$CandidatesTableOrderingComposer,
          $$CandidatesTableAnnotationComposer,
          $$CandidatesTableCreateCompanionBuilder,
          $$CandidatesTableUpdateCompanionBuilder,
          (
            Candidate,
            BaseReferences<_$AppDatabase, $CandidatesTable, Candidate>,
          ),
          Candidate,
          PrefetchHooks Function()
        > {
  $$CandidatesTableTableManager(_$AppDatabase db, $CandidatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CandidatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CandidatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CandidatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> start = const Value.absent(),
                Value<DateTime> end = const Value.absent(),
                Value<bool> allDay = const Value.absent(),
                Value<String?> recurrence = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String> sourceText = const Value.absent(),
                Value<String> sourceApp = const Value.absent(),
                Value<String> extractor = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CandidatesCompanion(
                id: id,
                title: title,
                start: start,
                end: end,
                allDay: allDay,
                recurrence: recurrence,
                details: details,
                sourceText: sourceText,
                sourceApp: sourceApp,
                extractor: extractor,
                status: status,
                calendarEventId: calendarEventId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required DateTime start,
                required DateTime end,
                Value<bool> allDay = const Value.absent(),
                Value<String?> recurrence = const Value.absent(),
                Value<String?> details = const Value.absent(),
                required String sourceText,
                required String sourceApp,
                required String extractor,
                Value<String> status = const Value.absent(),
                Value<String?> calendarEventId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CandidatesCompanion.insert(
                id: id,
                title: title,
                start: start,
                end: end,
                allDay: allDay,
                recurrence: recurrence,
                details: details,
                sourceText: sourceText,
                sourceApp: sourceApp,
                extractor: extractor,
                status: status,
                calendarEventId: calendarEventId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CandidatesTable, Candidate>(table),
                  BaseReferences<_$AppDatabase, $CandidatesTable, Candidate>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CandidatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CandidatesTable,
      Candidate,
      $$CandidatesTableFilterComposer,
      $$CandidatesTableOrderingComposer,
      $$CandidatesTableAnnotationComposer,
      $$CandidatesTableCreateCompanionBuilder,
      $$CandidatesTableUpdateCompanionBuilder,
      (Candidate, BaseReferences<_$AppDatabase, $CandidatesTable, Candidate>),
      Candidate,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AuditLogTableTableManager get auditLog =>
      $$AuditLogTableTableManager(_db, _db.auditLog);
  $$CandidatesTableTableManager get candidates =>
      $$CandidatesTableTableManager(_db, _db.candidates);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
