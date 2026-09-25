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

  // O print grande de teste real (540x16302px, 3,4 MB) continuou dando
  // 0 blocos de texto mesmo sem NENHUM redimensionamento — ou seja,
  // tamanho/memória nunca foi a causa. Mas o ui.ImageDescriptor (decoder
  // do Flutter/Skia, usado só pra medir a imagem) lê as dimensões dela
  // sem problema, enquanto o ML Kit (que no Android decodifica via
  // BitmapFactory, uma implementação diferente) não encontra nada -
  // sugere que esse JPEG específico (gerado por um app de "scroll
  // capture") tem algo que o decoder nativo não tolera bem, mesmo sendo
  // um arquivo "válido" pro Skia. Por isso agora SEMPRE reescreve a
  // imagem como PNG novo via Skia antes de mandar pro ML Kit (mesmo
  // abaixo do teto de redimensionamento) — um PNG recém-gerado não
  // carrega qualquer estrutura interna estranha do arquivo original.
  static const _maxHeightPx = 30000;

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

  /// Sempre decodifica a imagem original via [ui.ImageDescriptor] (Skia)
  /// e reescreve como PNG novo — reduzindo a altura pro teto
  /// [_maxHeightPx] só se necessário, mas rodando a reescrita mesmo
  /// quando não precisa reduzir nada, já que o objetivo agora também é
  /// "higienizar" o arquivo (ver comentário em [_maxHeightPx]). Devolve
  /// o caminho original se a decodificação falhar — nesse caso o ML Kit
  /// tenta com o arquivo original, mesmo sabendo que pode falhar, em
  /// vez de travar a importação com um erro nosso. [log] recebe as
  /// dimensões encontradas e o que foi feito, pra aparecer no painel de
  /// diagnóstico se o OCR não achar nada.
  Future<String> _capImageHeight(String imagePath, StringBuffer log) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final descriptor = await ui.ImageDescriptor.encoded(
        await ui.ImmutableBuffer.fromUint8List(bytes),
      );

      log.writeln(
        'Imagem original ($imagePath): ${descriptor.width}x'
        '${descriptor.height}px, '
        '${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB.',
      );

      final needsDownscale = descriptor.height > _maxHeightPx;
      final targetHeight = needsDownscale ? _maxHeightPx : descriptor.height;
      final targetWidth = needsDownscale
          ? (descriptor.width * (_maxHeightPx / descriptor.height)).round()
          : descriptor.width;

      final codec = await descriptor.instantiateCodec(
        targetHeight: targetHeight,
        targetWidth: targetWidth,
      );
      final frame = await codec.getNextFrame();
      final resized = frame.image;

      final byteData = await resized.toByteData(format: ui.ImageByteFormat.png);
      resized.dispose();
      codec.dispose();
      if (byteData == null) {
        log.writeln('Reescrita falhou ao gerar os bytes do PNG.');
        return imagePath;
      }

      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/ride_import_ocr_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(outPath).writeAsBytes(byteData.buffer.asUint8List());
      log.writeln(
        needsDownscale
            ? 'Redimensionada e reescrita como PNG: ${targetWidth}x$targetHeight px.'
            : 'Reescrita como PNG sem redimensionar: ${targetWidth}x$targetHeight px.',
      );
      return outPath;
    } catch (error) {
      log.writeln('Erro ao tentar reescrever a imagem: $error');
      return imagePath;
    }
  }
}
