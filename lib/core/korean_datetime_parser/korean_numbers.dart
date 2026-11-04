/// 한국어 수사 → 정수 변환 유틸.
library;

const Map<String, int> _nativeHours = {
  '한': 1,
  '두': 2,
  '세': 3,
  '네': 4,
  '다섯': 5,
  '여섯': 6,
  '일곱': 7,
  '여덟': 8,
  '아홉': 9,
  '열': 10,
  '열한': 11,
  '열두': 12,
};

/// 정규식에서 "시" 앞에 올 수 있는 수 표현(아라비아 숫자 또는 고유어 수사).
/// 긴 수사("열두")가 짧은 수사("열")보다 먼저 오도록 정렬되어 있다.
const String hourNumberPattern = r'(?:\d{1,2}|열두|열한|열|아홉|여덟|일곱|여섯|다섯|네|세|두|한)';

/// "3", "세", "열두" 같은 시(時) 수 표현을 정수로 바꾼다. 해석 불가면 null.
int? parseHourNumber(String raw) {
  final text = raw.trim();
  return int.tryParse(text) ?? _nativeHours[text];
}
