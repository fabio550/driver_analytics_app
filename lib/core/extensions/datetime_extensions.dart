extension DateTimeExtensions on DateTime {
  String get formattedHHmm {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(hour)}:${two(minute)}';
  }
}
