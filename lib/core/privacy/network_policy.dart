/// 앱의 네트워크 정책: 허용 호스트 목록과 외부 전송 스위치.
///
/// 앱 안의 모든 HTTP 요청은 [PolicyHttpClient] 하나를 거치고, 그 클라이언트는
/// 이 정책에 따라 요청을 허용/차단한다.
class NetworkPolicy {
  const NetworkPolicy({
    this.allowedHosts = const {geminiHost},
    this.requireHttps = true,
  });

  /// Gemini API. 계획상 유일하게 허용되는 외부 호스트.
  static const String geminiHost = 'generativelanguage.googleapis.com';

  final Set<String> allowedHosts;
  final bool requireHttps;

  /// [url] 로의 요청이 허용되는지 판정한다.
  PolicyDecision evaluate(Uri url, {required bool externalTransferEnabled}) {
    if (!externalTransferEnabled) {
      return const PolicyDecision.blocked(BlockReason.externalTransferDisabled);
    }
    if (requireHttps && url.scheme != 'https') {
      return const PolicyDecision.blocked(BlockReason.insecureScheme);
    }
    if (!allowedHosts.contains(url.host.toLowerCase())) {
      return const PolicyDecision.blocked(BlockReason.hostNotAllowed);
    }
    return const PolicyDecision.allowed();
  }
}

enum BlockReason {
  hostNotAllowed('host_not_allowed'),
  insecureScheme('insecure_scheme'),
  externalTransferDisabled('external_transfer_disabled');

  const BlockReason(this.code);

  /// 감사 로그에 기록되는 안정적인 문자열 코드.
  final String code;
}

class PolicyDecision {
  const PolicyDecision.allowed() : allowed = true, reason = null;

  const PolicyDecision.blocked(BlockReason this.reason) : allowed = false;

  final bool allowed;
  final BlockReason? reason;
}
