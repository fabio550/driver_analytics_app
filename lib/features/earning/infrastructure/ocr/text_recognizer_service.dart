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

  // Scroll captures (screenshot empilhado) de vários prints do Uber
  // passam de 20-30 mil px de altura — decodificar isso no tamanho
  // original estoura memória/limite do decoder em vários aparelhos e o
  // OCR falha antes de devolver qualquer texto. Reduzir demais também
  // não serve: o primeiro teto (8000px) deixou o texto pequeno demais
  // pro ML Kit reconhecer qualquer caractere (0 corridas E nenhum texto
  // reconhecido). 14000px é uma folga mais conservadora — reduz menos
  // que a metade da altura original nesse tipo de print, mantendo o
  // texto legível, mas ainda evita decodificar o bitmap gigante inteiro.
  static const _maxHeightPx = 14000;

  MlKitTextRecognizerService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognizeText(String imagePath) async {
    final resizeLog = StringBuffer();
    final preparedPath = await _capImageHeight(imagePath, resizeLog);
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

    if (lines.isEmpty) {
      // Sem isso, "OCR rodou mas não achou nada" e "algo no
      // redimensionamento deu errado silenciosamente" ficam
      // indistinguíveis pra quem só vê a tela vazia — esse texto (que
      // não bate com nenhum padrão do parser) aparece no painel "Ver
      // texto reconhecido" e mostra exatamente o que aconteceu.
      return '[Diagnóstico: ML Kit não retornou nenhum bloco de texto '
          'para essa imagem.\n$resizeLog]';
    }

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
  /// em vez de travar a importação com um erro nosso. [log] recebe as
  /// dimensões encontradas e o que foi feito, pra aparecer no painel de
  /// diagnóstico se o OCR não achar nada.
  Future<String> _capImageHeight(String imagePath, StringBuffer log) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final descriptor = await ui.ImageDescriptor.encoded(
        await ui.ImmutableBuffer.fromUint8List(bytes),
      );

      log.writeln(
        'Imagem original: ${descriptor.width}x${descriptor.height}px, '
        '${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB.',
      );

      if (descriptor.height <= _maxHeightPx) {
        log.writeln('Abaixo do teto de $_maxHeightPx px — sem redimensionar.');
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
      if (byteData == null) {
        log.writeln('Redimensionamento falhou ao gerar os bytes do PNG.');
        return imagePath;
      }

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/ride_import_ocr_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(outPath).writeAsBytes(byteData.buffer.asUint8List());
      log.writeln('Redimensionada para ${targetWidth}x$_maxHeightPx px.');
      return outPath;
    } catch (error) {
      log.writeln('Erro ao tentar redimensionar: $error');
      return imagePath;
    }
  }
}
