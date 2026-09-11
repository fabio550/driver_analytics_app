import 'package:intl/intl.dart';

/// Mesmo padrão que o `CurrencyInputFormatter` usa ao digitar. Sem isso o
/// app se contradizia: o campo mostrava `1.545,00` enquanto a lista
/// mostrava `1545,00` pro mesmo valor.
final _decimalFormat = NumberFormat('#,##0.00', 'pt_BR');
final _integerFormat = NumberFormat('#,##0', 'pt_BR');

extension DoubleExtensions on double {
  String get formattedKm {
    return '${_integerFormat.format(this)} km';
  }

  String get formattedCurrency {
    return 'R\$ ${_decimalFormat.format(this)}';
  }

  /// Só o número, sem o "R$" — pros rótulos de barra do gráfico, onde o
  /// símbolo repetido em toda barra vira ruído.
  String get formattedAmount {
    return _decimalFormat.format(this);
  }

  String get formattedPercent {
    return '${(this * 100).toStringAsFixed(0)}%';
  }
}

extension NullableDoubleExtensions on double? {
  String get formattedCurrencyOrDash {
    final value = this;

    if (value == null) return '—';

    return value.formattedCurrency;
  }

  String get formattedPercentOrDash {
    final value = this;

    if (value == null) return '—';

    return value.formattedPercent;
  }
}
