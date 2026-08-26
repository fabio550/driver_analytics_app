extension DurationExtensions on Duration {
  String get formatted {
    String two(int value) => value.toString().padLeft(2, '0');

    final hours = two(inHours);
    final minutes = two(inMinutes.remainder(60));
    final seconds = two(inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }
}
