class ShiftPauseFormEntry {
  final int id;
  final DateTime? startTime;
  final DateTime? endTime;

  const ShiftPauseFormEntry({required this.id, this.startTime, this.endTime});

  ShiftPauseFormEntry copyWith({DateTime? startTime, DateTime? endTime}) {
    return ShiftPauseFormEntry(
      id: id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftPauseFormEntry &&
          other.id == id &&
          other.startTime == startTime &&
          other.endTime == endTime);

  @override
  int get hashCode => Object.hash(id, startTime, endTime);
}
