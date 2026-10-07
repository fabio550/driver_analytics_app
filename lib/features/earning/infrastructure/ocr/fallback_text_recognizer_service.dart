import 'package:driver_analytics_app/features/earning/infrastructure/ocr/text_recognizer_service.dart';

/// Tenta [primary] (Cloud Vision) e cai pra [fallback] (ML Kit
/// on-device) se [primary] falhar por qualquer motivo — sem internet,
/// timeout, erro HTTP, resposta malformada, ou devolver texto vazio.
/// Não tenta adivinhar se há conexão antes: só tenta e trata a falha,
/// o que cobre tanto "sem internet" quanto "tem wifi mas sem rota de
/// verdade" (que uma checagem de conectividade não pegaria).
class FallbackTextRecognizerService implements TextRecognizerService {
  final TextRecognizerService primary;
  final TextRecognizerService fallback;

  const FallbackTextRecognizerService({required this.primary, required this.fallback});

  @override
  Future<String> recognizeText(String imagePath) async {
    try {
      final text = await primary.recognizeText(imagePath);
      if (text.trim().isNotEmpty) return text;
    } catch (_) {
      // Sem internet, timeout, erro HTTP, resposta malformada — qualquer
      // falha do motor em nuvem cai pro on-device em vez de propagar.
    }
    return fallback.recognizeText(imagePath);
  }

  @override
  Future<void> dispose() async {
    await primary.dispose();
    await fallback.dispose();
  }
}
