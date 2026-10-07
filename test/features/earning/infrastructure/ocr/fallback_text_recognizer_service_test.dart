import 'package:driver_analytics_app/features/earning/infrastructure/ocr/fallback_text_recognizer_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/ocr/text_recognizer_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRecognizer implements TextRecognizerService {
  final String? result;
  final Object? error;
  bool disposed = false;
  bool called = false;

  _FakeRecognizer.returning(this.result) : error = null;
  _FakeRecognizer.throwing(this.error) : result = null;

  @override
  Future<String> recognizeText(String imagePath) async {
    called = true;
    if (error != null) throw error!;
    return result!;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

void main() {
  group('FallbackTextRecognizerService', () {
    test('usa o resultado do primary quando ele funciona', () async {
      final primary = _FakeRecognizer.returning('texto da nuvem');
      final fallback = _FakeRecognizer.returning('texto do ml kit');
      final service = FallbackTextRecognizerService(primary: primary, fallback: fallback);

      final text = await service.recognizeText('img.png');

      expect(text, 'texto da nuvem');
      expect(fallback.called, isFalse);
    });

    test('cai pro fallback quando o primary lança uma exceção (sem '
        'internet, timeout, erro HTTP)', () async {
      final primary = _FakeRecognizer.throwing(Exception('sem conexão'));
      final fallback = _FakeRecognizer.returning('texto do ml kit');
      final service = FallbackTextRecognizerService(primary: primary, fallback: fallback);

      final text = await service.recognizeText('img.png');

      expect(text, 'texto do ml kit');
      expect(fallback.called, isTrue);
    });

    test('cai pro fallback quando o primary devolve texto vazio', () async {
      final primary = _FakeRecognizer.returning('');
      final fallback = _FakeRecognizer.returning('texto do ml kit');
      final service = FallbackTextRecognizerService(primary: primary, fallback: fallback);

      final text = await service.recognizeText('img.png');

      expect(text, 'texto do ml kit');
    });

    test('dispose fecha os dois recognizers', () async {
      final primary = _FakeRecognizer.returning('x');
      final fallback = _FakeRecognizer.returning('y');
      final service = FallbackTextRecognizerService(primary: primary, fallback: fallback);

      await service.dispose();

      expect(primary.disposed, isTrue);
      expect(fallback.disposed, isTrue);
    });
  });
}
