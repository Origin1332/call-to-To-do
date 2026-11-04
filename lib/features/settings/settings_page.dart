import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/privacy/audit_sink.dart';
import '../../core/privacy/network_policy.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  bool _apiKeyLoaded = false;
  bool _modelLoaded = false;
  bool _obscureKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    await ref
        .read(settingsRepositoryProvider)
        .writeGeminiApiKey(_apiKeyController.text);
    ref.invalidate(geminiApiKeyProvider);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('API 키를 안전 저장소에 저장했습니다.')));
    }
  }

  Future<void> _saveModel() async {
    await ref
        .read(settingsRepositoryProvider)
        .setGeminiModel(_modelController.text);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('모델 이름을 저장했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final externalTransfer = ref.watch(externalTransferEnabledProvider);
    final apiKey = ref.watch(geminiApiKeyProvider);
    final model = ref.watch(geminiModelProvider);
    final audit = ref.watch(recentAuditLogProvider);

    if (!_apiKeyLoaded && apiKey.hasValue) {
      _apiKeyController.text = apiKey.value ?? '';
      _apiKeyLoaded = true;
    }
    if (!_modelLoaded && model.hasValue) {
      _modelController.text = model.value!;
      _modelLoaded = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('프라이버시'),
          SwitchListTile(
            title: const Text('외부 전송 끄기'),
            subtitle: const Text(
              '켜면 Gemini 를 호출하지 않고 규칙 파서만 사용합니다. '
              '네트워크 클라이언트도 모든 요청을 차단합니다.',
            ),
            value: !(externalTransfer.value ?? true),
            onChanged: (off) => ref
                .read(settingsRepositoryProvider)
                .setExternalTransferEnabled(!off),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: const Text('허용 호스트'),
            subtitle: Text(NetworkPolicy.geminiHost),
            dense: true,
          ),
          const SizedBox(height: 16),
          _SectionTitle('Gemini'),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Gemini API 키',
              helperText: 'flutter_secure_storage(Android Keystore)에 저장됩니다.',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _saveApiKey,
            child: const Text('API 키 저장'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(
              labelText: '모델 이름',
              helperText: 'Flash 계열 권장 (예: gemini-2.5-flash)',
            ),
            onSubmitted: (_) => _saveModel(),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _saveModel, child: const Text('모델 저장')),
          const SizedBox(height: 24),
          _SectionTitle('네트워크 감사 로그 (최근 50건)'),
          Text(
            '모든 외부 요청 시도가 기록됩니다. 본문은 저장되지 않습니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          audit.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('오류: $e'),
            data: (rows) => rows.isEmpty
                ? const Text('기록 없음')
                : Column(children: [for (final r in rows) _AuditTile(row: r)]),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.row});

  final AuditEntry row;

  static final DateFormat _format = DateFormat('MM-dd HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        row.allowed ? Icons.check_circle_outline : Icons.block,
        color: row.allowed ? scheme.primary : scheme.error,
      ),
      title: Text('${row.method} ${row.host}'),
      subtitle: Text(
        '${_format.format(row.timestamp)} · ${row.requestBytes} bytes'
        '${row.reason != null ? ' · ${row.reason}' : ''}',
      ),
    );
  }
}
