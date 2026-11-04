import 'package:call_to_todo/core/pigeon/capture_api.g.dart';
import 'package:call_to_todo/features/capture/capture_sources.dart';
import 'package:call_to_todo/features/capture/message_deduper.dart';
import 'package:flutter_test/flutter_test.dart';

CapturedMessage message(
  String text, {
  String sourceApp = CaptureSources.kakaoTalk,
  String? sender = '홍길동',
  CaptureSource source = CaptureSource.notification,
  int timestampMillis = 0,
}) {
  return CapturedMessage(
    sourceApp: sourceApp,
    sender: sender,
    text: text,
    timestampMillis: timestampMillis,
    source: source,
  );
}

void main() {
  late DateTime now;
  late MessageDeduper deduper;

  setUp(() {
    now = DateTime(2026, 11, 4, 10);
    deduper = MessageDeduper(
      window: const Duration(minutes: 10),
      clock: () => now,
    );
  });

  test('같은 알림이 다시 게시되면 중복', () {
    expect(deduper.isDuplicate(message('내일 3시에 보자')), isFalse);
    expect(deduper.isDuplicate(message('내일 3시에 보자')), isTrue);
  });

  test('누적 MessagingStyle 갱신에서는 새 줄만 남는다', () {
    expect(deduper.takeNewLines(message('안녕\n내일 3시에 보자')), ['안녕', '내일 3시에 보자']);
    // 카카오톡은 다음 메시지가 오면 이전 메시지를 포함해 다시 게시한다.
    expect(deduper.takeNewLines(message('안녕\n내일 3시에 보자\n강남역 2번 출구')), [
      '강남역 2번 출구',
    ]);
    expect(deduper.isDuplicate(message('안녕\n내일 3시에 보자\n강남역 2번 출구')), isTrue);
  });

  test('공백·대소문자 차이는 같은 줄로 본다', () {
    expect(deduper.isDuplicate(message('Meeting  tomorrow  3PM')), isFalse);
    expect(deduper.isDuplicate(message('meeting tomorrow 3pm ')), isTrue);
    expect(
      deduper.isDuplicate(message('\n\n  meeting tomorrow 3pm\n')),
      isTrue,
    );
  });

  test('윈도 밖이면 다시 새 메시지로 본다', () {
    expect(deduper.isDuplicate(message('내일 3시')), isFalse);
    now = now.add(const Duration(minutes: 9));
    expect(deduper.isDuplicate(message('내일 3시')), isTrue);
    now = now.add(const Duration(minutes: 2));
    expect(deduper.isDuplicate(message('내일 3시')), isFalse);
  });

  test('같은 문자를 메시지 앱 알림과 SMS 옵저버로 받으면 하나로 본다', () {
    final fromNotification = message(
      '[Web발신] 11월 20일 10시 예약 안내',
      sourceApp: CaptureSources.googleMessages,
      sender: '치과',
    );
    final fromObserver = message(
      '[Web발신] 11월 20일 10시 예약 안내',
      sourceApp: CaptureSources.smsObserverSourceApp,
      sender: '+821012345678',
      source: CaptureSource.sms,
    );
    expect(deduper.isDuplicate(fromNotification), isFalse);
    expect(deduper.isDuplicate(fromObserver), isTrue);
  });

  test('다른 앱(라벨)에서 온 같은 문장은 중복이 아니다', () {
    expect(deduper.isDuplicate(message('내일 3시')), isFalse);
    expect(
      deduper.isDuplicate(
        message('내일 3시', sourceApp: CaptureSources.sktDialer),
      ),
      isFalse,
    );
  });

  test('빈 본문은 새 줄이 없다', () {
    expect(deduper.takeNewLines(message('  \n \n')), isEmpty);
  });

  group('키', () {
    test('lineKey 는 본문을 담지 않는 해시다', () {
      final key = MessageDeduper.lineKey('kakao', '내일 3시에 보자');
      expect(key, hasLength(40));
      expect(key, isNot(contains('내일')));
      expect(key, MessageDeduper.lineKey('kakao', '  내일   3시에 보자 '));
      expect(key, isNot(MessageDeduper.lineKey('sms', '내일 3시에 보자')));
    });

    test('messageKey 는 라벨이 같으면 패키지가 달라도 같다', () {
      final lines = ['내일 3시', '강남역'];
      expect(
        MessageDeduper.messageKey(CaptureSources.googleMessages, lines),
        MessageDeduper.messageKey(CaptureSources.smsObserverSourceApp, lines),
      );
      expect(
        MessageDeduper.messageKey(CaptureSources.kakaoTalk, lines),
        isNot(MessageDeduper.messageKey(CaptureSources.googleMessages, lines)),
      );
    });
  });
}
