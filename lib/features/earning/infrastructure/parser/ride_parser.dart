import 'package:driver_analytics_app/features/earning/infrastructure/parser/parsed_ride.dart';

abstract class RideParser {
  bool canParse(String rawText);

  List<ParsedRide> parse(String rawText, {DateTime? now});
}
