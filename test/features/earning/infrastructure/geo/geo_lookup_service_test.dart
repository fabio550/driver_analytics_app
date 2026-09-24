import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_lookup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('SqliteGeoLookupService', () {
    late Database db;
    late SqliteGeoLookupService service;

    setUpAll(() {
      db = sqlite3.open('assets/geo/geo.db', mode: OpenMode.readOnly);
      service = SqliteGeoLookupService(db);
    });

    tearDownAll(() {
      db.close();
    });

    test('resolve CEP do Tatuapé (usado no texto de exemplo da Uber)', () {
      final match = service.resolvePostalCode('03317-000');
      expect(match, isNotNull);
      expect(match!.districtName, 'Tatuape');
      expect(match.districtType, 'sp_district');
      expect(match.zoneName, 'Zona Leste');
    });

    test('resolve CEP do Itaim Bibi', () {
      final match = service.resolvePostalCode('04551-060');
      expect(match, isNotNull);
      expect(match!.districtName, 'Itaim Bibi');
      expect(match.zoneName, 'Zona Oeste');
    });

    test('resolve CEP da Bela Vista (Centro)', () {
      final match = service.resolvePostalCode('01310-100');
      expect(match, isNotNull);
      expect(match!.districtName, 'Bela Vista');
      expect(match.zoneName, 'Centro');
    });

    test('resolve CEP de município da Grande SP (fora da capital)', () {
      final match = service.resolvePostalCode('07159-605');
      expect(match, isNotNull);
      expect(match!.districtName, 'Guarulhos');
      expect(match.districtType, 'municipality');
      expect(match.zoneName, 'Grande SP');
    });

    test('CEP fora da base retorna null', () {
      final match = service.resolvePostalCode('99999-999');
      expect(match, isNull);
    });
  });
}
