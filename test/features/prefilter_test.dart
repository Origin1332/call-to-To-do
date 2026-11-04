import 'package:call_to_todo/core/korean_datetime_parser/korean_datetime_parser.dart';
import 'package:call_to_todo/features/extraction/prefilter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = KoreanDateTimeParser();
  const prefilter = Prefilter();
  final now = DateTime(2026, 11, 4, 10);

  test('일정 표현이 없으면 아무것도 보내지 않는다', () {
    const text = '여보세요. 잘 지내시죠? 어머니 건강은 좀 어떠세요. 네네 알겠습니다.';
    final result = prefilter.select(text, parser.parse(text, now: now));
    expect(result.isEmpty, isTrue);
    expect(result.sentLength, 0);
    expect(result.originalLength, text.length);
  });

  test('매칭 문장과 앞뒤 한 문장만 포함한다', () {
    const text =
        '여보세요. 계좌번호는 110-123-456789 입니다. '
        '그럼 내일 오후 3시에 사무실에서 뵙죠. 주소는 문자로 보낼게요. '
        '비밀번호는 1234예요. 감사합니다.';
    final result = prefilter.select(text, parser.parse(text, now: now));

    expect(result.snippets, hasLength(1));
    final snippet = result.snippets.single;
    expect(snippet, contains('내일 오후 3시'));
    expect(snippet, contains('계좌번호')); // 앞 문장 1개
    expect(snippet, contains('주소는 문자로')); // 뒤 문장 1개
    expect(snippet, isNot(contains('여보세요')));
    expect(snippet, isNot(contains('비밀번호')));
    expect(result.sentLength, lessThan(text.length));
  });

  test('떨어진 두 매칭은 별도 조각으로, 인접하면 하나로 합친다', () {
    const text =
        '내일 3시 회의입니다. 자료는 준비됐어요. 중간 문장입니다. '
        '다른 얘기도 있어요. 모레 오전 10시 치과도 잊지 마세요.';
    final matches = parser.parse(text, now: now);
    expect(matches, hasLength(2));

    final result = prefilter.select(text, matches);
    expect(result.snippets, hasLength(2));
    expect(result.snippets[0], contains('내일 3시'));
    expect(result.snippets[0], isNot(contains('모레')));
    expect(result.snippets[1], contains('모레 오전 10시'));

    final merged = prefilter.select(
      '내일 3시 회의입니다. 모레 오전 10시 치과입니다.',
      parser.parse('내일 3시 회의입니다. 모레 오전 10시 치과입니다.', now: now),
    );
    expect(merged.snippets, hasLength(1));
  });

  test('contextSentences=0 이면 매칭 문장만', () {
    const narrow = Prefilter(contextSentences: 0);
    const text = '앞 문장. 내일 오후 3시 회의. 뒤 문장.';
    final result = narrow.select(text, parser.parse(text, now: now));
    expect(result.snippets.single, '내일 오후 3시 회의.');
  });

  test('너무 긴 조각은 잘라낸다', () {
    const small = Prefilter(contextSentences: 0, maxSnippetChars: 20);
    final text = '내일 오후 3시 ${'아' * 100}';
    final result = small.select(text, parser.parse(text, now: now));
    expect(result.snippets.single.length, 20);
  });
}
