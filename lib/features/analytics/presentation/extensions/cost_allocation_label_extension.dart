import 'package:driver_analytics_app/features/analytics/domain/entities/cost_allocation.dart';

extension CostAllocationGroupKindLabel on CostAllocationGroupKind {
  String get label {
    return switch (this) {
      CostAllocationGroupKind.fuel => 'Combustível',
      CostAllocationGroupKind.maintenance => 'Manutenção',
      CostAllocationGroupKind.financing => 'Financiamento',
      CostAllocationGroupKind.taxes => 'IPVA/Taxas',
      CostAllocationGroupKind.insurance => 'Seguro',
      CostAllocationGroupKind.direct => 'Estacionamento, lavagem, multa, pedágio e outros',
    };
  }
}
