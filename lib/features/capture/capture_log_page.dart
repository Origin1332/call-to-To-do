import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import 'capture_log_entry.dart';
import 'capture_providers.dart';
import 'capture_service.dart';
import 'capture_sources.dart';

/// 수집 로그. 출처·시각·결과만 보여 주며 본문은 저장돼 있지 않다.
/// 후보가 만들어진 항목을 탭하면 Review 화면에서 원문을 볼 수 있다.
class CaptureLogPage extends ConsumerWidget {
  const CaptureLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(captureLogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('수집 로그')),
      body: log.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (entries) => entries.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '아직 수집된 메시지가 없습니다.\n'
                    '수집을 켜고 알림 접근 권한을 허용하면 여기에 기록됩니다.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _LogTile(entry: entries[i]),
              ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final CaptureLogEntry entry;

  static final DateFormat _format = DateFormat('M/d HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color, label) = switch (entry.status) {
      CaptureStatusValues.processed when entry.producedCandidate => (
        Icons.event_available,
        scheme.primary,
        '후보 ${entry.candidateCount}개',
      ),
      CaptureStatusValues.processed => (
        Icons.search_off,
        scheme.outline,
        '일정 표현 없음',
      ),
      CaptureStatusValues.duplicate => (Icons.copy_all, scheme.outline, '중복'),
      CaptureStatusValues.disabled => (Icons.block, scheme.outline, '소스 꺼짐'),
      CaptureStatusValues.error => (Icons.error_outline, scheme.error, '처리 오류'),
      _ => (Icons.help_outline, scheme.outline, entry.status),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text('${CaptureSources.displayName(entry.sourceApp)} · $label'),
      subtitle: Text(
        '${_format.format(entry.messageAt)} 수신 · '
        '${entry.source == 'sms' ? 'SMS 옵저버' : '알림'} · '
        '${entry.textLength}자',
      ),
      trailing: entry.producedCandidate
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: entry.producedCandidate ? () => _openCandidate(context) : null,
    );
  }

  Future<void> _openCandidate(BuildContext context) async {
    final ids = entry.candidateIds;
    if (ids.length == 1) {
      await context.push(AppRoutes.review(ids.single));
      return;
    }
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < ids.length; i++)
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text('후보 ${i + 1}'),
                onTap: () => Navigator.of(sheetContext).pop(ids[i]),
              ),
          ],
        ),
      ),
    );
    if (chosen != null && context.mounted) {
      await context.push(AppRoutes.review(chosen));
    }
  }
}
