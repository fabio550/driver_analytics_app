class ParsedRide {
  final DateTime startedAt;
  final String serviceType;
  final String status;
  final double fareBrl;
  final double? surgeBrl;
  final double? tipBrl;
  final int? durationSeconds;
  final double? distanceKm;
  final String? pickupPostalCode;
  final String? destinationPostalCode;
  final String rawOcrText;

  const ParsedRide({
    required this.startedAt,
    required this.serviceType,
    required this.status,
    required this.fareBrl,
    this.surgeBrl,
    this.tipBrl,
    this.durationSeconds,
    this.distanceKm,
    this.pickupPostalCode,
    this.destinationPostalCode,
    required this.rawOcrText,
  });
}
