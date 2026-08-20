// providers/entry_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:driver_analytics_app/features/shift/application/state/shift_notifier.dart';
import 'package:driver_analytics_app/features/shift/application/state/shift_state.dart';

final shiftNotifierProvider = NotifierProvider<ShiftNotifier, ShiftState>(
  ShiftNotifier.new,
);
