import 'package:driver_analytics_app/features/earning/domain/enums/ride_app.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_service_type.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';

extension RideAppLabel on RideApp {
  String get label {
    return switch (this) {
      RideApp.uber => 'Uber',
    };
  }
}

extension RideServiceTypeLabel on RideServiceType {
  String get label {
    return switch (this) {
      RideServiceType.uberX => 'UberX',
      RideServiceType.comfort => 'Comfort',
      RideServiceType.black => 'Black',
      RideServiceType.deliveries => 'Entregas',
      RideServiceType.uberDispatch => 'Uber envios',
      RideServiceType.uberByTime => 'Uber por tempo',
    };
  }
}

extension RideStatusLabel on RideStatus {
  String get label {
    return switch (this) {
      RideStatus.completed => 'Concluída',
      RideStatus.cancelled => 'Cancelada',
    };
  }
}