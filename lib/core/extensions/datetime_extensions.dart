extension DateTimeExtensions on DateTime {
  String get formattedHHmm {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(hour)}:${two(minute)}';
  }

  String get formattedDDMMYYYY {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(day)}/${two(month)}/$year';
  }

  String get formattedDDMMYYYYHHmm {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(day)}/${two(month)}/$year '
        '${two(hour)}:${two(minute)}';
  }

  String get formattedFullDate {
    const weekdays = ['segunda','terça','quarta','quinta','sexta','sábado','domingo',];

    final weekdayName = weekdays[weekday - 1];

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(day)}/${two(month)}/$year · $weekdayName';
  }

  /// Dia e dia da semana, sem o ano — cabe nas listas onde o mês já
  /// aparece no cabeçalho do grupo ("09/09 · terça").
  String get formattedDayAndWeekday {
    const weekdays = ['segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'];

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(day)}/${two(month)} · ${weekdays[weekday - 1]}';
  }

  /// Mês e ano em caixa alta, pro cabeçalho de grupo das listas.
  String get formattedMonthAndYear {
    const months = [
      'JANEIRO', 'FEVEREIRO', 'MARÇO', 'ABRIL', 'MAIO', 'JUNHO',
      'JULHO', 'AGOSTO', 'SETEMBRO', 'OUTUBRO', 'NOVEMBRO', 'DEZEMBRO',
    ];

    return '${months[month - 1]} $year';
  }
}
