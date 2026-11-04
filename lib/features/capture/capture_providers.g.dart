// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(captureHostApi)
final captureHostApiProvider = CaptureHostApiProvider._();

final class CaptureHostApiProvider
    extends $FunctionalProvider<CaptureHostApi, CaptureHostApi, CaptureHostApi>
    with $Provider<CaptureHostApi> {
  CaptureHostApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureHostApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureHostApiHash();

  @$internal
  @override
  $ProviderElement<CaptureHostApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaptureHostApi create(Ref ref) {
    return captureHostApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureHostApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureHostApi>(value),
    );
  }
}

String _$captureHostApiHash() => r'02def441e7ae540e8512e8edf38c5bc649d0d347';

/// 네이티브에서 온 메시지를 처리하는 서비스. UI 엔진과 백그라운드 엔진 양쪽 컨테이너에서 쓴다.

@ProviderFor(captureService)
final captureServiceProvider = CaptureServiceProvider._();

/// 네이티브에서 온 메시지를 처리하는 서비스. UI 엔진과 백그라운드 엔진 양쪽 컨테이너에서 쓴다.

final class CaptureServiceProvider
    extends $FunctionalProvider<CaptureService, CaptureService, CaptureService>
    with $Provider<CaptureService> {
  /// 네이티브에서 온 메시지를 처리하는 서비스. UI 엔진과 백그라운드 엔진 양쪽 컨테이너에서 쓴다.
  CaptureServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureServiceHash();

  @$internal
  @override
  $ProviderElement<CaptureService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaptureService create(Ref ref) {
    return captureService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureService>(value),
    );
  }
}

String _$captureServiceHash() => r'b913a224d034ee7db6f249054790ec4d580b763c';

@ProviderFor(captureController)
final captureControllerProvider = CaptureControllerProvider._();

final class CaptureControllerProvider
    extends
        $FunctionalProvider<
          CaptureController,
          CaptureController,
          CaptureController
        >
    with $Provider<CaptureController> {
  CaptureControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureControllerHash();

  @$internal
  @override
  $ProviderElement<CaptureController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CaptureController create(Ref ref) {
    return captureController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureController>(value),
    );
  }
}

String _$captureControllerHash() => r'abdaea077355b3b44eabd8a87635cac1be2c1eff';

@ProviderFor(captureSettings)
final captureSettingsProvider = CaptureSettingsProvider._();

final class CaptureSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CaptureSettings>,
          CaptureSettings,
          Stream<CaptureSettings>
        >
    with $FutureModifier<CaptureSettings>, $StreamProvider<CaptureSettings> {
  CaptureSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureSettingsHash();

  @$internal
  @override
  $StreamProviderElement<CaptureSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CaptureSettings> create(Ref ref) {
    return captureSettings(ref);
  }
}

String _$captureSettingsHash() => r'd62745b16b9f8faf02b1d2a5d53773814f1196e3';

/// 권한·서비스 상태. 시스템 설정에서 돌아오면 `ref.invalidate` 로 다시 읽는다.

@ProviderFor(captureStatus)
final captureStatusProvider = CaptureStatusProvider._();

/// 권한·서비스 상태. 시스템 설정에서 돌아오면 `ref.invalidate` 로 다시 읽는다.

final class CaptureStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<CaptureStatus>,
          CaptureStatus,
          FutureOr<CaptureStatus>
        >
    with $FutureModifier<CaptureStatus>, $FutureProvider<CaptureStatus> {
  /// 권한·서비스 상태. 시스템 설정에서 돌아오면 `ref.invalidate` 로 다시 읽는다.
  CaptureStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureStatusHash();

  @$internal
  @override
  $FutureProviderElement<CaptureStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CaptureStatus> create(Ref ref) {
    return captureStatus(ref);
  }
}

String _$captureStatusHash() => r'9b0620749aa1a6aad167cacd7881527329dfadea';

@ProviderFor(captureLog)
final captureLogProvider = CaptureLogProvider._();

final class CaptureLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CaptureLogEntry>>,
          List<CaptureLogEntry>,
          Stream<List<CaptureLogEntry>>
        >
    with
        $FutureModifier<List<CaptureLogEntry>>,
        $StreamProvider<List<CaptureLogEntry>> {
  CaptureLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureLogHash();

  @$internal
  @override
  $StreamProviderElement<List<CaptureLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CaptureLogEntry>> create(Ref ref) {
    return captureLog(ref);
  }
}

String _$captureLogHash() => r'7550812b143d0c04209a0d718dcaf08cde98e694';
