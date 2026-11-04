import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/candidate_mapper.dart';
import 'providers.dart';
import 'router.dart';

/// 후보 목록. 탭하면 Review 화면으로 간다.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 알림 권한은 첫 화면에서 한 번 요청한다 (Android 13+).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewNotificationsProvider).requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(candidateListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call to To-do'),
        actions: [
          IconButton(
            tooltip: '설정',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: candidates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (rows) => rows.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _CandidateTile(row: rows[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.textInput),
        icon: const Icon(Icons.edit_note),
        label: const Text('텍스트 입력'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 일정 후보가 없습니다.\n'
              '아래 "텍스트 입력" 으로 파이프라인을 시험해 보세요.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({required this.row});

  final CandidateRecord row;

  static final DateFormat _format = DateFormat('M/d (E) HH:mm', 'ko_KR');
  static final DateFormat _dayFormat = DateFormat('M/d (E)', 'ko_KR');

  @override
  Widget build(BuildContext context) {
    final c = row.candidate;
    final when = c.allDay
        ? _dayFormat.format(c.start)
        : _format.format(c.start);
    final (icon, color) = switch (row.status) {
      CandidateStatus.confirmed => (
        Icons.check_circle,
        Theme.of(context).colorScheme.primary,
      ),
      CandidateStatus.cancelled => (
        Icons.cancel,
        Theme.of(context).colorScheme.outline,
      ),
      _ => (Icons.pending_outlined, Theme.of(context).colorScheme.tertiary),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(c.title),
      subtitle: Text(
        '$when${c.isRecurring ? ' · 반복' : ''}'
        ' · ${c.sourceApp} · ${c.extractor.name}',
      ),
      onTap: () => context.push(AppRoutes.review(c.id)),
    );
  }
}
