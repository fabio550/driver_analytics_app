import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_lookup_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/ocr/fallback_text_recognizer_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/ocr/google_cloud_vision_text_recognizer_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/ocr/text_recognizer_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_parser.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/uber_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';

/// Passada no build/run via `--dart-define=GCV_API_KEY=...` — nunca
/// hardcoded aqui nem commitada. Vazia quando não configurada (ex.: dev
/// local sem a chave ainda, ou quem clonou o repo sem configurar nada),
/// e nesse caso o app roda só com o ML Kit, sem tentar a Cloud Vision.
/// Ver docs/google-cloud-vision-setup.md pra como gerar e restringir a
/// chave.
const _googleCloudVisionApiKey = String.fromEnvironment('GCV_API_KEY');

/// Abre o `geo.db` (asset copiado pro disco na primeira chamada) uma vez
/// e mantém a conexão — reaberta se o provider for descartado e lido de
/// novo (ex: hot restart).
final geoDatabaseProvider = FutureProvider<Database>((ref) async {
  final db = await openBundledGeoDatabase();
  ref.onDispose(db.close);
  return db;
});

final geoLookupServiceProvider = FutureProvider<GeoLookupService>((ref) async {
  final db = await ref.watch(geoDatabaseProvider.future);
  return SqliteGeoLookupService(db);
});

/// Só Uber por enquanto — troca por uma factory quando outro parser existir.
final rideParserProvider = Provider<RideParser>((ref) {
  return UberParser();
});

/// Um recognizer por tela de importação — fecha (libera o motor on-device
/// e o client HTTP da Cloud Vision, se estiver em uso) quando o provider
/// é descartado, ex: ao sair da tela.
///
/// Sem a chave configurada (`_googleCloudVisionApiKey` vazia), roda só
/// com o ML Kit — não tenta chamar a Cloud Vision sem credencial, isso
/// só daria erro de autenticação e adicionaria uma espera inútil antes
/// do fallback. Com a chave, a Cloud Vision é o motor principal (mais
/// preciso, mas exige internet) e o ML Kit vira fallback automático se
/// ela falhar por qualquer motivo — sem conexão, timeout, erro HTTP.
final textRecognizerServiceProvider = Provider<TextRecognizerService>((ref) {
  final mlKit = MlKitTextRecognizerService();

  if (_googleCloudVisionApiKey.isEmpty) {
    ref.onDispose(mlKit.dispose);
    return mlKit;
  }

  final service = FallbackTextRecognizerService(
    primary: GoogleCloudVisionTextRecognizerService(apiKey: _googleCloudVisionApiKey),
    fallback: mlKit,
  );
  ref.onDispose(service.dispose);
  return service;
});
