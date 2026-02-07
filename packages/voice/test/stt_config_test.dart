import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_voice/src/stt/stt_service.dart';

void main() {
  group('SttConfig', () {
    test('defaults to on-device recognition', () {
      const config = SttConfig();
      expect(config.onDevice, isTrue);
      expect(config.allowCloudFallback, isFalse);
    });
  });
}
