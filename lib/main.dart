import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');

  final container = ProviderContainer();
  // "외부 전송 끄기" 캐시를 네트워크 클라이언트가 쓰기 전에 채운다.
  await container.read(settingsRepositoryProvider).load();

  final notifications = container.read(reviewNotificationsProvider);
  final launchCandidateId = await notifications.launchCandidateId();
  final router = createRouter(
    initialLocation: launchCandidateId == null
        ? null
        : AppRoutes.review(launchCandidateId),
  );
  await notifications.init(
    onSelect: (candidateId) => router.push(AppRoutes.review(candidateId)),
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: CallToTodoApp(router: router),
    ),
  );
}
