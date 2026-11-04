import 'dart:convert';

import 'package:call_to_todo/core/privacy/audit_sink.dart';
import 'package:call_to_todo/core/privacy/network_policy.dart';
import 'package:call_to_todo/core/privacy/policy_http_client.dart';
import 'package:call_to_todo/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final fixedNow = DateTime(2026, 11, 4, 10);

  group('NetworkPolicy', () {
    const policy = NetworkPolicy();

    test('Gemini 호스트(https)만 허용', () {
      final ok = policy.evaluate(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models'),
        externalTransferEnabled: true,
      );
      expect(ok.allowed, isTrue);
      expect(ok.reason, isNull);
    });

    test('다른 호스트는 차단', () {
      final blocked = policy.evaluate(
        Uri.parse('https://example.com/collect'),
        externalTransferEnabled: true,
      );
      expect(blocked.allowed, isFalse);
      expect(blocked.reason, BlockReason.hostNotAllowed);
    });

    test('서브도메인 흉내도 차단', () {
      final blocked = policy.evaluate(
        Uri.parse('https://generativelanguage.googleapis.com.evil.io/x'),
        externalTransferEnabled: true,
      );
      expect(blocked.allowed, isFalse);
    });

    test('http(평문)는 허용 호스트라도 차단', () {
      final blocked = policy.evaluate(
        Uri.parse('http://generativelanguage.googleapis.com/v1beta/models'),
        externalTransferEnabled: true,
      );
      expect(blocked.reason, BlockReason.insecureScheme);
    });

    test('외부 전송이 꺼져 있으면 허용 호스트도 차단', () {
      final blocked = policy.evaluate(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models'),
        externalTransferEnabled: false,
      );
      expect(blocked.reason, BlockReason.externalTransferDisabled);
    });
  });

  group('PolicyHttpClient', () {
    late InMemoryAuditSink audit;
    late List<http.Request> reached;
    late bool externalTransfer;
    late PolicyHttpClient client;

    setUp(() {
      audit = InMemoryAuditSink();
      reached = [];
      externalTransfer = true;
      client = PolicyHttpClient(
        policy: const NetworkPolicy(),
        auditSink: audit,
        isExternalTransferEnabled: () => externalTransfer,
        clock: () => fixedNow,
        inner: MockClient((request) async {
          reached.add(request);
          return http.Response('{"ok":true}', 200);
        }),
      );
    });

    test('허용 호스트 요청은 통과하고 감사 로그에 바이트 수만 남는다', () async {
      final body = jsonEncode({'contents': '내일 오후 3시 회의'});
      final response = await client.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/x:generateContent',
        ),
        body: body,
      );

      expect(response.statusCode, 200);
      expect(reached, hasLength(1));
      expect(audit.entries, hasLength(1));

      final entry = audit.entries.single;
      expect(entry.host, 'generativelanguage.googleapis.com');
      expect(entry.method, 'POST');
      expect(entry.allowed, isTrue);
      expect(entry.reason, isNull);
      expect(entry.timestamp, fixedNow);
      expect(entry.requestBytes, utf8.encode(body).length);
      expect(entry.toString(), isNot(contains('회의')));
    });

    test('허용되지 않은 호스트는 전송 없이 예외 + 차단 기록', () async {
      await expectLater(
        client.get(Uri.parse('https://analytics.example.com/ping')),
        throwsA(
          isA<BlockedRequestException>().having(
            (e) => e.reason,
            'reason',
            BlockReason.hostNotAllowed,
          ),
        ),
      );
      expect(reached, isEmpty);
      expect(audit.entries.single.allowed, isFalse);
      expect(audit.entries.single.reason, 'host_not_allowed');
      expect(audit.entries.single.host, 'analytics.example.com');
    });

    test('외부 전송 끄기 토글이 켜지면 Gemini 호스트도 차단', () async {
      externalTransfer = false;
      await expectLater(
        client.get(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models'),
        ),
        throwsA(isA<BlockedRequestException>()),
      );
      expect(reached, isEmpty);
      expect(audit.entries.single.reason, 'external_transfer_disabled');
    });
  });

  group('DriftAuditSink', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.withExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('audit_log 테이블에 기록되고 최신순으로 조회된다', () async {
      final sink = DriftAuditSink(db);
      await sink.record(
        AuditEntry(
          timestamp: fixedNow,
          host: 'generativelanguage.googleapis.com',
          method: 'POST',
          allowed: true,
          requestBytes: 123,
        ),
      );
      await sink.record(
        AuditEntry(
          timestamp: fixedNow.add(const Duration(seconds: 1)),
          host: 'evil.example',
          method: 'GET',
          allowed: false,
          requestBytes: 0,
          reason: 'host_not_allowed',
        ),
      );

      final rows = await db.watchRecentAudit().first;
      expect(rows, hasLength(2));
      expect(rows.first.host, 'evil.example');
      expect(rows.first.allowed, isFalse);
      expect(rows.first.reason, 'host_not_allowed');
      expect(rows.last.requestBytes, 123);

      // 테이블에 본문 컬럼 자체가 없다.
      final columns = db.auditLog.$columns.map((c) => c.$name).toSet();
      expect(columns, isNot(contains('body')));
      expect(
        columns,
        containsAll([
          'timestamp',
          'host',
          'method',
          'allowed',
          'reason',
          'request_bytes',
        ]),
      );
    });
  });
}
