import 'dart:io';

import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_match.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

abstract class GeoLookupService {
  /// Resolve um CEP no formato "NNNNN-NNN" para o distrito/zona que o
  /// contém. Retorna null se o CEP não estiver na base local.
  GeoMatch? resolvePostalCode(String postalCode);

  /// Nome do distrito a partir do seu id — usado pra mostrar o nome em
  /// vez do id numérico cru em telas que só guardaram o id (ex.: o
  /// ranking de bairros das Análises, que lê `pickupDistrictId` direto
  /// da ride já salva, sem o [GeoMatch] completo que existia na hora da
  /// importação). Retorna null se o id não existir na base local.
  String? resolveDistrictName(int districtId);
}

/// Consulta postal_codes -> districts -> zones num `geo.db` já aberto.
/// Recebe o [Database] pronto para que a lógica de consulta seja testável
/// sem depender do Flutter (asset bundle, path_provider).
class SqliteGeoLookupService implements GeoLookupService {
  final Database _db;

  const SqliteGeoLookupService(this._db);

  @override
  GeoMatch? resolvePostalCode(String postalCode) {
    final result = _db.select(
      '''
      select
        d.id as district_id,
        d.name as district_name,
        d.type as district_type,
        z.id as zone_id,
        z.name as zone_name
      from postal_codes p
      join districts d on d.id = p.district_id
      join zones z on z.id = d.zone_id
      where p.postal_code = ?
      limit 1
      ''',
      [postalCode],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    return GeoMatch(
      districtId: row['district_id'] as int,
      districtName: row['district_name'] as String,
      districtType: row['district_type'] as String,
      zoneId: row['zone_id'] as int,
      zoneName: row['zone_name'] as String,
    );
  }

  @override
  String? resolveDistrictName(int districtId) {
    final result = _db.select(
      'select name from districts where id = ? limit 1',
      [districtId],
    );
    if (result.isEmpty) return null;
    return result.first['name'] as String;
  }
}

/// Copia o `geo.db` empacotado como asset para um arquivo real (sqlite3
/// não abre bytes de asset diretamente) e o abre em modo leitura.
/// Idempotente: só copia na primeira chamada de cada instalação.
Future<Database> openBundledGeoDatabase({
  String assetPath = 'assets/geo/geo.db',
  String fileName = 'geo.db',
}) async {
  final supportDir = await getApplicationSupportDirectory();
  final dbFile = File(p.join(supportDir.path, fileName));

  if (!await dbFile.exists()) {
    final bytes = await rootBundle.load(assetPath);
    await dbFile.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
  }

  return sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
}
