import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formattedCurrency', () {
    test('agrupa milhar como o campo de entrada agrupa', () {
      // O CurrencyInputFormatter já usava NumberFormat pt_BR ao digitar.
      // Sem o mesmo agrupamento aqui, o app mostrava 1.545,00 no campo e
      // 1545,00 na lista pro mesmo valor.
      expect(1545.0.formattedCurrency, 'R\$ 1.545,00');
      expect(CurrencyInputFormatter.format(1545.0), '1.545,00');
    });

    test('valores abaixo de mil não ganham separador', () {
      expect(884.60.formattedCurrency, 'R\$ 884,60');
      expect(0.0.formattedCurrency, 'R\$ 0,00');
    });

    test('negativo mantém o sinal', () {
      expect((-150.0).formattedCurrency, 'R\$ -150,00');
    });
  });

  group('formattedKm', () {
    test('agrupa milhar e não mostra decimal', () {
      expect(84210.0.formattedKm, '84.210 km');
      expect(142.0.formattedKm, '142 km');
    });
  });
}
