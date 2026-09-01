extension DoubleExtensions on double {
  String get formattedKm {
    return '${toStringAsFixed(0)} km';
  }

  String get formattedCurrency {
    return 'R\$ ${toStringAsFixed(2).replaceAll('.', ',')}';
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
