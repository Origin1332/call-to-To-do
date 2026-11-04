import '../../core/korean_datetime_parser/korean_datetime_parser.dart';

/// 프리필터 결과. [snippets] 만 외부(Gemini)로 전송된다.
class PrefilterResult {
  const PrefilterResult({required this.snippets, required this.originalLength});

  const PrefilterResult.empty() : snippets = const [], originalLength = 0;

  final List<String> snippets;
  final int originalLength;

  bool get isEmpty => snippets.isEmpty;
  int get sentLength => snippets.fold(0, (sum, s) => sum + s.length);
}

/// 규칙 파서가 잡은 표현 주변 문장만 골라내는 프라이버시 프리필터.
///
/// 일정 표현이 하나도 없으면 아무것도 보내지 않는다. 있으면 해당 문장과
/// 앞뒤 [contextSentences] 문장만 포함한다.
class Prefilter {
  const Prefilter({this.contextSentences = 1, this.maxSnippetChars = 600});

  final int contextSentences;
  final int maxSnippetChars;

  static final RegExp _boundary = RegExp(r'[.!?\n。]+');

  PrefilterResult select(String text, List<ParsedSchedule> matches) {
    if (matches.isEmpty || text.trim().isEmpty) {
      return PrefilterResult(snippets: const [], originalLength: text.length);
    }

    final sentences = _splitSentences(text);
    final selected = <int>{};
    for (final match in matches) {
      final index = _sentenceIndexAt(sentences, match.startOffset);
      if (index < 0) continue;
      for (
        var i = index - contextSentences;
        i <= index + contextSentences;
        i++
      ) {
        if (i >= 0 && i < sentences.length) selected.add(i);
      }
    }

    final snippets = <String>[];
    final ordered = selected.toList()..sort();
    var buffer = <String>[];
    int? previous;
    for (final i in ordered) {
      if (previous != null && i != previous + 1 && buffer.isNotEmpty) {
        snippets.add(_join(buffer));
        buffer = <String>[];
      }
      buffer.add(sentences[i].text);
      previous = i;
    }
    if (buffer.isNotEmpty) snippets.add(_join(buffer));

    return PrefilterResult(
      snippets: snippets.where((s) => s.isNotEmpty).toList(),
      originalLength: text.length,
    );
  }

  String _join(List<String> parts) {
    final joined = parts.join('\n').trim();
    return joined.length > maxSnippetChars
        ? joined.substring(0, maxSnippetChars)
        : joined;
  }

  List<_Sentence> _splitSentences(String text) {
    final result = <_Sentence>[];
    var cursor = 0;
    for (final m in _boundary.allMatches(text)) {
      result.add(
        _Sentence(cursor, m.end, text.substring(cursor, m.end).trim()),
      );
      cursor = m.end;
    }
    if (cursor < text.length) {
      result.add(_Sentence(cursor, text.length, text.substring(cursor).trim()));
    }
    return result;
  }

  int _sentenceIndexAt(List<_Sentence> sentences, int offset) {
    for (var i = 0; i < sentences.length; i++) {
      if (offset >= sentences[i].start && offset < sentences[i].end) return i;
    }
    return -1;
  }
}

class _Sentence {
  const _Sentence(this.start, this.end, this.text);
  final int start;
  final int end;
  final String text;
}
