import 'package:flutter/material.dart';

import '../../core/korean_datetime_parser/recurrence_rule.dart';

enum _Preset { none, daily, weekly, monthly, yearly, custom }

/// 반복 규칙 편집기. 자주 쓰는 프리셋과 RRULE 직접 입력을 제공한다.
class RecurrenceField extends StatefulWidget {
  const RecurrenceField({
    super.key,
    required this.rrule,
    required this.start,
    required this.enabled,
    required this.onChanged,
  });

  final String? rrule;
  final DateTime start;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  State<RecurrenceField> createState() => _RecurrenceFieldState();
}

class _RecurrenceFieldState extends State<RecurrenceField> {
  late final TextEditingController _custom = TextEditingController(
    text: widget.rrule ?? '',
  );

  @override
  void didUpdateWidget(covariant RecurrenceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rrule != widget.rrule &&
        (widget.rrule ?? '') != _custom.text) {
      _custom.text = widget.rrule ?? '';
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  _Preset get _preset {
    final rrule = widget.rrule;
    if (rrule == null || rrule.isEmpty) return _Preset.none;
    if (rrule == _presetRule(_Preset.daily)) return _Preset.daily;
    if (rrule == _presetRule(_Preset.weekly)) return _Preset.weekly;
    if (rrule == _presetRule(_Preset.monthly)) return _Preset.monthly;
    if (rrule == _presetRule(_Preset.yearly)) return _Preset.yearly;
    return _Preset.custom;
  }

  String? _presetRule(_Preset preset) => switch (preset) {
    _Preset.none => null,
    _Preset.daily => const RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
    ).toRRule(),
    _Preset.weekly => RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      byWeekdays: [widget.start.weekday],
    ).toRRule(),
    _Preset.monthly => RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      byMonthDay: widget.start.day,
    ).toRRule(),
    _Preset.yearly => const RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
    ).toRRule(),
    _Preset.custom => _custom.text.trim().isEmpty ? null : _custom.text.trim(),
  };

  String _label(_Preset preset) => switch (preset) {
    _Preset.none => '반복 없음',
    _Preset.daily => '매일',
    _Preset.weekly => '매주 (${_weekdayName(widget.start.weekday)}요일)',
    _Preset.monthly => '매월 ${widget.start.day}일',
    _Preset.yearly => '매년',
    _Preset.custom => '직접 입력 (RRULE)',
  };

  static String _weekdayName(int weekday) =>
      const ['월', '화', '수', '목', '금', '토', '일'][weekday - 1];

  @override
  Widget build(BuildContext context) {
    final preset = _preset;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<_Preset>(
          initialValue: preset,
          decoration: const InputDecoration(labelText: '반복'),
          items: [
            for (final p in _Preset.values)
              DropdownMenuItem(value: p, child: Text(_label(p))),
          ],
          onChanged: widget.enabled
              ? (p) {
                  if (p == null) return;
                  if (p == _Preset.custom && _custom.text.trim().isEmpty) {
                    _custom.text = widget.rrule ?? 'FREQ=WEEKLY';
                  }
                  widget.onChanged(_presetRule(p));
                }
              : null,
        ),
        if (preset == _Preset.custom) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _custom,
            enabled: widget.enabled,
            decoration: const InputDecoration(
              labelText: 'RRULE',
              helperText: '예: FREQ=WEEKLY;BYDAY=MO,WE;COUNT=8',
            ),
            onChanged: (value) =>
                widget.onChanged(value.trim().isEmpty ? null : value.trim()),
          ),
        ],
      ],
    );
  }
}
