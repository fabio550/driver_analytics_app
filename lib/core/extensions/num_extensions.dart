extension DoubleExtensions on double {
  String get formattedKm {
    return '${toStringAsFixed(0)} km';
  }

  String get formattedCurrency {
    return 'R\$ ${toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

extension NullableDoubleExtensions on double? {
  String get formattedCurrencyOrDash {
    final value = this;

    if (value == null) return '—';

    return value.formattedCurrency;
  }
}
