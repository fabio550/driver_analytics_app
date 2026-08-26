extension DurationExtensions on Duration {
  String get formattedHHmmss {
    String two(int n) => n.toString().padLeft(2, '0');

    final hours = two(inHours);
    final minutes = two(inMinutes % 60);
    final seconds = two(inSeconds % 60);

    return '$hours:$minutes:$seconds';
  }

  String get formattedHHmm {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(inHours)}:${two(inMinutes % 60)}';
  }
}
