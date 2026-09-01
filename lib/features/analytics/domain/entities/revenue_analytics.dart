import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';

/// De onde vem cada real da receita. `undetailed` é o caso do §7.1: jornada
/// finalizada com valor declarado mas sem nenhum ganho lançado — entra na
/// receita mas não dá pra abrir em fare/dinâmico/gorjeta.
enum RevenueSource { rides, surge, tip, promotion, adjustment, undetailed }

class RevenueSourceEntry {
  final RevenueSource source;
  final double amount;

  const RevenueSourceEntry({required this.source, required this.amount});
}

class ServiceTypeEntry {
  final RideServiceType serviceType;
  final double amount;
  final int rideCount;

  const ServiceTypeEntry({
    required this.serviceType,
    required this.amount,
    required this.rideCount,
  });
}

class AverageTicketStats {
  /// Receita das corridas remuneradas dividida pela contagem delas.
  /// Remuneradas = concluídas + canceladas com taxa (§ver calculadora).
  final double? amountPerPaidRide;
  final int paidRideCount;
  final int completedRideCount;

  const AverageTicketStats({
    required this.amountPerPaidRide,
    required this.paidRideCount,
    required this.completedRideCount,
  });

  static const empty = AverageTicketStats(
    amountPerPaidRide: null,
    paidRideCount: 0,
    completedRideCount: 0,
  );
}

class RevenueAnalytics {
  final List<RevenueSourceEntry> bySource;
  final List<ServiceTypeEntry> byServiceType;
  final AverageTicketStats averageTicket;
  final double totalRevenue;

  const RevenueAnalytics({
    required this.bySource,
    required this.byServiceType,
    required this.averageTicket,
    required this.totalRevenue,
  });

  static const empty = RevenueAnalytics(
    bySource: [],
    byServiceType: [],
    averageTicket: AverageTicketStats.empty,
    totalRevenue: 0,
  );

  bool get isEmpty => totalRevenue == 0 && byServiceType.isEmpty;
}
