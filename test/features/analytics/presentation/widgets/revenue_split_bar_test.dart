import 'package:driver_analytics_app/core/presentation/theme/app_theme.dart';
import 'package:driver_analytics_app/features/analytics/presentation/widgets/revenue_split_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SizedBox(width: 360, child: child)),
  );
}

void main() {
  testWidgets('a legenda dá ganhos e custos, nunca o lucro', (tester) async {
    // O lucro é o número herói logo acima da barra: repetido aqui, o
    // card diria duas vezes a mesma coisa.
    await tester.pumpWidget(
      _wrap(const RevenueSplitBar(revenue: 1545, cost: 660.40)),
    );

    expect(find.text('Ganhos'), findsOneWidget);
    expect(find.text('R\$ 1.545,00'), findsOneWidget);
    expect(find.text('Custos'), findsOneWidget);
    expect(find.text('R\$ 660,40'), findsOneWidget);
    expect(find.text('Lucro'), findsNothing);
    expect(find.text('R\$ 884,60'), findsNothing);
  });

  testWidgets('um período no prejuízo ainda desenha', (tester) async {
    await tester.pumpWidget(
      _wrap(const RevenueSplitBar(revenue: 100, cost: 250)),
    );

    expect(find.text('R\$ 100,00'), findsOneWidget);
    expect(find.text('R\$ 250,00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('um período vazio não divide por zero', (tester) async {
    await tester.pumpWidget(_wrap(const RevenueSplitBar(revenue: 0, cost: 0)));

    expect(find.text('R\$ 0,00'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
