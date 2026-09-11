import 'package:driver_analytics_app/core/extensions/duration_extensions.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/currency_field.dart';
import 'package:driver_analytics_app/features/earning/domain/enums/earning_field.dart';
import 'package:driver_analytics_app/features/earning/presentation/dialogs/quick_ride_sheet.dart';
import 'package:driver_analytics_app/features/earning/presentation/extensions/ride_extensions.dart';
import 'package:driver_analytics_app/features/earning/presentation/state/ride_draft.dart';
import 'package:driver_analytics_app/features/shift/domain/entities/shift_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// O que o diálogo de finalizar devolve. [rides] pode vir vazio: detalhar
/// corrida a corrida é opcional.
class FinishShiftResult {
  final double finalKm;
  final double? earnings;
  final List<RideDraft> rides;

  const FinishShiftResult({
    required this.finalKm,
    required this.earnings,
    required this.rides,
  });
}

/// Fecha a jornada: km final, ganho bruto e, se o motorista quiser, as
/// corridas do turno.
///
/// As corridas entram aqui, e não na tela da jornada em andamento, porque
/// é aqui que o turno é fechado — e lançadas daqui elas já nascem com o
/// shiftId da jornada certa, sem ninguém precisar escolher a jornada
/// numa lista depois.
class FinishShiftDialog extends StatefulWidget {
  final ShiftEntity shift;
  final DateTime now;

  const FinishShiftDialog({super.key, required this.shift, required this.now});

  static Future<FinishShiftResult?> show(
    BuildContext context, {
    required ShiftEntity shift,
    required DateTime now,
  }) {
    return showModalBottomSheet<FinishShiftResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FinishShiftDialog(shift: shift, now: now),
    );
  }

  @override
  State<FinishShiftDialog> createState() => _FinishShiftDialogState();
}

class _FinishShiftDialogState extends State<FinishShiftDialog> {
  final _finalKmController = TextEditingController();
  final _earningsController = TextEditingController();
  final _rides = <RideDraft>[];

  double? get _finalKm =>
      double.tryParse(_finalKmController.text.replaceAll(',', '.'));

  double get _earnings => CurrencyInputFormatter.toDouble(_earningsController.text);

  bool get _kmIsTooLow =>
      _finalKm != null && _finalKm! <= widget.shift.initialKm;

  bool get _isValid =>
      _finalKm != null && !_kmIsTooLow && _earningsController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // CurrencyField não expõe onChanged — escuta o controller direto pra
    // reavaliar _isValid a cada dígito digitado.
    _earningsController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _earningsController.removeListener(_onChanged);
    _finalKmController.dispose();
    _earningsController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_isValid) return;
    Navigator.of(context).pop(
      FinishShiftResult(
        finalKm: _finalKm!,
        earnings: _earnings,
        rides: List.unmodifiable(_rides),
      ),
    );
  }

  Future<void> _addRide() async {
    final draft = await QuickRideSheet.show(context, initialTime: widget.now);
    if (draft == null || !mounted) return;

    setState(() {
      _rides
        ..add(draft)
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Finalizar jornada',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Km inicial ${widget.shift.initialKm.formattedKm} · '
                '${widget.shift.elapsedTime(widget.now).formattedHHmm} de jornada',
                style: textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)
                    .tabular,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _finalKmController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Km final',
                  suffixText: 'km',
                  errorText: _kmIsTooLow ? 'Deve ser maior que o km inicial' : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.md),
              CurrencyField<EarningField>(
                label: 'Ganho bruto',
                errors: const [],
                controller: _earningsController,
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(color: colorScheme.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.md),
              _ridesSection(context),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.fieldPadding),
                  Expanded(
                    flex: 3,
                    child: FilledButton(
                      onPressed: _isValid ? _confirm : null,
                      child: const Text('Finalizar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ridesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'CORRIDAS',
              style: AppTextStyles.eyebrow.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              child: Text(
                'OPCIONAL',
                style: AppTextStyles.badgeStrong.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Detalhar corrida a corrida alimenta as análises de receita e '
          'operação. Dá pra finalizar sem isso e lançar depois.',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.fieldPadding),
        for (var i = 0; i < _rides.length; i++) ...[
          _RideRow(
            draft: _rides[i],
            onRemove: () => setState(() => _rides.removeAt(i)),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        OutlinedButton.icon(
          onPressed: _addRide,
          icon: const Icon(Icons.add),
          label: const Text('Adicionar corrida'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
        if (_rides.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_rides.length} '
            '${_rides.length == 1 ? 'corrida detalhada' : 'corridas detalhadas'}',
            style: textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)
                .tabular,
          ),
        ],
      ],
    );
  }
}

class _RideRow extends StatelessWidget {
  final RideDraft draft;
  final VoidCallback onRemove;

  const _RideRow({required this.draft, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final distance = draft.distanceKm.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.fieldPadding, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.serviceType.label,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${draft.duration.inMinutes} min · $distance km',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant)
                      .tabular,
                ),
              ],
            ),
          ),
          Text(
            draft.amount.formattedCurrency,
            style: textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)
                .tabular,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Remover corrida',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
