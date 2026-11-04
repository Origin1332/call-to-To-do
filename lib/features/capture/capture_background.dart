import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../app/providers.dart';
import '../../core/pigeon/capture_api.g.dart';
import 'capture_providers.dart';
import 'capture_service.dart';

/// 헤드리스 Flutter 엔진의 진입점. Kotlin `CaptureEngineHolder` 가 실행한다.
///
/// UI 없이 `ProviderContainer` 만 세워 설정·DB·알림 플러그인을 초기화한 뒤
/// [CaptureFlutterApi] 핸들러를 등록하고 준비 완료를 알린다. 이후 네이티브가 메시지를
/// 하나씩 넘기면 [CaptureService] 가 규칙 파서 → (Gemini) → 후보 저장 → 확인 알림까지 처리한다.
/// 앱 화면이 완전히 닫혀 있어도 이 경로로 확인 알림이 뜬다.
@pragma('vm:entry-point')
Future<void> captureMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await initializeDateFormatting('ko_KR');

  final container = ProviderContainer();
  await container.read(settingsRepositoryProvider).load();
  // 알림 플러그인은 isolate 마다 초기화해야 show() 가 동작한다. 탭 처리는 UI 엔진이 맡는다.
  await container.read(reviewNotificationsProvider).init(onSelect: (_) {});

  CaptureFlutterApi.setUp(
    _BackgroundCaptureApi(container.read(captureServiceProvider)),
  );
  await CaptureHostApi().signalDartReady();
}

class _BackgroundCaptureApi implements CaptureFlutterApi {
  _BackgroundCaptureApi(this._service);

  final CaptureService _service;

  @override
  Future<CaptureProcessResult> processMessage(CapturedMessage message) =>
      _service.process(message);
}
