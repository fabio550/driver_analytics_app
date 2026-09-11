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
  testWidgets('splits the gross into profit and cost', (tester) async {
    await tester.pumpWidget(
      _wrap(const RevenueSplitBar(revenue: 1545, cost: 660.40)),
    );

    expect(find.text('Lucro'), findsOneWidget);
    expect(find.text('R\$ 884,60'), findsOneWidget);
    expect(find.text('Custos'), findsOneWidget);
    expect(find.text('R\$ 660,40'), findsOneWidget);
  });

  testWidgets('a period that lost money still renders, with the loss signed',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const RevenueSplitBar(revenue: 100, cost: 250)),
    );

    expect(find.text('R\$ -150,00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty period renders without dividing by zero',
      (tester) async {
    await tester.pumpWidget(_wrap(const RevenueSplitBar(revenue: 0, cost: 0)));

    expect(find.text('R\$ 0,00'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
