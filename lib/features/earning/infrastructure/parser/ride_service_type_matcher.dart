import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';

/// Reconhece o [RideServiceType] a partir do texto bruto do parser.
/// Compartilhado entre `PreviewRideImportUseCase` (decide se a corrida é
/// importável) e `RideBatchDeduper` (agrupa leituras da mesma corrida) —
/// os dois precisam do tipo já normalizado, não do texto bruto, que pode
/// variar entre leituras da mesma corrida por ruído de OCR.
class RideServiceTypeMatcher {
  const RideServiceTypeMatcher._();

  static final RegExp _reUberX = RegExp(r'\buber ?x\b');
  static final RegExp _reComfort = RegExp(r'\bcomfort\b');
  static final RegExp _reBlack = RegExp(r'\bblack\b');
  static final RegExp _reMoto = RegExp(r'\bmoto\b');
  static final RegExp _reFlash = RegExp(r'\bflash\b');
  static final RegExp _rePet = RegExp(r'\bpet\b');
  static final RegExp _rePrioridade = RegExp(r'\bprioridade\b');

  /// O OCR às vezes cola um caractere de ícone (um pino/bullet do layout
  /// mal reconhecido) direto na frente do nome do serviço — "8 uber X",
  /// "& uber X", "8 Comfort" — em vez do texto limpo. Comparar por
  /// igualdade exata perdia essas corridas inteiras como "não
  /// reconhecidas" por causa de 1 caractere solto. `\b` (borda de
  /// palavra) tolera esse prefixo solto sem abrir mão de precisão: uma
  /// variante real diferente como "UberXL" não bate com `uber ?x\b`,
  /// porque não há borda de palavra entre o "x" e o "l" que vem colado
  /// nele.
  static RideServiceType? match(String raw) {
    final normalized = raw.trim().toLowerCase();

    if (_reUberX.hasMatch(normalized)) return RideServiceType.uberX;
    if (_reComfort.hasMatch(normalized)) return RideServiceType.comfort;
    if (_reBlack.hasMatch(normalized)) return RideServiceType.black;
    if (_reMoto.hasMatch(normalized)) return RideServiceType.moto;
    if (_reFlash.hasMatch(normalized)) return RideServiceType.flash;
    if (_rePet.hasMatch(normalized)) return RideServiceType.pet;
    if (_rePrioridade.hasMatch(normalized)) return RideServiceType.priority;
    return null;
  }
}
