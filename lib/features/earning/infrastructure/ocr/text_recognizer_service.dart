import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class TextRecognizerService {
  /// Roda OCR on-device sobre a imagem em [imagePath] e devolve o texto
  /// reconhecido, na mesma forma que o parser espera (o texto que o ML
  /// Kit extrai de um screenshot da tela de corridas do Uber).
  Future<String> recognizeText(String imagePath);

  Future<void> dispose();
}

class MlKitTextRecognizerService implements TextRecognizerService {
  final TextRecognizer _recognizer;

  MlKitTextRecognizerService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);

    // O ML Kit não garante ordem de leitura topo->baixo em telas com
    // imagem no meio (mapa de cada corrida) — ele agrupa por blocos
    // visuais, e o destino de uma corrida pode acabar emitido depois
    // da tarifa da corrida seguinte. Cada TextLine carrega sua própria
    // posição (boundingBox) na tela, então ordenar por ela reconstrói
    // a ordem visual real em vez de confiar na ordem que o ML Kit
    // devolveu.
    final lines = <MapEntry<double, String>>[
      for (final block in result.blocks)
        for (final line in block.lines) MapEntry(line.boundingBox.top, line.text),
    ]..sort((a, b) => a.key.compareTo(b.key));

    return lines.map((e) => e.value).join('\n');
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
