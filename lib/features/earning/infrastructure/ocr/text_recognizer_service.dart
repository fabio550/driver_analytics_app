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

  // Prints de scroll-capture muito altos e estreitos (ex.: 540x16302px)
  // davam 0 blocos de texto mesmo depois de reescrever a imagem como PNG
  // limpo sem reduzir nada — ou seja, não era arquivo corrompido nem
  // memória. A explicação mais provável: modelos de detecção de texto
  // costumam redimensionar a imagem inteira pra um "canvas" de detecção
  // internamente (algo como um quadrado fixo), preservando a proporção.
  // Numa imagem com proporção 30:1 (muito mais alta que larga), esse
  // redimensionamento espreme a largura já pequena (540px) pra uma
  // fração ínfima, tornando o texto ilegível mesmo a olho nu num
  // screenshot desse redimensionamento — sem depender de tamanho de
  // arquivo/memória, só da proporção extrema.
  //
  // A correção é dividir a imagem em faixas horizontais e rodar o ML
  // Kit em cada uma separadamente: cada faixa mantém a largura original
  // (sem perda de resolução) mas com uma proporção muito menos extrema,
  // então o redimensionamento interno do detector não esmaga o texto.
  // 2000px de altura numa largura de ~540px dá uma proporção ~1:3,7 —
  // perto de recibo/nota fiscal, um formato que detectores de texto já
  // lidam bem, bem longe da proporção ~1:30 da imagem inteira.
  static const _stripHeightThreshold = 2500;
  static const _stripHeightPx = 2000;

  MlKitTextRecognizerService()
      : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognizeText(String imagePath) async {
    final log = StringBuffer();
    final lines = await _recognizeAllLines(imagePath, log);

    if (lines.isEmpty) {
      // Sem isso, "OCR rodou mas não achou nada" e "algo deu errado
      // silenciosamente" ficam indistinguíveis pra quem só vê a tela
      // vazia — esse texto (que não bate com nenhum padrão do parser)
      // aparece no painel "Ver texto reconhecido" e mostra exatamente
      // o que aconteceu.
      return '[Diagnóstico: ML Kit não retornou nenhum bloco de texto '
          'para essa imagem.\n$log]';
    }

    // O ML Kit não garante ordem de leitura topo->baixo em telas com
    // imagem no meio (mapa de cada corrida) — ele agrupa por blocos
    // visuais, e o destino de uma corrida pode acabar emitido depois
    // da tarifa da corrida seguinte. Cada linha carrega sua posição Y
    // (já ajustada pelo deslocamento da faixa, se veio de uma), então
    // ordenar por ela reconstrói a ordem visual real.
    lines.sort((a, b) => a.key.compareTo(b.key));
    return lines.map((e) => e.value).join('\n');
  }

  @override
  Future<void> dispose() => _recognizer.close();

  /// Decodifica a imagem original uma vez (via Skia) e, se for alta o
  /// bastante pra passar de [_stripHeightThreshold], processa em faixas
  /// horizontais de até [_stripHeightPx] — cada uma na largura original,
  /// sem perda de resolução. Devolve todas as linhas encontradas, com a
  /// posição Y de cada uma já somada ao deslocamento vertical da faixa
  /// de onde veio, pra a ordenação final funcionar como se fosse uma
  /// imagem só. [log] recebe o que foi feito, pra aparecer no painel de
  /// diagnóstico se nada for reconhecido.
  Future<List<MapEntry<double, String>>> _recognizeAllLines(
    String imagePath,
    StringBuffer log,
  ) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final descriptor = await ui.ImageDescriptor.encoded(
        await ui.ImmutableBuffer.fromUint8List(bytes),
      );
      final width = descriptor.width;
      final height = descriptor.height;

      log.writeln(
        'Imagem original ($imagePath): ${width}x$height'
        'px, ${(bytes.length / 1024 / 1024).toStringAsFixed(1)} MB.',
      );

      if (height <= _stripHeightThreshold) {
        log.writeln('Abaixo do teto de $_stripHeightThreshold px — '
            'processada direto, só higienizada como PNG.');
        final path = await _reencodeWhole(descriptor, width, height, log);
        return _recognizeFile(path);
      }

      final codec =
          await descriptor.instantiateCodec(targetWidth: width, targetHeight: height);
      final frame = await codec.getNextFrame();
      final fullImage = frame.image;
      codec.dispose();

      final stripCount = (height / _stripHeightPx).ceil();
      log.writeln('Acima do teto — dividida em $stripCount faixas de '
          'até $_stripHeightPx px de altura, largura original preservada.');

      final allLines = <MapEntry<double, String>>[];
      for (var s = 0; s < stripCount; s++) {
        final top = s * _stripHeightPx;
        final remaining = height - top;
        if (remaining <= 0) break;
        final stripHeight = remaining > _stripHeightPx ? _stripHeightPx : remaining;

        final stripImage = await _cropImage(fullImage, top, width, stripHeight);
        final stripPath = await _writeTempPng(stripImage, 'strip_$s');
        stripImage.dispose();

        final stripLines = await _recognizeFile(stripPath);
        for (final entry in stripLines) {
          allLines.add(MapEntry(entry.key + top, entry.value));
        }
        log.writeln('Faixa $s (y=$top..${top + stripHeight}): '
            '${stripLines.length} linha(s) reconhecida(s).');
      }

      fullImage.dispose();
      return allLines;
    } catch (error) {
      log.writeln('Erro ao processar a imagem: $error');
      return const [];
    }
  }

  /// Roda o ML Kit sobre um arquivo e devolve cada linha com sua posição
  /// Y original dentro DESSE arquivo (sem nenhum deslocamento — quem
  /// chama soma o deslocamento da faixa, se houver).
  Future<List<MapEntry<double, String>>> _recognizeFile(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final result = await _recognizer.processImage(inputImage);
    return [
      for (final block in result.blocks)
        for (final line in block.lines) MapEntry(line.boundingBox.top, line.text),
    ];
  }

  /// Recorta uma faixa horizontal de [src] (de [top] até [top]+[height],
  /// largura [width] inteira) numa imagem nova, na resolução original —
  /// sem nenhum redimensionamento, só recorte.
  Future<ui.Image> _cropImage(ui.Image src, int top, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final srcRect =
        ui.Rect.fromLTWH(0, top.toDouble(), width.toDouble(), height.toDouble());
    final dstRect = ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    canvas.drawImageRect(src, srcRect, dstRect, ui.Paint());
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    return image;
  }

  /// Reescreve a imagem inteira como PNG novo (sem recorte nem redução),
  /// só pra higienizar o arquivo antes do ML Kit — usado quando a altura
  /// já está abaixo do teto de divisão em faixas.
  Future<String> _reencodeWhole(
    ui.ImageDescriptor descriptor,
    int width,
    int height,
    StringBuffer log,
  ) async {
    try {
      final codec =
          await descriptor.instantiateCodec(targetWidth: width, targetHeight: height);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      codec.dispose();
      final path = await _writeTempPng(image, 'whole');
      image.dispose();
      return path;
    } catch (error) {
      log.writeln('Erro ao higienizar a imagem: $error');
      rethrow;
    }
  }

  Future<String> _writeTempPng(ui.Image image, String label) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Não consegui gerar os bytes do PNG ($label).');
    }
    final tempDir = await getTemporaryDirectory();
    final outPath = '${tempDir.path}/ride_import_ocr_${label}_'
        '${DateTime.now().microsecondsSinceEpoch}.png';
    await File(outPath).writeAsBytes(byteData.buffer.asUint8List());
    return outPath;
  }
}
