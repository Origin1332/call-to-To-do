import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../extraction/extraction_service.dart';
import '../extraction/models/schedule_candidate.dart';

/// 디버그용 텍스트 입력 화면.
///
/// 캡처 소스(알림·SMS·통화 STT)가 아직 없어도 임의 텍스트로
/// 추출 → 저장 → 알림 → Review → 캘린더 등록 전체 흐름을 에뮬레이터에서 돌려 볼 수 있다.
class TextInputPage extends ConsumerStatefulWidget {
  const TextInputPage({super.key});

  @override
  ConsumerState<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends ConsumerState<TextInputPage> {
  final _textController = TextEditingController();
  final _sourceController = TextEditingController(text: 'debug');

  ExtractionResult? _result;
  bool _running = false;

  static const List<String> _samples = [
    '내일 오후 3시에 강남역 2번 출구에서 보자. 늦지 마!',
    '다음 주 화요일 저녁 7시 반 치과 예약 잡아 뒀어요.',
    '11월 20일 오전 10시부터 12시까지 팀 워크숍 있습니다.',
    '매주 월수금 아침 7시 수영 등록했어. 총 12회.',
    '안녕하세요, 잘 지내시죠? 특별한 얘기는 없어요.',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _running = true;
      _result = null;
    });
    try {
      final result = await ref
          .read(candidatePipelineProvider)
          .run(
            text,
            sourceApp: _sourceController.text.trim().isEmpty
                ? 'debug'
                : _sourceController.text.trim(),
          );
      if (mounted) setState(() => _result = result);
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('텍스트 입력 (디버그)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '여기 입력한 텍스트는 캡처 소스에서 들어온 것처럼 처리됩니다. '
            '규칙 파서가 일정 표현을 찾으면, 설정에 따라 그 주변 문장만 Gemini 로 보냅니다.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final sample in _samples)
                ActionChip(
                  label: Text(
                    sample.length > 18 ? '${sample.substring(0, 18)}…' : sample,
                  ),
                  onPressed: () =>
                      setState(() => _textController.text = sample),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: '텍스트',
              hintText: '통화 내용이나 메시지를 붙여 넣으세요',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sourceController,
            decoration: const InputDecoration(
              labelText: '출처(sourceApp)',
              hintText: 'debug, kakao, sms, call …',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: const Text('추출 실행'),
          ),
          if (result != null) ...[
            const SizedBox(height: 24),
            _ResultSummary(result: result),
            const SizedBox(height: 8),
            for (final c in result.candidates) _CandidateCard(candidate: c),
          ],
        ],
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.result});

  final ExtractionResult result;

  @override
  Widget build(BuildContext context) {
    final extractorLabel = switch (result.extractor) {
      ExtractorKind.rule when result.sentChars == 0 => '규칙 파서 (외부 전송 없음)',
      ExtractorKind.rule => '규칙 파서 (Gemini 폴백)',
      ExtractorKind.gemini => 'Gemini',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '후보 ${result.candidates.length}개 · $extractorLabel',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('외부 전송 글자 수: ${result.sentChars}'),
            if (result.note != null) ...[
              const SizedBox(height: 4),
              Text(result.note!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate});

  final ScheduleCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(candidate.title),
        subtitle: Text(
          '${candidate.start}'
          '${candidate.isRecurring ? '\n${candidate.recurrence}' : ''}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoutes.review(candidate.id)),
      ),
    );
  }
}
