import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail_gen/video_thumbnail_gen.dart';

/// Quebra um vídeo (gravação de tela rolando a lista de corridas) em
/// frames individuais, prontos pra passar pro mesmo OCR que já processa
/// um print único. Existe porque a Uber passou a bloquear screenshot
/// nessa tela com um aviso cobrindo o conteúdo — gravação de tela não
/// aciona o mesmo bloqueio.
abstract class VideoFrameExtractorService {
  /// Extrai frames de [videoPath], em ordem cronológica, como arquivos
  /// de imagem temporários. O chamador é responsável por apagar cada
  /// arquivo depois de usar.
  Future<List<String>> extractFrames(String videoPath);
}

class ThumbnailGenVideoFrameExtractorService implements VideoFrameExtractorService {
  // Scroll de captura de tela costuma ser lento o bastante pra uma
  // corrida ficar visível por mais de 1s — menos que isso só multiplica
  // chamada de OCR (e de Cloud Vision, que tem cota) sem ganhar
  // cobertura real.
  static const _frameIntervalMs = 1200;

  // Teto de frames pra um vídeo longo não estourar a cota de OCR —
  // acima disso o intervalo entre frames cresce pra caber nesse teto,
  // em vez do número de chamadas crescer sem limite.
  static const _maxFrames = 40;

  const ThumbnailGenVideoFrameExtractorService();

  @override
  Future<List<String>> extractFrames(String videoPath) async {
    final metadata = await VideoThumbnail.getVideoMetadata(video: videoPath);
    final durationMs = metadata?.durationMs ?? 0;
    if (durationMs <= 0) return const [];

    final timesMs = _sampleTimes(durationMs);
    final tempDir = await getTemporaryDirectory();
    final batchId = DateTime.now().microsecondsSinceEpoch;
    final paths = <String>[];

    // `thumbnailDataList` (extração em lote) tem um bug na versão atual
    // do pacote — o lado nativo sempre espera um `timeMs` no payload,
    // mesmo pra esse método, e o wrapper Dart dele não manda, gerando
    // NPE do lado Android. `thumbnailData` (frame único) manda esse
    // campo certinho, então extrai um frame por vez em vez de em lote.
    for (var i = 0; i < timesMs.length; i++) {
      final bytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        timeMs: timesMs[i],
        imageFormat: ImageFormat.JPEG,
        quality: 90,
      );
      if (bytes == null) continue;

      final file = File('${tempDir.path}/ride_import_frame_${batchId}_$i.jpg');
      await file.writeAsBytes(bytes);
      paths.add(file.path);
    }

    return paths;
  }

  List<int> _sampleTimes(int durationMs) {
    final interval = durationMs / _maxFrames > _frameIntervalMs
        ? (durationMs / _maxFrames).ceil()
        : _frameIntervalMs;

    final times = <int>[];
    for (var t = 0; t < durationMs; t += interval) {
      times.add(t);
    }
    if (times.isEmpty) times.add(0);
    return times;
  }
}
