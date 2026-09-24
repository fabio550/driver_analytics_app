import 'package:driver_analytics_app/features/earning/application/state/ride_import_notifier.dart';
import 'package:driver_analytics_app/features/earning/application/state/ride_import_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rideImportNotifierProvider =
    NotifierProvider<RideImportNotifier, RideImportState>(
  RideImportNotifier.new,
);
