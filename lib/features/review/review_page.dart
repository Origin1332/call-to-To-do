import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../data/candidate_mapper.dart';
import '../calendar/calendar_repository.dart';
import '../extraction/models/schedule_candidate.dart';
import 'recurrence_field.dart';

/// 일정 후보 확인 화면. 알림(전체화면 인텐트)에서 바로 열린다.
///
/// 처음엔 읽기 전용으로 보여 주고, [수정] 을 누르면 편집 가능해진다.
/// [확인] 은 선택한 기기 캘린더에 이벤트를 쓰고 후보를 confirmed 로 바꾼다.
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key, required this.candidateId});

  final String candidateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(candidateByIdProvider(candidateId));
    return candidate.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('일정 확인')),
        body: Center(child: Text('오류: $e')),
      ),
      data: (row) {
        if (row == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('일정 확인')),
            body: const Center(child: Text('후보를 찾을 수 없습니다.')),
          );
        }
        return _ReviewForm(
          key: ValueKey(row.candidate.id),
          initial: row.candidate,
          status: row.status,
        );
      },
    );
  }
}

class _ReviewForm extends ConsumerStatefulWidget {
  const _ReviewForm({super.key, required this.initial, required this.status});

  final ScheduleCandidate initial;
  final String status;

  @override
  ConsumerState<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<_ReviewForm> {
  late final TextEditingController _title = TextEditingController(
    text: widget.initial.title,
  );
  late final TextEditingController _details = TextEditingController(
    text: widget.initial.details ?? '',
  );
  late DateTime _start = widget.initial.start;
  late DateTime _end = widget.initial.end;
  late bool _allDay = widget.initial.allDay;
  late String? _rrule = widget.initial.recurrence;

  bool _editing = false;
  bool _saving = false;
  int? _calendarId;

  static final DateFormat _dateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  bool get _isPending => widget.status == CandidateStatus.pending;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  ScheduleCandidate _current() => widget.initial.copyWith(
    title: _title.text.trim().isEmpty ? '일정' : _title.text.trim(),
    details: _details.text.trim().isEmpty ? null : _details.text.trim(),
    start: _start,
    end: _end,
    allDay: _allDay,
    recurrence: _rrule,
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final duration = _end.difference(_start);
    setState(() {
      _start = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _start.hour,
        _start.minute,
      );
      _end = _start.add(duration);
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final base = isStart ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        final duration = _end.difference(_start);
        _start = DateTime(
          _start.year,
          _start.month,
          _start.day,
          picked.hour,
          picked.minute,
        );
        _end = _start.add(duration);
      } else {
        _end = DateTime(
          _start.year,
          _start.month,
          _start.day,
          picked.hour,
          picked.minute,
        );
        if (!_end.isAfter(_start)) _end = _end.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _confirm() async {
    final calendarId = _calendarId;
    if (calendarId == null) {
      _snack('등록할 캘린더를 선택하세요.');
      return;
    }
    setState(() => _saving = true);
    final candidate = _current();
    final db = ref.read(appDatabaseProvider);
    try {
      final eventId = await ref
          .read(calendarRepositoryProvider)
          .insertCandidate(candidate, calendarId: calendarId);
      await db.upsertCandidate(candidate.toCompanion());
      await db.updateCandidateStatus(
        candidate.id,
        CandidateStatus.confirmed,
        calendarEventId: eventId,
      );
      await ref
          .read(reviewNotificationsProvider)
          .cancelForCandidate(candidate.id);
      ref.invalidate(candidateByIdProvider(candidate.id));
      if (!mounted) return;
      _snack('캘린더에 등록했습니다.');
      _leave();
    } on CalendarPermissionDeniedException {
      _snack('캘린더 권한이 없어 등록할 수 없습니다.');
    } on Exception catch (e) {
      _snack('등록 실패: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancel() async {
    final db = ref.read(appDatabaseProvider);
    await db.updateCandidateStatus(
      widget.initial.id,
      CandidateStatus.cancelled,
    );
    await ref
        .read(reviewNotificationsProvider)
        .cancelForCandidate(widget.initial.id);
    ref.invalidate(candidateByIdProvider(widget.initial.id));
    if (!mounted) return;
    _leave();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? '일정 수정' : '일정 확인'),
        actions: [
          if (!_isPending)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(label: Text(_statusLabel(widget.status))),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          TextField(
            controller: _title,
            readOnly: !_editing,
            decoration: const InputDecoration(labelText: '이름'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _Field(
            label: '날짜',
            value: _dateFormat.format(_start),
            onTap: _editing ? _pickDate : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('종일'),
            value: _allDay,
            onChanged: _editing
                ? (v) => setState(() {
                    _allDay = v;
                    if (v) {
                      _start = DateTime(_start.year, _start.month, _start.day);
                      _end = _start.add(const Duration(days: 1));
                    } else {
                      _start = DateTime(
                        _start.year,
                        _start.month,
                        _start.day,
                        9,
                      );
                      _end = _start.add(const Duration(hours: 1));
                    }
                  })
                : null,
          ),
          if (!_allDay)
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: '시작 시간',
                    value: _timeFormat.format(_start),
                    onTap: _editing ? () => _pickTime(isStart: true) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: '종료 시간',
                    value: _timeFormat.format(_end),
                    onTap: _editing ? () => _pickTime(isStart: false) : null,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          RecurrenceField(
            rrule: _rrule,
            start: _start,
            enabled: _editing,
            onChanged: (value) => setState(() => _rrule = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _details,
            readOnly: !_editing,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: '세부내용',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          _CalendarPicker(
            selectedId: _calendarId,
            onChanged: (id) => setState(() => _calendarId = id),
          ),
          const SizedBox(height: 24),
          ExpansionTile(
            title: const Text('원문'),
            subtitle: Text(
              '출처: ${widget.initial.sourceApp} · 추출기: ${widget.initial.extractor.name}',
              style: theme.textTheme.bodySmall,
            ),
            tilePadding: EdgeInsets.zero,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SelectableText(widget.initial.sourceText),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _isPending
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _cancel,
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _editing = !_editing),
                        child: Text(_editing ? '수정 완료' : '수정'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _confirm,
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('확인'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  static String _statusLabel(String status) => switch (status) {
    CandidateStatus.confirmed => '등록됨',
    CandidateStatus.cancelled => '취소됨',
    _ => '대기',
  };
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: onTap != null ? const Icon(Icons.edit_outlined) : null,
        ),
        child: Text(value),
      ),
    );
  }
}

/// 쓰기 가능한 기기 캘린더 선택. 권한이 없으면 요청 버튼을 보여 준다.
class _CalendarPicker extends ConsumerWidget {
  const _CalendarPicker({required this.selectedId, required this.onChanged});

  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendars = ref.watch(writableCalendarsProvider);
    return calendars.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            e is CalendarPermissionDeniedException
                ? '캘린더 권한이 필요합니다.'
                : '캘린더 목록을 불러오지 못했습니다: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(writableCalendarsProvider),
            icon: const Icon(Icons.lock_open),
            label: const Text('권한 요청 / 다시 시도'),
          ),
        ],
      ),
      data: (list) {
        if (list.isEmpty) {
          return const Text('쓰기 가능한 캘린더가 없습니다. 기기에 구글 계정을 추가하세요.');
        }
        final effective =
            selectedId ??
            (list.firstWhere((c) => c.isPrimary, orElse: () => list.first)).id;
        if (selectedId == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => onChanged(effective),
          );
        }
        return DropdownButtonFormField<int>(
          initialValue: effective,
          isExpanded: true,
          decoration: const InputDecoration(labelText: '캘린더'),
          items: [
            for (final c in list)
              DropdownMenuItem(
                value: c.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(c.color | 0xFF000000),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${c.displayName} (${c.accountName})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}
