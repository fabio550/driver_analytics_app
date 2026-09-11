import 'package:driver_analytics_app/features/analytics/domain/value_objects/analytics_period.dart';
import 'package:driver_analytics_app/features/analytics/presentation/extensions/analytics_period_label_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('enclosing', () {
    test('a semana se compara com o mês', () {
      final week = AnalyticsPeriod.week(DateTime(2026, 9, 9));
      final enclosing = week.enclosing!;

      expect(enclosing.start, DateTime(2026, 9));
      expect(enclosing.end, DateTime(2026, 10));
      expect(enclosing.preset, AnalyticsPeriodPreset.month);
    });

    test('a semana que cruza a virada usa o mês em que começou', () {
      // 28/09/2026 é uma segunda: a semana vai até 04/10.
      final week = AnalyticsPeriod.week(DateTime(2026, 10, 1));
      final enclosing = week.enclosing!;

      expect(week.start, DateTime(2026, 9, 28));
      expect(enclosing.start, DateTime(2026, 9));
    });

    test('o mês se compara com o ano inteiro', () {
      final month = AnalyticsPeriod.month(DateTime(2026, 9, 9));
      final enclosing = month.enclosing!;

      expect(enclosing.start, DateTime(2026));
      expect(enclosing.end, DateTime(2027));
      expect(enclosing.contains(DateTime(2026, 1, 1)), isTrue);
      expect(enclosing.contains(DateTime(2026, 12, 31, 23)), isTrue);
      expect(enclosing.contains(DateTime(2027, 1, 1)), isFalse);
    });

    test('intervalo escolhido à mão não tem recorte mais largo', () {
      final custom = AnalyticsPeriod.custom(
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 20),
      );

      expect(custom.enclosing, isNull);
      expect(custom.enclosingAverageLabel, isNull);
    });
  });

  group('rótulos de média', () {
    test('nomeiam o período e a régua sem ambiguidade', () {
      final week = AnalyticsPeriod.week(DateTime(2026, 9, 9));
      final month = AnalyticsPeriod.month(DateTime(2026, 9, 9));

      expect(week.averageLabel, 'Média da semana');
      expect(week.enclosingAverageLabel, 'Média do mês');
      expect(month.averageLabel, 'Média do mês');
      expect(month.enclosingAverageLabel, 'Média do ano');
    });
  });
}
