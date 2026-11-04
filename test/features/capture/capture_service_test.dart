import 'package:call_to_todo/core/pigeon/capture_api.g.dart';
import 'package:call_to_todo/data/database.dart';
import 'package:call_to_todo/features/capture/capture_log_entry.dart';
import 'package:call_to_todo/features/capture/capture_service.dart';
import 'package:call_to_todo/features/capture/capture_settings.dart';
import 'package:call_to_todo/features/capture/capture_sources.dart';
import 'package:call_to_todo/features/capture/message_deduper.dart';
import 'package:call_to_todo/features/extraction/extraction_service.dart';
import 'package:call_to_todo/features/extraction/models/schedule_candidate.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 파이프라인 대역: 받은 호출을 기록하고 미리 정한 후보 수만큼 돌려준다.
class FakePipeline implements PipelineRunner {
  final List<({String text, String sourceApp})> calls = [];
  int candidatesToReturn = 1;
  Exception? failWith;

  @override
  Future<ExtractionResult> run(String text, {required String sourceApp}) async {
    calls.add((text: text, sourceApp: sourceApp));
    if (failWith != null) throw failWith!;
    final now = DateTime(2026, 11, 5, 15);
    return ExtractionResult(
      candidates: [
        for (var i = 0; i < candidatesToReturn; i++)
          ScheduleCandidate(
            id: 'cand-$i-${calls.length}',
            title: '후보 $i',
            start: now,
            end: now.add(const Duration(hours: 1)),
            sourceText: text,
            sourceApp: sourceApp,
          ),
      ],
      extractor: ExtractorKind.rule,
      sentChars: 0,
    );
  }
}

void main() {
  late AppDatabase db;
  late FakePipeline pipeline;
  late CaptureSettings settings;
  late DateTime now;
  late CaptureService service;

  CapturedMessage kakao(String text, {String? sender = '홍길동'}) =>
      CapturedMessage(
        sourceApp: CaptureSources.kakaoTalk,
        sender: sender,
        text: text,
        timestampMillis: DateTime(2026, 11, 4, 9, 30).millisecondsSinceEpoch,
        source: CaptureSource.notification,
      );

  CapturedMessage sms(String text) => CapturedMessage(
    sourceApp: CaptureSources.smsObserverSourceApp,
    sender: '+821012345678',
    text: text,
    timestampMillis: DateTime(2026, 11, 4, 9, 31).millisecondsSinceEpoch,
    source: CaptureSource.sms,
  );

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    pipeline = FakePipeline();
    settings = const CaptureSettings(captureEnabled: true);
    now = DateTime(2026, 11, 4, 10);
    service = CaptureService(
      db: db,
      pipeline: pipeline,
      readSettings: () async => settings,
      deduper: MessageDeduper(clock: () => now),
      clock: () => now,
    );
  });

  tearDown(() => db.close());

  Future<List<CaptureLogEntry>> log() async => [
    for (final r in await db.watchRecentCaptureLog().first) r.toEntry(),
  ];

  test('카카오톡 알림 → 파이프라인 라벨 kakao 로 전달되고 로그에 후보 수가 남는다', () async {
    final result = await service.process(kakao('내일 오후 3시에 강남역에서 보자'));

    expect(result.status, CaptureStatusValues.processed);
    expect(result.candidateCount, 1);
    expect(pipeline.calls, hasLength(1));
    expect(pipeline.calls.single.sourceApp, 'kakao');
    expect(pipeline.calls.single.text, '내일 오후 3시에 강남역에서 보자');

    final entries = await log();
    expect(entries, hasLength(1));
    final e = entries.single;
    expect(e.source, 'notification');
    expect(e.sourceApp, CaptureSources.kakaoTalk);
    expect(e.status, CaptureStatusValues.processed);
    expect(e.candidateCount, 1);
    expect(e.candidateIds, ['cand-0-1']);
    expect(e.textLength, '내일 오후 3시에 강남역에서 보자'.length);
    expect(e.messageAt, DateTime(2026, 11, 4, 9, 30));
    expect(e.processedAt, now);
  });

  test('수집 로그 테이블에는 본문이 어떤 형태로도 저장되지 않는다', () async {
    const text = '비밀번호는 1234 이고 내일 3시에 만나';
    await service.process(kakao(text));

    final rows = await db.select(db.captureLog).get();
    final serialized = rows.single.toJson().toString();
    expect(serialized, isNot(contains('비밀번호')));
    expect(serialized, isNot(contains('1234')));
    expect(serialized, isNot(contains('내일 3시')));
    expect(rows.single.dedupeKey, hasLength(40));
  });

  test('SMS 옵저버 메시지는 라벨 sms 로 전달된다', () async {
    final result = await service.process(sms('[Web발신] 11월 20일 10시 예약'));
    expect(result.status, CaptureStatusValues.processed);
    expect(pipeline.calls.single.sourceApp, 'sms');
    expect((await log()).single.source, 'sms');
  });

  test('누적 알림은 새 줄만 파이프라인에 들어가고 완전 중복은 건너뛴다', () async {
    await service.process(kakao('안녕\n내일 3시에 보자'));
    final second = await service.process(kakao('안녕\n내일 3시에 보자\n강남역 2번 출구'));
    final third = await service.process(kakao('안녕\n내일 3시에 보자\n강남역 2번 출구'));

    expect(pipeline.calls.map((c) => c.text), ['안녕\n내일 3시에 보자', '강남역 2번 출구']);
    expect(second.status, CaptureStatusValues.processed);
    expect(third.status, CaptureStatusValues.duplicate);
    expect(third.candidateCount, 0);

    final entries = await log();
    expect(entries.map((e) => e.status), [
      CaptureStatusValues.duplicate,
      CaptureStatusValues.processed,
      CaptureStatusValues.processed,
    ]);
  });

  test('프로세스가 재시작돼도(메모리 비움) capture_log 로 중복을 거른다', () async {
    await service.process(kakao('내일 3시에 보자'));

    final restarted = CaptureService(
      db: db,
      pipeline: pipeline,
      readSettings: () async => settings,
      deduper: MessageDeduper(clock: () => now),
      clock: () => now,
    );
    now = now.add(const Duration(minutes: 5));
    final result = await restarted.process(kakao('내일 3시에 보자'));

    expect(result.status, CaptureStatusValues.duplicate);
    expect(pipeline.calls, hasLength(1));
  });

  test('수집 마스터 스위치가 꺼져 있으면 disabled 로 기록하고 파이프라인을 부르지 않는다', () async {
    settings = const CaptureSettings(captureEnabled: false);
    final result = await service.process(kakao('내일 3시'));
    expect(result.status, CaptureStatusValues.disabled);
    expect(pipeline.calls, isEmpty);
    expect((await log()).single.status, CaptureStatusValues.disabled);
  });

  test('허용 목록에 없는 패키지의 알림은 disabled', () async {
    settings = const CaptureSettings(
      captureEnabled: true,
      allowedPackages: [CaptureSources.googleMessages],
    );
    final result = await service.process(kakao('내일 3시'));
    expect(result.status, CaptureStatusValues.disabled);
    expect(pipeline.calls, isEmpty);
  });

  test('SMS 소스가 꺼져 있으면 SMS 만 막히고 알림은 처리된다', () async {
    settings = const CaptureSettings(captureEnabled: true, smsEnabled: false);
    expect(
      (await service.process(sms('11월 20일 10시 예약'))).status,
      CaptureStatusValues.disabled,
    );
    expect(
      (await service.process(kakao('내일 3시'))).status,
      CaptureStatusValues.processed,
    );
    expect(pipeline.calls, hasLength(1));
  });

  test('알림 소스가 꺼져 있으면 허용 앱이라도 처리하지 않는다', () async {
    settings = const CaptureSettings(
      captureEnabled: true,
      notificationsEnabled: false,
    );
    expect(
      (await service.process(kakao('내일 3시'))).status,
      CaptureStatusValues.disabled,
    );
    expect(pipeline.calls, isEmpty);
  });

  test('일정 표현이 없어 후보가 0개여도 processed 로 기록된다', () async {
    pipeline.candidatesToReturn = 0;
    final result = await service.process(kakao('잘 지내?'));
    expect(result.status, CaptureStatusValues.processed);
    expect(result.candidateCount, 0);
    final entry = (await log()).single;
    expect(entry.producedCandidate, isFalse);
    expect(entry.candidateIds, isEmpty);
  });

  test('파이프라인 예외는 error 로 기록하고 메시지를 돌려준다', () async {
    pipeline.failWith = Exception('db locked');
    final result = await service.process(kakao('내일 3시'));
    expect(result.status, CaptureStatusValues.error);
    expect(result.error, contains('db locked'));
    expect((await log()).single.status, CaptureStatusValues.error);
  });

  test('후보가 여러 개면 ID 를 모두 기록한다', () async {
    pipeline.candidatesToReturn = 2;
    await service.process(kakao('내일 3시 회의, 모레 5시 저녁'));
    final entry = (await log()).single;
    expect(entry.candidateCount, 2);
    expect(entry.candidateIds, ['cand-0-1', 'cand-1-1']);
  });

  test('buildPipelineText 는 줄바꿈으로 이어 문장 경계를 유지한다', () {
    expect(CaptureService.buildPipelineText(['a', 'b']), 'a\nb');
    expect(CaptureService.buildPipelineText([]), '');
  });
}
