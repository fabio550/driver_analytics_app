import 'package:driver_analytics_app/core/infrastructure/export/xlsx_export_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final xlsxExportServiceProvider = Provider<XlsxExportService>((ref) {
  return const XlsxExportService();
});
