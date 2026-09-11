import 'package:driver_analytics_app/core/presentation/theme/app_chart_colors.dart';
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

/// Só as fatias da barra, não os marcadores da legenda — os dois são
/// caixas decoradas da mesma cor.
Finder _segmentOf(Color color) {
  return find.descendant(
    of: find.byWidgetPredicate(
      (widget) =>
          widget is Row && widget.crossAxisAlignment == CrossAxisAlignment.stretch,
    ),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == color,
    ),
  );
}

void main() {
  testWidgets('a barra tem altura e largura de verdade', (tester) async {
    // Um DecoratedBox sem filho assume a menor altura possível. Com a Row
    // alinhando ao centro, os segmentos vinham com 0px e a barra sumia
    // inteira dentro do card, sem erro nenhum no console.
    await tester.pumpWidget(
      _wrap(const RevenueSplitBar(revenue: 1000, cost: 400)),
    );

    final profit = tester.getSize(_segmentOf(AppChartColors.profit));
    final cost = tester.getSize(_segmentOf(AppChartColors.cost));

    expect(profit.height, 10);
    expect(cost.height, 10);
    expect(profit.width, greaterThan(cost.width));
  });

  testWidgets('sem nada no período, sobra um trilho vazio visível',
      (tester) async {
    await tester.pumpWidget(_wrap(const RevenueSplitBar(revenue: 0, cost: 0)));

    final track = tester.getSize(
      _segmentOf(AppTheme.light.colorScheme.outlineVariant),
    );

    expect(track.height, 10);
    expect(track.width, greaterThan(0));
  });

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
