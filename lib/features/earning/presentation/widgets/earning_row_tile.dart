import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/ride_status.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/earning_kind_icon.dart';
import 'package:flutter/material.dart';

class EarningRowTile extends StatelessWidget {
  final EarningEntity earning;
  final VoidCallback? onTap;

  const EarningRowTile({super.key, required this.earning, this.onTap});

  bool get _isCancelledRide {
    final e = earning;
    return e is RideEarningEntity && e.status == RideStatus.cancelled;
  }

  String get _title {
    return switch (earning) {
      RideEarningEntity(:final serviceType, :final status) => status == RideStatus.cancelled
          ? '${serviceType.label} · cancelada'
          : serviceType.label,
      PromotionEarningEntity() => 'Promoção',
      AdjustmentEarningEntity() => 'Ajuste',
    };
  }

  String get _subtitle {
    return switch (earning) {
      RideEarningEntity(:final occurredAt, :final duration, :final distanceKm) =>
        '${occurredAt.formattedHHmm} · ${duration.inMinutes} min · '
            '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km',
      PromotionEarningEntity(:final description, :final occurredAt) =>
        _descriptionOr(description, occurredAt),
      AdjustmentEarningEntity(:final description, :final occurredAt) =>
        _descriptionOr(description, occurredAt),
    };
  }

  String _descriptionOr(String? description, DateTime occurredAt) {
    if (description != null && description.trim().isNotEmpty) return description;
    return occurredAt.formattedHHmm;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cancelled = _isCancelledRide;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          children: [
            EarningKindIcon(kind: earning.kind, size: 32),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cancelled ? colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _subtitle,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              earning.amount.formattedCurrency,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cancelled ? colorScheme.onSurfaceVariant : null,
                decoration: cancelled ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}