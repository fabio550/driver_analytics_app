import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/presentation/pages/home_page.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_theme.dart';
import 'package:driver_analytics_app/core/presentation/widgets/skeleton_box.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/application/state/cost_notifier.dart';
import 'package:driver_analytics_app/features/cost/application/state/cost_state.dart';
import 'package:driver_analytics_app/features/earning/application/providers/earning_provider.dart';
import 'package:driver_analytics_app/features/earning/application/state/earning_notifier.dart';
import 'package:driver_analytics_app/features/earning/application/state/earning_state.dart';
import 'package:driver_analytics_app/features/shift/application/providers/active_shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/providers/shift_provider.dart';
import 'package:driver_analytics_app/features/shift/application/state/active_shift_notifier.dart';
import 'package:driver_analytics_app/features/shift/application/state/active_shift_state.dart';
import 'package:driver_analytics_app/features/shift/application/state/shift_notifier.dart';
import 'package:driver_analytics_app/features/shift/application/state/shift_state.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/enums/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Os fakes substituem o `build()` original, que leria os use cases e,
/// por baixo, abriria o banco — o que não existe num widget test.
class _FakeShiftNotifier extends ShiftNotifier {
  _FakeShiftNotifier(this._state);

  final ShiftState _state;

  @override
  ShiftState build() => _state;

  @override
  Future<void> loadShifts() async {}
}

class _FakeCostNotifier extends CostNotifier {
  _FakeCostNotifier(this._state);

  final CostState _state;

  @override
  CostState build() => _state;

  @override
  Future<void> loadCosts() async {}
}

class _FakeEarningNotifier extends EarningNotifier {
  _FakeEarningNotifier(this._state);

  final EarningState _state;

  @override
  EarningState build() => _state;

  @override
  Future<void> loadEarnings() async {}
}

class _FakeActiveShiftNotifier extends ActiveShiftNotifier {
  @override
  ActiveShiftState build() => const ActiveShiftState();

  @override
  Future<void> restore() async {}
}

ShiftEntity _shift({
  required int day,
  required double earnings,
  required double km,
}) {
  final start = DateTime(2026, 9, day, 18);

  return ShiftEntity(
    id: 'shift-$day',
    status: ShiftStatus.submitted,
    initialKm: 84000,
    finalKm: 84000 + km,
    earnings: earnings,
    startTime: start,
    endTime: start.add(const Duration(hours: 7, minutes: 12)),
  );
}

Widget _app({
  required ShiftState shiftState,
  CostState costState = const CostState(status: LoadStatus.loaded),
  EarningState earningState = const EarningState(status: LoadStatus.loaded),
}) {
  return ProviderScope(
    overrides: [
      shiftNotifierProvider.overrideWith(() => _FakeShiftNotifier(shiftState)),
      costNotifierProvider.overrideWith(() => _FakeCostNotifier(costState)),
      earningNotifierProvider.overrideWith(() => _FakeEarningNotifier(earningState)),
      activeShiftNotifierProvider.overrideWith(_FakeActiveShiftNotifier.new),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const HomePage()),
  );
}

void main() {
  testWidgets('mostra esqueleto enquanto os dados não chegaram', (tester) async {
    await tester.pumpWidget(_app(shiftState: const ShiftState()));
    await tester.pump();

    expect(find.byType(SkeletonBox), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem jornada confirmada, convida a iniciar uma', (tester) async {
    await tester.pumpWidget(
      _app(shiftState: const ShiftState(status: LoadStatus.loaded)),
    );
    await tester.pump();

    expect(find.text('Nenhuma jornada ainda'), findsOneWidget);
    expect(find.text('Iniciar jornada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com jornadas, desenha o painel sem estourar o layout',
      (tester) async {
    await tester.pumpWidget(
      _app(
        shiftState: ShiftState(
          status: LoadStatus.loaded,
          shifts: [
            _shift(day: 9, earnings: 268.40, km: 142),
            _shift(day: 8, earnings: 231, km: 121),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Driver Analytics'), findsOneWidget);
    expect(find.text('ESTA SEMANA'), findsOneWidget);
    expect(find.text('ÚLTIMAS JORNADAS'), findsOneWidget);
    expect(find.text('Iniciar jornada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('erro de carga oferece tentar de novo', (tester) async {
    await tester.pumpWidget(
      _app(shiftState: const ShiftState(status: LoadStatus.error)),
    );
    await tester.pump();

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
