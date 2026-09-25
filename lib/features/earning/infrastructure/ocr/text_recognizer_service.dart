import 'dart:io';
import 'dart:ui' as ui;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

abstract class TextRecognizerService {
  /// Roda OCR on-device sobre a imagem em [imagePath] e devolve o texto
  /// reconhecido, na mesma forma que o parser espera (o texto que o ML
  /// Kit extrai de um screenshot da tela de corridas do Uber).
  Future<String> recognizeText(String imagePath);

  Future<void> dispose();
}

class MlKitTextRecognizerService implements TextRecognizerService {
  final TextRecognizer _recognizer;

  // Scroll captures (screenshot empilhado) podem passar de 10-15 mil px
  // de altura. Decodificar um bitmap desse tamanho estoura o limite de
  // alocação do decoder/Skia em vários aparelhos e o ML Kit falha (ou o
  // app trava) antes de devolver qualquer texto — por isso o print
  // grande "nem aparece a opção de ver texto": o OCR nunca chega a
  // rodar. Reduzir a altura antes de mandar pro ML Kit evita isso sem
  // perder legibilidade (o texto do Uber continua nítido bem abaixo
  // desse teto).
  static const _maxHeightPx = 8000;

  MlKitTextRecognizerService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognizeText(String imagePath) async {
    final preparedPath = await _capImageHeight(imagePath);
    final inputImage = InputImage.fromFilePath(preparedPath);
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

  /// Se a imagem for mais alta que [_maxHeightPx], usa [ui.ImageDescriptor]
  /// pra decodificar já pedindo o tamanho reduzido (o decoder faz o
  /// downscale, então nunca aloca o bitmap gigante original por inteiro)
  /// e escreve o resultado num PNG temporário. Devolve o caminho
  /// original se não precisar reduzir ou se algo falhar — nesse caso o
  /// ML Kit tenta com a imagem original, mesmo sabendo que pode falhar,
  /// em vez de travar a importação com um erro nosso.
  Future<String> _capImageHeight(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final descriptor = await ui.ImageDescriptor.encoded(
        await ui.ImmutableBuffer.fromUint8List(bytes),
      );

      if (descriptor.height <= _maxHeightPx) {
        return imagePath;
      }

      final scale = _maxHeightPx / descriptor.height;
      final targetWidth = (descriptor.width * scale).round();

      final codec = await descriptor.instantiateCodec(
        targetHeight: _maxHeightPx,
        targetWidth: targetWidth,
      );
      final frame = await codec.getNextFrame();
      final resized = frame.image;

      final byteData = await resized.toByteData(format: ui.ImageByteFormat.png);
      resized.dispose();
      codec.dispose();
      if (byteData == null) return imagePath;

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/ride_import_ocr_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(outPath).writeAsBytes(byteData.buffer.asUint8List());
      return outPath;
    } catch (_) {
      return imagePath;
    }
  }
}
