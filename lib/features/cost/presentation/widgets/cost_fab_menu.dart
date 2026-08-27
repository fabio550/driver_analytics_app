import 'package:driver_analytics_app/features/cost/domain/enums/cost_category.dart';
import 'package:driver_analytics_app/features/cost/presentation/widgets/cost_category_icon.dart';
import 'package:flutter/material.dart';

class CostFabMenu extends StatefulWidget {
  final void Function(CostCategory category) onSelect;

  const CostFabMenu({super.key, required this.onSelect});

  @override
  State<CostFabMenu> createState() => _CostFabMenuState();
}

class _CostFabMenuState extends State<CostFabMenu> {
  bool _isOpen = false;

  void _toggle() => setState(() => _isOpen = !_isOpen);

  void _select(CostCategory category) {
    setState(() => _isOpen = false);
    widget.onSelect(category);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: Container(color: Colors.black.withOpacity(0.32)),
            ),
          ),
        Positioned.fill(
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isOpen) ...[
                      _MiniOption(
                        label: 'Despesa',
                        category: CostCategory.expense,
                        onTap: () => _select(CostCategory.expense),
                      ),
                      const SizedBox(height: 12),
                      _MiniOption(
                        label: 'Manutenção',
                        category: CostCategory.maintenance,
                        onTap: () => _select(CostCategory.maintenance),
                      ),
                      const SizedBox(height: 12),
                      _MiniOption(
                        label: 'Abastecimento',
                        category: CostCategory.fuel,
                        onTap: () => _select(CostCategory.fuel),
                      ),
                      const SizedBox(height: 14),
                    ],
                    FloatingActionButton(
                      onPressed: _toggle,
                      child: AnimatedRotation(
                        turns: _isOpen ? 0.125 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniOption extends StatelessWidget {
  final String label;
  final CostCategory category;
  final VoidCallback onTap;

  const _MiniOption({
    required this.label,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
          ),
          const SizedBox(width: 10),
          CostCategoryIcon(category: category, size: 40),
        ],
      ),
    );
  }
}