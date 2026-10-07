import 'package:driver_analytics_app/features/analytics/domain/entities/operation_analytics.dart';

extension DistanceRangeLabel on DistanceRange {
  String get label {
    return switch (this) {
      DistanceRange.curta => 'Curta',
      DistanceRange.media => 'Média',
      DistanceRange.longa => 'Longa',
      DistanceRange.viagem => 'Viagem',
    };
  }
}
