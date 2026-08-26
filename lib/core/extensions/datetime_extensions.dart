extension DateTimeExtensions on DateTime {
  String get formattedHHmm {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(hour)}:${two(minute)}';
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
}
