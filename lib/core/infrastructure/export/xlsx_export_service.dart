import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/cost_category_extensions.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/infrastructure/geo/geo_lookup_service.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:excel/excel.dart';

/// Gera uma planilha .xlsx com todas as jornadas, ganhos e custos — só
/// pra inspeção manual dos dados em desenvolvimento (o botão que chama
/// isso só aparece em `kDebugMode`, ver `home_page.dart`).
class XlsxExportService {
  const XlsxExportService();

  List<int> build({
    required List<ShiftEntity> shifts,
    required List<EarningEntity> earnings,
    required List<CostEntity> costs,
    GeoLookupService? geoLookup,
  }) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet()!;
    excel.rename(defaultSheet, 'Jornadas');

    _writeShifts(excel['Jornadas'], shifts);
    _writeEarnings(excel['Ganhos'], earnings, geoLookup);
    _writeCosts(excel['Custos'], costs);

    return excel.encode()!;
  }

  void _writeShifts(Sheet sheet, List<ShiftEntity> shifts) {
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('status'),
      TextCellValue('início'),
      TextCellValue('fim'),
      TextCellValue('km inicial'),
      TextCellValue('km final'),
      TextCellValue('km rodado'),
      TextCellValue('ganhos declarados'),
      TextCellValue('tempo trabalhado (min)'),
      TextCellValue('tempo pausado (min)'),
      TextCellValue('pausas'),
    ]);

    for (final shift in shifts) {
      final pausedMinutes = shift.pauses
          .where((p) => p.endTime != null)
          .fold<int>(0, (t, p) => t + p.endTime!.difference(p.startTime).inMinutes);
      final workedMinutes = shift.endTime != null
          ? shift.endTime!.difference(shift.startTime).inMinutes - pausedMinutes
          : null;

      sheet.appendRow([
        TextCellValue(shift.id),
        TextCellValue(shift.status.name),
        DateTimeCellValue.fromDateTime(shift.startTime),
        shift.endTime == null ? null : DateTimeCellValue.fromDateTime(shift.endTime!),
        DoubleCellValue(shift.initialKm),
        shift.finalKm == null ? null : DoubleCellValue(shift.finalKm!),
        DoubleCellValue(shift.distanceKm),
        shift.earnings == null ? null : DoubleCellValue(shift.earnings!),
        workedMinutes == null ? null : IntCellValue(workedMinutes),
        IntCellValue(pausedMinutes),
        IntCellValue(shift.pauses.length),
      ]);
    }
  }

  void _writeEarnings(
    Sheet sheet,
    List<EarningEntity> earnings,
    GeoLookupService? geoLookup,
  ) {
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('jornada id'),
      TextCellValue('data'),
      TextCellValue('tipo'),
      TextCellValue('valor'),
      TextCellValue('descrição'),
      TextCellValue('app'),
      TextCellValue('tipo de serviço'),
      TextCellValue('tarifa'),
      TextCellValue('dinâmico'),
      TextCellValue('gorjeta'),
      TextCellValue('duração (min)'),
      TextCellValue('distância (km)'),
      TextCellValue('status da corrida'),
      TextCellValue('cep embarque'),
      TextCellValue('cep destino'),
      TextCellValue('bairro embarque'),
      TextCellValue('bairro destino'),
    ]);

    for (final earning in earnings) {
      sheet.appendRow([
        TextCellValue(earning.id),
        earning.shiftId == null ? null : TextCellValue(earning.shiftId!),
        DateTimeCellValue.fromDateTime(earning.occurredAt),
        TextCellValue(earning.kind.name),
        DoubleCellValue(earning.amount),
        earning.description == null ? null : TextCellValue(earning.description!),
        ...switch (earning) {
          RideEarningEntity(
            :final app,
            :final serviceType,
            :final fare,
            :final surge,
            :final tip,
            :final durationSeconds,
            :final distanceKm,
            :final status,
            :final pickupCep,
            :final destinationCep,
            :final pickupDistrictId,
            :final destinationDistrictId,
          ) =>
            [
              TextCellValue(app.label),
              TextCellValue(serviceType.label),
              DoubleCellValue(fare),
              DoubleCellValue(surge),
              DoubleCellValue(tip),
              IntCellValue((durationSeconds / 60).round()),
              DoubleCellValue(distanceKm),
              TextCellValue(status.label),
              pickupCep == null ? null : TextCellValue(pickupCep),
              destinationCep == null ? null : TextCellValue(destinationCep),
              _districtName(geoLookup, pickupDistrictId),
              _districtName(geoLookup, destinationDistrictId),
            ],
          _ => List<CellValue?>.filled(12, null),
        },
      ]);
    }
  }

  CellValue? _districtName(GeoLookupService? geoLookup, String? districtId) {
    if (geoLookup == null || districtId == null) return null;
    final id = int.tryParse(districtId);
    if (id == null) return null;
    final name = geoLookup.resolveDistrictName(id);
    return name == null ? null : TextCellValue(name);
  }

  void _writeCosts(Sheet sheet, List<CostEntity> costs) {
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('data'),
      TextCellValue('categoria'),
      TextCellValue('subcategoria'),
      TextCellValue('valor'),
      TextCellValue('descrição'),
      TextCellValue('odômetro'),
      TextCellValue('quantidade'),
      TextCellValue('unidade'),
      TextCellValue('tanque cheio'),
      TextCellValue('abastecimento anterior faltante'),
      TextCellValue('preço por unidade'),
    ]);

    for (final cost in costs) {
      sheet.appendRow([
        TextCellValue(cost.id),
        DateTimeCellValue.fromDateTime(cost.date),
        TextCellValue(cost.category.label),
        TextCellValue(_subcategoryLabel(cost)),
        DoubleCellValue(cost.amount),
        cost.description == null ? null : TextCellValue(cost.description!),
        ...switch (cost) {
          FuelCostEntity(
            :final odometerKm,
            :final quantity,
            :final quantityUnit,
            :final isFullTank,
            :final previousFillUpMissing,
            :final pricePerUnit,
          ) =>
            [
              DoubleCellValue(odometerKm),
              DoubleCellValue(quantity),
              TextCellValue(quantityUnit),
              TextCellValue(isFullTank ? 'sim' : 'não'),
              TextCellValue(previousFillUpMissing ? 'sim' : 'não'),
              pricePerUnit == null ? null : DoubleCellValue(pricePerUnit),
            ],
          MaintenanceCostEntity(:final odometerKm) => [
              odometerKm == null ? null : DoubleCellValue(odometerKm),
              null,
              null,
              null,
              null,
              null,
            ],
          ExpenseCostEntity() => List<CellValue?>.filled(6, null),
        },
      ]);
    }
  }

  String _subcategoryLabel(CostEntity cost) {
    return switch (cost) {
      FuelCostEntity(:final subcategory) => subcategory.label,
      MaintenanceCostEntity(:final subcategory) => subcategory.label,
      ExpenseCostEntity(:final subcategory) => subcategory.label,
    };
  }
}
