import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import 'capture_providers.dart';
import 'capture_settings.dart';
import 'capture_sources.dart';

/// 수집 소스 설정: 마스터 스위치, 소스별 on/off, 허용 앱 목록, 권한 딥링크, 로그 진입.
class CaptureSettingsPage extends ConsumerStatefulWidget {
  const CaptureSettingsPage({super.key});

  @override
  ConsumerState<CaptureSettingsPage> createState() =>
      _CaptureSettingsPageState();
}

class _CaptureSettingsPageState extends ConsumerState<CaptureSettingsPage>
    with WidgetsBindingObserver {
  final _packageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _packageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 시스템 설정(알림 접근·배터리)에서 돌아오면 상태를 다시 읽는다.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(captureStatusProvider);
    }
  }

  Future<void> _addPackage() async {
    final ok = await ref
        .read(captureControllerProvider)
        .addPackage(_packageController.text);
    if (!mounted) return;
    if (ok) {
      _packageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('패키지 이름 형식이 아닙니다 (예: com.kakao.talk).')),
      );
    }
  }

  Future<void> _requestSms() async {
    final granted = await ref
        .read(captureControllerProvider)
        .requestSmsPermission();
    ref.invalidate(captureStatusProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(granted ? 'SMS 읽기 권한이 허용되었습니다.' : 'SMS 읽기 권한이 거부되었습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(captureSettingsProvider);
    final statusAsync = ref.watch(captureStatusProvider);
    final controller = ref.read(captureControllerProvider);
    final settings = settingsAsync.value ?? const CaptureSettings();
    final status = statusAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('수집 소스'),
        actions: [
          IconButton(
            tooltip: '수집 로그',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => context.push(AppRoutes.captureLog),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '메신저 알림과 수신 문자의 텍스트를 기기 안에서 읽어 일정 표현을 찾습니다. '
            '원문은 기기 밖으로 나가지 않으며, 설정에서 외부 전송을 허용한 경우에만 '
            '일정 표현 주변 문장이 Gemini 로 전송됩니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('수집 켜기'),
            subtitle: const Text(
              '켜면 상시 알림과 함께 백그라운드 서비스가 돌고, 재부팅 후에도 다시 시작됩니다.',
            ),
            value: settings.captureEnabled,
            onChanged: (v) async {
              await controller.setCaptureEnabled(v);
              ref.invalidate(captureStatusProvider);
            },
          ),
          const Divider(),
          _SectionTitle('권한·상태'),
          _StatusTile(
            icon: Icons.notifications_active_outlined,
            title: '알림 접근 권한',
            granted: status?.notificationListenerEnabled,
            grantedText: '허용됨 — 허용 앱의 알림 텍스트를 읽습니다.',
            deniedText: '필요 — 시스템 설정에서 "Call to To-do 일정 수집" 을 켜 주세요.',
            actionLabel: '알림 접근 권한 열기',
            onAction: controller.openNotificationListenerSettings,
          ),
          _StatusTile(
            icon: Icons.sms_outlined,
            title: 'SMS 읽기 권한',
            granted: status?.smsPermissionGranted,
            grantedText: '허용됨 — 수신함에 새로 들어온 문자만 읽습니다.',
            deniedText: 'SMS 수집을 쓰려면 READ_SMS 런타임 권한이 필요합니다.',
            actionLabel: 'SMS 권한 요청',
            onAction: _requestSms,
          ),
          _StatusTile(
            icon: Icons.battery_saver_outlined,
            title: '배터리 최적화',
            granted: status?.ignoringBatteryOptimizations,
            grantedText: '제외됨 — 백그라운드 서비스가 덜 중단됩니다.',
            deniedText: '최적화 대상 — 제조사 절전 정책에 따라 수집이 멈출 수 있습니다.',
            actionLabel: '배터리 최적화 제외',
            onAction: controller.openBatteryOptimizationSettings,
          ),
          ListTile(
            leading: Icon(
              status?.serviceRunning == true
                  ? Icons.play_circle_outline
                  : Icons.pause_circle_outline,
            ),
            title: const Text('백그라운드 서비스'),
            subtitle: Text(switch (status?.serviceRunning) {
              true => '실행 중 (dataSync Foreground Service)',
              false => '중지됨',
              null => '확인 중…',
            }),
            dense: true,
          ),
          const Divider(),
          _SectionTitle('소스'),
          SwitchListTile(
            title: const Text('메신저·앱 알림'),
            subtitle: const Text('아래 허용 앱이 띄우는 알림의 제목·본문·메시지 줄을 읽습니다.'),
            value: settings.notificationsEnabled,
            onChanged: settings.captureEnabled
                ? controller.setNotificationsEnabled
                : null,
          ),
          SwitchListTile(
            title: const Text('SMS 수신함'),
            subtitle: const Text(
              'content://sms 수신함에 새 문자가 오면 보낸 번호와 본문을 읽습니다.',
            ),
            value: settings.smsEnabled,
            onChanged: settings.captureEnabled
                ? controller.setSmsEnabled
                : null,
          ),
          const Divider(),
          _SectionTitle('허용 앱 (알림을 읽을 패키지)'),
          if (settings.allowedPackages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '허용 앱이 없어 어떤 알림도 처리하지 않습니다.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final package in settings.allowedPackages)
                InputChip(
                  label: Text(CaptureSources.displayName(package)),
                  tooltip: package,
                  onDeleted: () => controller.removePackage(package),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _packageController,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: '패키지 이름 추가',
                    hintText: 'com.example.app',
                  ),
                  onSubmitted: (_) => _addPackage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: '추가',
                icon: const Icon(Icons.add),
                onPressed: _addPackage,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: controller.restoreDefaultPackages,
              child: const Text('기본값 복원'),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.captureLog),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('수집 로그 보기'),
          ),
          const SizedBox(height: 16),
          Text(
            '알림 접근 권한과 READ_SMS 는 Play 스토어 심사에서 제한되는 권한입니다. '
            '이 앱은 개인 배포(사이드로드)를 전제로 하며, 스토어 배포 시 SMS 수집은 제외해야 할 수 있습니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.title,
    required this.granted,
    required this.grantedText,
    required this.deniedText,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final bool? granted;
  final String grantedText;
  final String deniedText;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: switch (granted) {
          true => scheme.primary,
          false => scheme.error,
          null => null,
        },
      ),
      title: Text(title),
      subtitle: Text(switch (granted) {
        true => grantedText,
        false => deniedText,
        null => '확인 중…',
      }),
      trailing: granted == true
          ? const Icon(Icons.check_circle_outline)
          : TextButton(onPressed: onAction, child: Text(actionLabel)),
      isThreeLine: granted != true,
    );
  }
}
