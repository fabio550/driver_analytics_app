import 'package:driver_analytics_app/core/extensions/datetime_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/features/earning/domain/entities/earning_entity.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';

class _NoShiftSelection {
  const _NoShiftSelection();
}

const _noShift = _NoShiftSelection();

/// Seletor de turno pro formulário de ganho. Mostra o turno sugerido
/// (pré-selecionado a partir do horário do lançamento) já com valor
/// informado e quantos lançamentos existem; toque abre a lista completa
/// pra trocar, com a mesma informação em cada opção.
class ShiftPickerField extends StatelessWidget {
  final List<ShiftEntity> shifts;
  final Map<String, List<EarningEntity>> earningsByShift;
  final String? selectedShiftId;
  final ValueChanged<String?> onChanged;

  const ShiftPickerField({
    super.key,
    required this.shifts,
    required this.earningsByShift,
    required this.selectedShiftId,
    required this.onChanged,
  });

  ShiftEntity? get _selected {
    final id = selectedShiftId;
    if (id == null) return null;
    for (final shift in shifts) {
      if (shift.id == id) return shift;
    }
    return null;
  }

  String _subtitleFor(ShiftEntity shift) {
    final earnings = earningsByShift[shift.id] ?? const [];
    final informed = shift.earnings;
    final count = earnings.length;
    final noun = count == 1 ? 'lançamento' : 'lançamentos';
    return informed != null
        ? '${informed.formattedCurrency} informado · $count $noun'
        : '$count $noun · sem valor informado';
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    final selected = _selected;

    return InkWell(
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'Turno',
        ),
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected != null
                          ? '${selected.startTime.formattedDDMMYYYY} · ${selected.startTime.formattedHHmm}'
                          : 'Sem jornada',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (selected != null)
                      Text(
                        _subtitleFor(selected),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final sorted = [...shifts]..sort((a, b) => b.startTime.compareTo(a.startTime));

    final result = await showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'ESCOLHER TURNO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final shift in sorted)
                  ListTile(
                    leading: Icon(
                      shift.id == selectedShiftId ? Icons.check_circle : Icons.circle_outlined,
                      color: shift.id == selectedShiftId
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                    title: Text(
                      '${shift.startTime.formattedDDMMYYYY} · ${shift.startTime.formattedHHmm}',
                    ),
                    subtitle: Text(_subtitleFor(shift)),
                    onTap: () => Navigator.of(context).pop(shift.id),
                  ),
                ListTile(
                  leading: const SizedBox(width: 24),
                  title: const Text('Sem jornada'),
                  subtitle: const Text('Não associar a nenhum turno'),
                  onTap: () => Navigator.of(context).pop(_noShift),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted) return;
    // null = fechou sem escolher nada (toque fora, voltar) — mantém a
    // seleção atual. _noShift = escolheu "Sem jornada" de propósito.
    if (result == null) return;
    onChanged(result == _noShift ? null : result as String);
  }
}
