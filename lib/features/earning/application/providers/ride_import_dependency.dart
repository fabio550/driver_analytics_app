import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_lookup_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/ocr/text_recognizer_service.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/ride_parser.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/parser/uber_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';

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

/// Um recognizer por tela de importação — fecha (libera o modelo do ML
/// Kit) quando o provider é descartado, ex: ao sair da tela.
final textRecognizerServiceProvider = Provider<TextRecognizerService>((ref) {
  final service = MlKitTextRecognizerService();
  ref.onDispose(service.dispose);
  return service;
});
