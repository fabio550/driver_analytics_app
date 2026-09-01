import 'package:driver_analytics_app/features/analytics/domain/entities/revenue_analytics.dart';

extension RevenueSourceLabel on RevenueSource {
  String get label {
    return switch (this) {
      RevenueSource.rides => 'Corridas',
      RevenueSource.surge => 'Dinâmico',
      RevenueSource.tip => 'Gorjeta',
      RevenueSource.promotion => 'Promoção',
      RevenueSource.adjustment => 'Ajuste',
      RevenueSource.undetailed => 'Sem detalhamento',
    };
  }
}
