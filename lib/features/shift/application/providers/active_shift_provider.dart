import 'package:driver_analytics_app/features/shift/application/state/active_shift_notifier.dart';
import 'package:driver_analytics_app/features/shift/application/state/active_shift_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeShiftNotifierProvider =
    NotifierProvider<ActiveShiftNotifier, ActiveShiftState>(
  ActiveShiftNotifier.new,
);
