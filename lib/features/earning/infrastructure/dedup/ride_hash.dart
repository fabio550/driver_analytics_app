import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Mesma composição do dedup_hash do doc original / migration Supabase:
/// app + ride_timestamp + fare_brl + pickup_postal_code + destination_postal_code.
/// Usado pra descartar corridas duplicadas quando o mesmo screenshot (ou
/// screenshots sobrepostos) é importado mais de uma vez.
class RideHash {
  const RideHash._();

  static String compute({
    required String app,
    required DateTime rideTimestamp,
    required double fareBrl,
    String? pickupPostalCode,
    String? destinationPostalCode,
  }) {
    final raw = [
      app,
      rideTimestamp.toUtc().toIso8601String(),
      fareBrl.toStringAsFixed(2),
      pickupPostalCode ?? '',
      destinationPostalCode ?? '',
    ].join('|');

    return sha256.convert(utf8.encode(raw)).toString();
  }
}
