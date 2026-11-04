import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/database.dart';
import '../extraction/gemini_extractor.dart';

/// 앱 설정 저장소.
///
/// * Gemini API 키 → `flutter_secure_storage` (Android Keystore 암호화).
/// * 그 외(외부 전송 토글, 모델 이름) → drift `settings` 테이블.
///
/// "외부 전송 끄기" 값은 네트워크 클라이언트가 동기적으로 참조해야 하므로
/// 메모리에도 캐시한다. 앱 시작 시 [load] 를 한 번 호출한다.
class SettingsRepository {
  SettingsRepository(this._db, this._secureStorage);

  final AppDatabase _db;
  final FlutterSecureStorage _secureStorage;

  static const String _apiKeyStorageKey = 'gemini_api_key';
  static const String externalTransferKey = 'external_transfer_enabled';
  static const String geminiModelKey = 'gemini_model';

  bool _externalTransferEnabled = true;

  /// 외부 전송 허용 여부(캐시). false 면 Gemini 호출 없이 규칙 파서만 쓴다.
  bool get externalTransferEnabled => _externalTransferEnabled;

  Future<void> load() async {
    final value = await _db.readSetting(externalTransferKey);
    _externalTransferEnabled = value != 'false';
  }

  Stream<bool> watchExternalTransferEnabled() =>
      _db.watchSetting(externalTransferKey).map((value) => value != 'false');

  Future<void> setExternalTransferEnabled(bool enabled) async {
    _externalTransferEnabled = enabled;
    await _db.writeSetting(externalTransferKey, enabled.toString());
  }

  Future<String?> readGeminiApiKey() async {
    final key = await _secureStorage.read(key: _apiKeyStorageKey);
    return key == null || key.isEmpty ? null : key;
  }

  Future<void> writeGeminiApiKey(String? key) {
    if (key == null || key.trim().isEmpty) {
      return _secureStorage.delete(key: _apiKeyStorageKey);
    }
    return _secureStorage.write(key: _apiKeyStorageKey, value: key.trim());
  }

  Future<String> readGeminiModel() async =>
      (await _db.readSetting(geminiModelKey)) ?? GeminiExtractor.defaultModel;

  Stream<String> watchGeminiModel() => _db
      .watchSetting(geminiModelKey)
      .map((value) => value ?? GeminiExtractor.defaultModel);

  Future<void> setGeminiModel(String model) => _db.writeSetting(
    geminiModelKey,
    model.trim().isEmpty ? GeminiExtractor.defaultModel : model.trim(),
  );
}
