import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emite [DateTime.now()] imediatamente e depois a cada segundo.
///
/// Usado por qualquer widget que precise de um timer "ao vivo" (ex: duração
/// de uma jornada em andamento) sem persistir nada — só força o rebuild da
/// UI para recalcular durações a partir de timestamps já salvos.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
