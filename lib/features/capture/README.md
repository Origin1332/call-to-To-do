# capture (3단계)

네이티브 수집기(알림 리스너·SMS 옵저버)가 보낸 `CapturedMessage` 를 받아
중복 제거 → `CandidatePipeline.run` → 수집 로그까지 처리한다. 설계는 `docs/ARCHITECTURE.md` 의 "수집 소스" 절 참고.

| 파일 | 역할 |
| --- | --- |
| `capture_background.dart` | 헤드리스 Flutter 엔진 진입점 `captureMain` (Kotlin `CaptureEngineHolder` 가 실행) |
| `capture_service.dart` | 설정 확인 → `MessageDeduper` → 파이프라인 → `capture_log` 기록 |
| `message_deduper.dart` | 누적 알림/중복 경로에서 새 줄만 골라내는 중복 제거기 |
| `capture_settings.dart` | 소스 on/off·허용 앱 설정 모델과 직렬화 |
| `capture_sources.dart` | 기본 허용 앱, 표시 이름, 파이프라인 라벨(`kakao`/`sms`/`dialer`) |
| `capture_controller.dart` | 설정 저장 + Pigeon 으로 네이티브 동기화 |
| `capture_settings_page.dart`, `capture_log_page.dart` | 설정 화면, 수집 로그 화면 |
