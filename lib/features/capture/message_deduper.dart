import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/pigeon/capture_api.g.dart';
import 'capture_sources.dart';

/// 반복·누적 알림에서 **새로 등장한 줄만** 골라내는 중복 제거기.
///
/// 메신저 알림은 같은 대화방에 메시지가 올 때마다 이전 메시지를 포함한 채 다시 게시된다
/// (MessagingStyle/InboxStyle 누적, 그룹 요약, 앱 재게시). 또 같은 문자를 메시지 앱 알림과
/// SMS 옵저버 두 경로로 받을 수도 있다. 그래서
///
/// * 본문을 줄 단위로 나눠 각 줄의 정규화 해시를 [window] 동안 기억하고,
/// * 이미 본 줄은 버리고 새 줄만 남겨 돌려준다. 남는 줄이 없으면 그 메시지는 중복이다.
///
/// 키에는 [CaptureSources.pipelineLabel] 만 넣고 보낸 사람은 넣지 않는다. 같은 문자를
/// 알림(연락처 이름)과 옵저버(전화번호)가 다른 sender 로 보내기 때문이다.
///
/// 상태는 메모리에만 있다. 프로세스 재시작을 넘어가는 중복은 `capture_log.dedupe_key`
/// 로 [CaptureService] 가 한 번 더 거른다.
class MessageDeduper {
  MessageDeduper({
    this.window = const Duration(minutes: 10),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration window;
  final DateTime Function() _clock;
  final Map<String, DateTime> _seen = {};

  /// [message] 에서 아직 보지 않은 줄만 돌려주고, 그 줄들을 본 것으로 기록한다.
  List<String> takeNewLines(CapturedMessage message) {
    final now = _clock();
    _prune(now);

    final label = CaptureSources.pipelineLabel(message.sourceApp);
    final fresh = <String>[];
    for (final line in splitLines(message.text)) {
      final key = lineKey(label, line);
      if (_seen.containsKey(key)) continue;
      _seen[key] = now;
      fresh.add(line);
    }
    return fresh;
  }

  /// 새 줄이 하나도 없으면 true. [takeNewLines] 와 마찬가지로 본 줄을 기록한다.
  bool isDuplicate(CapturedMessage message) => takeNewLines(message).isEmpty;

  void _prune(DateTime now) {
    _seen.removeWhere((_, seenAt) => now.difference(seenAt) > window);
  }

  /// 본문을 의미 있는 줄로 나눈다. 빈 줄은 버리고 각 줄은 trim 한다.
  static List<String> splitLines(String text) => [
    for (final line in text.split(RegExp(r'\r?\n')))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  /// 공백·대소문자 차이를 무시한 줄 키. 본문을 복원할 수 없는 해시다.
  static String lineKey(String label, String line) {
    final normalized = line
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return sha1.convert(utf8.encode('$label|$normalized')).toString();
  }

  /// 메시지 전체(새 줄들)를 대표하는 키. `capture_log.dedupe_key` 에 저장된다.
  static String messageKey(String sourceApp, List<String> lines) {
    final label = CaptureSources.pipelineLabel(sourceApp);
    final joined = lines
        .map((l) => l.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim())
        .join('\n');
    return sha1.convert(utf8.encode('$label|$joined')).toString();
  }
}
