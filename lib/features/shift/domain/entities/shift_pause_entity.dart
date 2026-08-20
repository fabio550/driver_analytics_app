class ShiftPauseEntity {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;

  const ShiftPauseEntity({
    required this.id,
    required this.startTime,
    this.endTime,
  });

  bool get isRunning => endTime == null;

  Duration duration(DateTime now) {
    final end = endTime ?? now;
    return end.difference(startTime);
  }

  ShiftPauseEntity copyWith({
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ShiftPauseEntity(
      id: id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
