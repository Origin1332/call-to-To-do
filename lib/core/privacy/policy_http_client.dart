import 'package:http/http.dart' as http;

import 'audit_sink.dart';
import 'network_policy.dart';

/// 정책에 의해 차단된 요청.
class BlockedRequestException implements Exception {
  const BlockedRequestException(this.url, this.reason);

  final Uri url;
  final BlockReason reason;

  @override
  String toString() => 'BlockedRequestException(${url.host}, ${reason.code})';
}

/// 앱에서 유일하게 사용되는 HTTP 클라이언트.
///
/// * [NetworkPolicy] 로 허용 호스트를 검사하고, 허용되지 않으면 전송 없이
///   [BlockedRequestException] 을 던진다.
/// * 허용/차단과 무관하게 모든 시도를 [AuditSink] 에 기록한다
///   (호스트, 메서드, 시각, 요청 바이트 수만 — 본문은 기록하지 않음).
/// * [isExternalTransferEnabled] 가 false 를 돌려주면 모든 요청을 차단한다
///   ("외부 전송 끄기" 토글의 2차 방어선).
class PolicyHttpClient extends http.BaseClient {
  PolicyHttpClient({
    required this.policy,
    required this.auditSink,
    required this.isExternalTransferEnabled,
    http.Client? inner,
    DateTime Function()? clock,
  }) : _inner = inner ?? http.Client(),
       _clock = clock ?? DateTime.now;

  final NetworkPolicy policy;
  final AuditSink auditSink;
  final bool Function() isExternalTransferEnabled;
  final http.Client _inner;
  final DateTime Function() _clock;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final decision = policy.evaluate(
      request.url,
      externalTransferEnabled: isExternalTransferEnabled(),
    );

    await auditSink.record(
      AuditEntry(
        timestamp: _clock(),
        host: request.url.host,
        method: request.method,
        allowed: decision.allowed,
        requestBytes: _requestBytes(request),
        reason: decision.reason?.code,
      ),
    );

    if (!decision.allowed) {
      throw BlockedRequestException(request.url, decision.reason!);
    }
    return _inner.send(request);
  }

  static int _requestBytes(http.BaseRequest request) {
    if (request is http.Request) return request.bodyBytes.length;
    return request.contentLength ?? 0;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
