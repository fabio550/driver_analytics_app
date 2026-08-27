import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_category_icon.dart';
import 'package:flutter/material.dart';

class CostListTile extends StatelessWidget {
  final CostEntity cost;
  final VoidCallback? onTap;
  
  const CostListTile({
    super.key,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = cost.description;
    final hasDescription = description != null && description.trim().isNotEmpty;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              ..._buildStats(context),
              if (hasDescription) ...[
                const SizedBox(height: 10),
                Text(
                  '"$description"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CostCategoryIcon(category: cost.category),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _subcategoryLabel,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                cost.date.formattedFullDate,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          cost.amount.formattedCurrency,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String get _subcategoryLabel {
    return switch (cost) {
      FuelCostEntity(:final subcategory) => subcategory.label,
      MaintenanceCostEntity(:final subcategory) => subcategory.label,
      ExpenseCostEntity(:final subcategory) => subcategory.label,
    };
  }

  List<Widget> _buildStats(BuildContext context) {
    final stats = switch (cost) {
      FuelCostEntity(
        :final odometerKm,
        :final quantity,
        :final quantityUnit,
        :final pricePerUnit,
        :final isFullTank,
      ) =>
        [
          ('Km rodado', odometerKm.formattedKm),
          ('Quantidade', '${_formatQuantity(quantity)} $quantityUnit'),
          if (pricePerUnit != null)
            ('R\$/$quantityUnit', pricePerUnit.formattedCurrency),
          if (isFullTank) ('Tanque', 'Cheio'),
        ],
      MaintenanceCostEntity(:final odometerKm) => [
          if (odometerKm != null) ('Km do odômetro', odometerKm.formattedKm),
        ],
      ExpenseCostEntity() => const <(String, String)>[],
    };

    if (stats.isEmpty) return const [];

    return [
      const SizedBox(height: 10),
      Wrap(
        spacing: 18,
        runSpacing: 8,
        children: [
          for (final (label, value) in stats)
            _StatItem(label: label, value: value),
        ],
      ),
    ];
  }

  String _formatQuantity(double value) => value.toStringAsFixed(1).replaceAll('.', ',');
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
