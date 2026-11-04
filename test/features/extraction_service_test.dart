import 'dart:convert';

import 'package:call_to_todo/core/korean_datetime_parser/korean_datetime_parser.dart';
import 'package:call_to_todo/core/privacy/audit_sink.dart';
import 'package:call_to_todo/core/privacy/network_policy.dart';
import 'package:call_to_todo/core/privacy/policy_http_client.dart';
import 'package:call_to_todo/features/extraction/extraction_service.dart';
import 'package:call_to_todo/features/extraction/gemini_extractor.dart';
import 'package:call_to_todo/features/extraction/models/schedule_candidate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Gemini REST 응답 형태로 [items] 를 감싼다.
http.Response geminiResponse(List<Map<String, Object?>> items) {
  return http.Response(
    jsonEncode({
      'candidates': [
        {
          'content': {
            'role': 'model',
            'parts': [
              {'text': jsonEncode(items)},
            ],
          },
          'finishReason': 'STOP',
        },
      ],
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  final now = DateTime(2026, 11, 4, 10);
  const text =
      '여보세요. 네, 접니다. 그럼 다음 주 화요일 저녁 7시에 강남에서 뵐게요. '
      '참, 계좌는 110-1234-5678 이에요.';

  late InMemoryAuditSink audit;
  late List<http.Request> requests;
  late bool externalTransfer;

  PolicyHttpClient makeClient(
    Future<http.Response> Function(http.Request) handler,
  ) {
    return PolicyHttpClient(
      policy: const NetworkPolicy(),
      auditSink: audit,
      isExternalTransferEnabled: () => externalTransfer,
      clock: () => now,
      inner: MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
    );
  }

  setUp(() {
    audit = InMemoryAuditSink();
    requests = [];
    externalTransfer = true;
  });

  test('일정 표현이 없으면 Gemini 를 호출하지 않는다', () async {
    var geminiAsked = false;
    final service = ExtractionService(
      geminiProvider: () async {
        geminiAsked = true;
        return null;
      },
      clock: () => now,
    );
    final result = await service.extract('안녕하세요 잘 지내시죠', sourceApp: 'debug');
    expect(result.candidates, isEmpty);
    expect(result.sentChars, 0);
    expect(geminiAsked, isFalse);
  });

  test('외부 전송이 꺼져 있으면(제공자가 null) 규칙 파서만 사용', () async {
    final service = ExtractionService(
      geminiProvider: () async => null,
      clock: () => now,
    );
    final result = await service.extract(text, sourceApp: 'call');

    expect(result.extractor, ExtractorKind.rule);
    expect(result.sentChars, 0);
    expect(result.candidates, hasLength(1));
    final c = result.candidates.single;
    expect(c.start, DateTime(2026, 11, 10, 19));
    expect(c.end, DateTime(2026, 11, 10, 20));
    expect(c.allDay, isFalse);
    expect(c.sourceApp, 'call');
    expect(c.sourceText, text);
    expect(c.title, contains('강남'));
    expect(requests, isEmpty);
  });

  test('Gemini 경로: 프리필터 조각만 전송되고 감사 로그가 남는다', () async {
    final client = makeClient((request) async {
      return geminiResponse([
        {
          'title': '강남 미팅',
          'start': '2026-11-10T19:00:00',
          'end': '2026-11-10T20:30:00',
          'all_day': false,
          'recurrence': null,
          'details': '강남에서',
        },
      ]);
    });
    final service = ExtractionService(
      geminiProvider: () async => GeminiExtractor(
        apiKey: 'test-key',
        httpClient: client,
        clock: () => now,
      ),
      clock: () => now,
    );

    final result = await service.extract(text, sourceApp: 'kakao');

    expect(result.extractor, ExtractorKind.gemini);
    expect(result.candidates, hasLength(1));
    final c = result.candidates.single;
    expect(c.title, '강남 미팅');
    expect(c.start, DateTime(2026, 11, 10, 19));
    expect(c.end, DateTime(2026, 11, 10, 20, 30));
    expect(c.extractor, ExtractorKind.gemini);
    expect(c.sourceApp, 'kakao');

    // 실제 전송 1건, 허용 호스트, 본문에는 프리필터 조각만.
    expect(requests, hasLength(1));
    final sent = requests.single;
    expect(sent.url.host, NetworkPolicy.geminiHost);
    expect(sent.body, contains('다음 주 화요일 저녁 7시'));
    expect(sent.body, contains('계좌는')); // 인접 문장은 포함
    expect(sent.body, contains('네, 접니다'));
    expect(sent.body, isNot(contains('여보세요'))); // 두 문장 떨어진 문장은 제외
    expect(result.sentChars, greaterThan(0));
    expect(result.sentChars, lessThan(text.length));

    expect(audit.entries, hasLength(1));
    expect(audit.entries.single.allowed, isTrue);
    expect(audit.entries.single.host, NetworkPolicy.geminiHost);
    expect(audit.entries.single.requestBytes, utf8.encode(sent.body).length);
  });

  test('Gemini 가 빈 배열을 주면 규칙 파서 결과로 대체', () async {
    final client = makeClient((_) async => geminiResponse([]));
    final service = ExtractionService(
      geminiProvider: () async =>
          GeminiExtractor(apiKey: 'k', httpClient: client, clock: () => now),
      clock: () => now,
    );
    final result = await service.extract(text, sourceApp: 'debug');
    expect(result.extractor, ExtractorKind.rule);
    expect(result.candidates, hasLength(1));
    expect(result.note, contains('규칙 파서'));
  });

  test('Gemini 호출이 실패하면 규칙 파서로 폴백', () async {
    final client = makeClient((_) async => http.Response('boom', 500));
    final service = ExtractionService(
      geminiProvider: () async =>
          GeminiExtractor(apiKey: 'k', httpClient: client, clock: () => now),
      clock: () => now,
    );
    final result = await service.extract(text, sourceApp: 'debug');
    expect(result.extractor, ExtractorKind.rule);
    expect(result.candidates.single.start, DateTime(2026, 11, 10, 19));
    expect(result.note, contains('실패'));
  });

  test('네트워크 클라이언트 단에서 차단돼도 규칙 파서로 폴백', () async {
    externalTransfer = false; // 2차 방어선: 제공자는 있지만 클라이언트가 막음
    final client = makeClient((_) async => geminiResponse([]));
    final service = ExtractionService(
      geminiProvider: () async =>
          GeminiExtractor(apiKey: 'k', httpClient: client, clock: () => now),
      clock: () => now,
    );
    final result = await service.extract(text, sourceApp: 'debug');
    expect(result.extractor, ExtractorKind.rule);
    expect(result.note, contains('external_transfer_disabled'));
    expect(requests, isEmpty);
    expect(audit.entries.single.allowed, isFalse);
  });

  group('GeminiExtractor.parseResponse', () {
    final extractor = GeminiExtractor(
      apiKey: 'k',
      httpClient: MockClient((_) async => http.Response('', 500)),
      clock: () => now,
    );

    test('형식이 틀린 항목은 건너뛰고 종료 시각을 보정한다', () {
      final parsed = extractor.parseResponse(
        jsonEncode([
          {
            'title': ' 치과 ',
            'start': '2026-11-06T10:00:00',
            'end': '2026-11-06T09:00:00', // 시작보다 이름 → 1시간으로 보정
            'all_day': false,
            'recurrence': '',
          },
          {'title': '시작 없음', 'all_day': false},
          {
            'title': '',
            'start': '2026-11-07T00:00:00',
            'all_day': true,
            'recurrence': 'FREQ=WEEKLY;BYDAY=SA',
          },
        ]),
        sourceText: 's',
        sourceApp: 'a',
      );

      expect(parsed, hasLength(2));
      expect(parsed[0].title, '치과');
      expect(parsed[0].end, DateTime(2026, 11, 6, 11));
      expect(parsed[0].recurrence, isNull);
      expect(parsed[1].title, '일정');
      expect(parsed[1].allDay, isTrue);
      expect(parsed[1].end, DateTime(2026, 11, 8));
      expect(parsed[1].recurrence, 'FREQ=WEEKLY;BYDAY=SA');
    });

    test('JSON 이 아니면 예외', () {
      expect(
        () => extractor.parseResponse(
          'not json',
          sourceText: 's',
          sourceApp: 'a',
        ),
        throwsA(isA<GeminiExtractionException>()),
      );
    });

    test('프롬프트에는 현재 시각과 규칙 파서 힌트가 들어간다', () {
      final hints = const KoreanDateTimeParser().parse('내일 3시 회의', now: now);
      final prompt = extractor.buildPrompt(
        snippets: const ['내일 3시 회의'],
        hints: hints,
      );
      expect(prompt, contains('2026-11-04T10:00:00'));
      expect(prompt, contains('수요일'));
      expect(prompt, contains('내일 3시 회의'));
      expect(prompt, contains('"내일 3시" → 2026-11-05T15:00:00'));
    });
  });
}
