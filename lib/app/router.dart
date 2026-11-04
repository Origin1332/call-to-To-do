import 'package:go_router/go_router.dart';

import '../features/capture/capture_log_page.dart';
import '../features/capture/capture_settings_page.dart';
import '../features/debug/text_input_page.dart';
import '../features/review/review_page.dart';
import '../features/settings/settings_page.dart';
import 'home_page.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String textInput = '/debug/text';
  static const String settings = '/settings';
  static const String captureSettings = '/settings/capture';
  static const String captureLog = '/settings/capture/log';
  static String review(String candidateId) => '/review/$candidateId';
}

GoRouter createRouter({String? initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation ?? AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'debug/text',
            builder: (context, state) => const TextInputPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'capture',
                builder: (context, state) => const CaptureSettingsPage(),
                routes: [
                  GoRoute(
                    path: 'log',
                    builder: (context, state) => const CaptureLogPage(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'review/:id',
            builder: (context, state) =>
                ReviewPage(candidateId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
}
