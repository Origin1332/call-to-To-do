// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(secureStorage)
final secureStorageProvider = SecureStorageProvider._();

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'0cd1b80f91784467390034386f925a0be155bfbd';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'784816f471a9a3cc8f408fbbf9b5d8d7f51b897a';

@ProviderFor(networkPolicy)
final networkPolicyProvider = NetworkPolicyProvider._();

final class NetworkPolicyProvider
    extends $FunctionalProvider<NetworkPolicy, NetworkPolicy, NetworkPolicy>
    with $Provider<NetworkPolicy> {
  NetworkPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkPolicyHash();

  @$internal
  @override
  $ProviderElement<NetworkPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkPolicy create(Ref ref) {
    return networkPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkPolicy>(value),
    );
  }
}

String _$networkPolicyHash() => r'496eb5993ac467a32ed63efe6a20821bb72bfdd7';

@ProviderFor(auditSink)
final auditSinkProvider = AuditSinkProvider._();

final class AuditSinkProvider
    extends $FunctionalProvider<AuditSink, AuditSink, AuditSink>
    with $Provider<AuditSink> {
  AuditSinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditSinkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditSinkHash();

  @$internal
  @override
  $ProviderElement<AuditSink> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuditSink create(Ref ref) {
    return auditSink(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditSink value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditSink>(value),
    );
  }
}

String _$auditSinkHash() => r'8c646c44a44e7fbb57b0b20d0aa41fadcf88f132';

@ProviderFor(policyHttpClient)
final policyHttpClientProvider = PolicyHttpClientProvider._();

final class PolicyHttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  PolicyHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'policyHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$policyHttpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return policyHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$policyHttpClientHash() => r'360922f5ca88286db742e21ec5b5349771e5d97a';

@ProviderFor(extractionService)
final extractionServiceProvider = ExtractionServiceProvider._();

final class ExtractionServiceProvider
    extends
        $FunctionalProvider<
          ExtractionService,
          ExtractionService,
          ExtractionService
        >
    with $Provider<ExtractionService> {
  ExtractionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'extractionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$extractionServiceHash();

  @$internal
  @override
  $ProviderElement<ExtractionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExtractionService create(Ref ref) {
    return extractionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExtractionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExtractionService>(value),
    );
  }
}

String _$extractionServiceHash() => r'146deab78d1b7589f569df873481602fc0a014f0';

@ProviderFor(candidatePipeline)
final candidatePipelineProvider = CandidatePipelineProvider._();

final class CandidatePipelineProvider
    extends
        $FunctionalProvider<
          CandidatePipeline,
          CandidatePipeline,
          CandidatePipeline
        >
    with $Provider<CandidatePipeline> {
  CandidatePipelineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'candidatePipelineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$candidatePipelineHash();

  @$internal
  @override
  $ProviderElement<CandidatePipeline> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CandidatePipeline create(Ref ref) {
    return candidatePipeline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CandidatePipeline value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CandidatePipeline>(value),
    );
  }
}

String _$candidatePipelineHash() => r'e507911f9791f31edabcabdfbffa81d24a7c81a6';

@ProviderFor(calendarRepository)
final calendarRepositoryProvider = CalendarRepositoryProvider._();

final class CalendarRepositoryProvider
    extends
        $FunctionalProvider<
          CalendarRepository,
          CalendarRepository,
          CalendarRepository
        >
    with $Provider<CalendarRepository> {
  CalendarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarRepositoryHash();

  @$internal
  @override
  $ProviderElement<CalendarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalendarRepository create(Ref ref) {
    return calendarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarRepository>(value),
    );
  }
}

String _$calendarRepositoryHash() =>
    r'6f6ff51ea7e3511e3591347cc12f7181d33e52cd';

@ProviderFor(reviewNotifications)
final reviewNotificationsProvider = ReviewNotificationsProvider._();

final class ReviewNotificationsProvider
    extends
        $FunctionalProvider<
          ReviewNotifications,
          ReviewNotifications,
          ReviewNotifications
        >
    with $Provider<ReviewNotifications> {
  ReviewNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewNotificationsHash();

  @$internal
  @override
  $ProviderElement<ReviewNotifications> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewNotifications create(Ref ref) {
    return reviewNotifications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewNotifications value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewNotifications>(value),
    );
  }
}

String _$reviewNotificationsHash() =>
    r'f5b198ee40fc6066667825466d018c3b0e7e6d43';

@ProviderFor(externalTransferEnabled)
final externalTransferEnabledProvider = ExternalTransferEnabledProvider._();

final class ExternalTransferEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  ExternalTransferEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalTransferEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalTransferEnabledHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return externalTransferEnabled(ref);
  }
}

String _$externalTransferEnabledHash() =>
    r'421722ca1573adb7bfaa4fff3d7b150fcd1fa963';

@ProviderFor(geminiModel)
final geminiModelProvider = GeminiModelProvider._();

final class GeminiModelProvider
    extends $FunctionalProvider<AsyncValue<String>, String, Stream<String>>
    with $FutureModifier<String>, $StreamProvider<String> {
  GeminiModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiModelHash();

  @$internal
  @override
  $StreamProviderElement<String> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String> create(Ref ref) {
    return geminiModel(ref);
  }
}

String _$geminiModelHash() => r'e1a2d4cb4ab4d58c5af3f7f6101a9c94e3fb76d5';

@ProviderFor(geminiApiKey)
final geminiApiKeyProvider = GeminiApiKeyProvider._();

final class GeminiApiKeyProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  GeminiApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geminiApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geminiApiKeyHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return geminiApiKey(ref);
  }
}

String _$geminiApiKeyHash() => r'6c93b378a95461ab73390b2e0236fba978c81706';

@ProviderFor(candidateList)
final candidateListProvider = CandidateListProvider._();

final class CandidateListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CandidateRecord>>,
          List<CandidateRecord>,
          Stream<List<CandidateRecord>>
        >
    with
        $FutureModifier<List<CandidateRecord>>,
        $StreamProvider<List<CandidateRecord>> {
  CandidateListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'candidateListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$candidateListHash();

  @$internal
  @override
  $StreamProviderElement<List<CandidateRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CandidateRecord>> create(Ref ref) {
    return candidateList(ref);
  }
}

String _$candidateListHash() => r'0ba9fc966e9f153ee95a8cbf7d6f0b718454c9be';

@ProviderFor(candidateById)
final candidateByIdProvider = CandidateByIdFamily._();

final class CandidateByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<CandidateRecord?>,
          CandidateRecord?,
          FutureOr<CandidateRecord?>
        >
    with $FutureModifier<CandidateRecord?>, $FutureProvider<CandidateRecord?> {
  CandidateByIdProvider._({
    required CandidateByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'candidateByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$candidateByIdHash();

  @override
  String toString() {
    return r'candidateByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CandidateRecord?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CandidateRecord?> create(Ref ref) {
    final argument = this.argument as String;
    return candidateById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CandidateByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$candidateByIdHash() => r'67d213c09dfb15c20d811ca689c6a4b31d0fd0cb';

final class CandidateByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CandidateRecord?>, String> {
  CandidateByIdFamily._()
    : super(
        retry: null,
        name: r'candidateByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CandidateByIdProvider call(String id) =>
      CandidateByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'candidateByIdProvider';
}

@ProviderFor(recentAuditLog)
final recentAuditLogProvider = RecentAuditLogProvider._();

final class RecentAuditLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuditEntry>>,
          List<AuditEntry>,
          Stream<List<AuditEntry>>
        >
    with $FutureModifier<List<AuditEntry>>, $StreamProvider<List<AuditEntry>> {
  RecentAuditLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentAuditLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentAuditLogHash();

  @$internal
  @override
  $StreamProviderElement<List<AuditEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AuditEntry>> create(Ref ref) {
    return recentAuditLog(ref);
  }
}

String _$recentAuditLogHash() => r'9d1db650ce38d51d731fe9f3ea5ed2c2fb673dba';

@ProviderFor(writableCalendars)
final writableCalendarsProvider = WritableCalendarsProvider._();

final class WritableCalendarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeviceCalendar>>,
          List<DeviceCalendar>,
          FutureOr<List<DeviceCalendar>>
        >
    with
        $FutureModifier<List<DeviceCalendar>>,
        $FutureProvider<List<DeviceCalendar>> {
  WritableCalendarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'writableCalendarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$writableCalendarsHash();

  @$internal
  @override
  $FutureProviderElement<List<DeviceCalendar>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DeviceCalendar>> create(Ref ref) {
    return writableCalendars(ref);
  }
}

String _$writableCalendarsHash() => r'fa69a2f4a73b6a939f70feb55cb130c4540f1fc0';
