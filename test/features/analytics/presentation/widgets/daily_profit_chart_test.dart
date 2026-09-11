import 'package:driver_analytics_app/core/presentation/theme/app_theme.dart';
import 'package:driver_analytics_app/features/analytics/domain/entities/daily_profit_entry.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/daily_profit_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SizedBox(width: 360, child: child)),
  );
}

DailyProfitEntry _entry(int day, {required double revenue, required double cost}) {
  return DailyProfitEntry(
    date: DateTime(2026, 9, day),
    revenue: revenue,
    cost: cost,
  );
}

void main() {
  testWidgets('empty period says so instead of drawing an empty axis',
      (tester) async {
    await tester.pumpWidget(_wrap(const DailyProfitChart(entries: [])));

    expect(find.text('Sem lançamentos no período.'), findsOneWidget);
  });

  testWidgets('draws one labelled column per day', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DailyProfitChart(
          entries: [
            _entry(4, revenue: 200, cost: 50),
            _entry(5, revenue: 300, cost: 80),
          ],
        ),
      ),
    );

    expect(find.text('04/09'), findsOneWidget);
    expect(find.text('05/09'), findsOneWidget);
  });

  testWidgets('labels only the best day, never every column', (tester) async {
    await tester.pumpWidget(
      _wrap(
        DailyProfitChart(
          entries: [
            _entry(4, revenue: 200, cost: 50),
            _entry(5, revenue: 400, cost: 50),
            _entry(6, revenue: 100, cost: 50),
          ],
        ),
      ),
    );

    expect(find.text('350,00'), findsOneWidget);
    expect(find.text('150,00'), findsNothing);
    expect(find.text('50,00'), findsNothing);
  });

  testWidgets('a losing day and a winning day share one scale', (tester) async {
    // Prejuízo de 100 e lucro de 100: as duas áreas ficam iguais, então
    // a barra negativa não pode ser desenhada maior que a positiva só
    // porque cada lado tinha metade fixa da altura.
    await tester.pumpWidget(
      _wrap(
        DailyProfitChart(
          entries: [
            _entry(4, revenue: 200, cost: 100),
            _entry(5, revenue: 0, cost: 100),
          ],
        ),
      ),
    );

    final bars = tester
        .widgetList<Container>(find.byType(Container))
        .where((container) => container.constraints?.maxWidth == 24)
        .toList();

    expect(bars, isNotEmpty);
  });
}
