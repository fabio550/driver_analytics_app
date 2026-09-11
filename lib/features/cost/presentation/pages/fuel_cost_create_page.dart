import 'package:driver_analytics_app/core/domain/failures/validation_failure.dart';
import 'package:driver_analytics_app/core/extensions/num_extensions.dart';
import 'package:driver_analytics_app/core/presentation/formatters/currency_input_formatter.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_radius.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_text_styles.dart';
import 'package:driver_analytics_app/core/presentation/widgets/amount_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/date_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/decimal_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/distance_field.dart';
import 'package:driver_analytics_app/core/presentation/widgets/form_section.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/features/cost/application/providers/cost_provider.dart';
import 'package:driver_analytics_app/features/cost/domain/entities/cost_entity.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/cost_field.dart';
import 'package:driver_analytics_app/features/cost/domain/enums/fuel_subcategory.dart';
import 'package:driver_analytics_app/features/cost/presentation/extensions/subcategory_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FuelCostCreatePage extends ConsumerStatefulWidget {
  final FuelCostEntity? existing;

  const FuelCostCreatePage({super.key, this.existing});

  @override
  ConsumerState<FuelCostCreatePage> createState() => _FuelCostCreatePageState();
}

class _FuelCostCreatePageState extends ConsumerState<FuelCostCreatePage> {
  late FuelSubcategory _subcategory;
  late DateTime _date;
  late bool _isFullTank;
  late bool _previousFillUpMissing;
  late bool _showDescription;
  bool _isSubmitting = false;

  late final TextEditingController _amountController;
  late final TextEditingController _odometerController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _subcategory = existing?.subcategory ?? FuelSubcategory.ethanolCommon;
    _date = existing?.date ?? DateTime.now();
    _isFullTank = existing?.isFullTank ?? false;
    _previousFillUpMissing = existing?.previousFillUpMissing ?? false;
    _showDescription =
        existing?.description != null && existing!.description!.trim().isNotEmpty;

    _amountController = TextEditingController(
      text: existing != null ? CurrencyInputFormatter.format(existing.amount) : '',
    );
    _odometerController = TextEditingController(
      text: existing?.odometerKm.toStringAsFixed(0) ?? '',
    );
    _quantityController = TextEditingController(
      text: existing != null
          ? existing.quantity.toStringAsFixed(1).replaceAll('.', ',')
          : '',
    );
    _descriptionController = TextEditingController(text: existing?.description ?? '');

    // O preço por unidade é derivado do valor e da quantidade, e aparece
    // enquanto o usuário digita: é o número que ele compara com a bomba.
    _amountController.addListener(_onChanged);
    _quantityController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _amountController
      ..removeListener(_onChanged)
      ..dispose();
    _quantityController
      ..removeListener(_onChanged)
      ..dispose();
    _odometerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _quantityUnit => _subcategory == FuelSubcategory.energy ? 'kWh' : 'L';

  double get _amount => CurrencyInputFormatter.toDouble(_amountController.text);

  double get _quantity =>
      double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0;

  double? get _pricePerUnit {
    if (_amount <= 0 || _quantity <= 0) return null;
    return _amount / _quantity;
  }

  /// Abastecimento anterior a este, pra o campo de odômetro dizer de
  /// onde o motorista veio em vez de pedir um número no vácuo.
  FuelCostEntity? get _previousFillUp {
    final fuels = ref
        .watch(costNotifierProvider)
        .costs
        .whereType<FuelCostEntity>()
        .where((cost) => cost.id != widget.existing?.id && cost.date.isBefore(_date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return fuels.isEmpty ? null : fuels.first;
  }

  Future<void> _pickDate() async {
    final date = await DateField.pick(context, initialDate: _date);
    if (date == null || !mounted) return;
    setState(() => _date = date);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final odometerKm = double.tryParse(_odometerController.text.replaceAll(',', '.')) ?? 0;
    final description = _descriptionController.text.trim();
    final notifier = ref.read(costNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateCost(
        FuelCostEntity(
          id: widget.existing!.id,
          amount: _amount,
          date: _date,
          description: description.isEmpty ? null : description,
          subcategory: _subcategory,
          odometerKm: odometerKm,
          quantity: _quantity,
          isFullTank: _isFullTank,
          previousFillUpMissing: _previousFillUpMissing,
        ),
      );
    } else {
      await notifier.createFuelCost(
        subcategory: _subcategory,
        amount: _amount,
        date: _date,
        odometerKm: odometerKm,
        quantity: _quantity,
        isFullTank: _isFullTank,
        previousFillUpMissing: _previousFillUpMissing,
        description: description.isEmpty ? null : description,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ref.read(costNotifierProvider).validationFailures.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final failures = ref.watch(costNotifierProvider).validationFailures;
    List<ValidationFailure<CostField>> errorsFor(CostField field) {
      return failures.where((f) => f.field == field).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar abastecimento' : 'Novo abastecimento'),
      ),
      bottomNavigationBar: PrimaryButton(
        label: _isEditing ? 'Salvar alterações' : 'Salvar',
        isLoading: _isSubmitting,
        onPressed: _isSubmitting ? null : _submit,
      ),
      body: ScreenScrollView(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormSection(
            label: 'VALOR PAGO',
            children: [
              AmountField<CostField>(
                errors: errorsFor(CostField.amount),
                controller: _amountController,
                autofocus: !_isEditing,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FormSection(
            label: 'ABASTECIMENTO',
            children: [
              // Chip em vez de dropdown: um toque em vez de dois, e as
              // opções ficam visíveis sem abrir nada.
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: FuelSubcategory.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final subcategory = FuelSubcategory.values[i];

                    return ChoiceChip(
                      label: Text(subcategory.label),
                      selected: _subcategory == subcategory,
                      onSelected: (_) => setState(() => _subcategory = subcategory),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DateField(
                      label: 'Data',
                      value: _date,
                      errors: errorsFor(CostField.date),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DecimalField<CostField>(
                      label: 'Quantidade ($_quantityUnit)',
                      errors: errorsFor(CostField.quantity),
                      controller: _quantityController,
                      leading: const Icon(Icons.local_gas_station, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              DistanceField<CostField>(
                label: 'Km do odômetro',
                errors: errorsFor(CostField.odometerKm),
                onChanged: (_) {},
                controller: _odometerController,
              ),
              if (_previousFillUp != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    'Último abastecimento: '
                    '${_previousFillUp!.odometerKm.formattedKm}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                        .tabular,
                  ),
                ),
              ],
              if (_pricePerUnit != null) ...[
                const SizedBox(height: AppSpacing.md),
                _PricePerUnitReadout(
                  unit: _quantityUnit,
                  value: _pricePerUnit!,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          FormSection(
            label: 'PRECISÃO DO CONSUMO',
            children: [
              FormSwitchTile(
                title: 'Tanque cheio',
                subtitle: 'O km/$_quantityUnit só é calculado entre dois tanques '
                    'cheios. Sem isso, o consumo fica em branco.',
                value: _isFullTank,
                onChanged: (value) => setState(() => _isFullTank = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              FormSwitchTile(
                title: 'Abastecimento anterior em falta',
                subtitle: 'Marque se você abasteceu e não lançou. Quebra a '
                    'cadeia de consumo aqui.',
                value: _previousFillUpMissing,
                onChanged: (value) => setState(() => _previousFillUpMissing = value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_showDescription)
            TextField(
              controller: _descriptionController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Observação (opcional)'),
              maxLines: 2,
            )
          else
            OutlinedButton.icon(
              onPressed: () => setState(() => _showDescription = true),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar observação'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
        ],
      ),
    );
  }
}

/// O preço por litro nunca foi um campo: ele sai do valor dividido pela
/// quantidade. Mostrar enquanto se digita deixa o motorista conferir
/// contra a bomba antes de salvar.
class _PricePerUnitReadout extends StatelessWidget {
  final String unit;
  final double value;

  const _PricePerUnitReadout({required this.unit, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.calculate_outlined, size: 18, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Preço por $unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          Text(
            value.formattedCurrency,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                )
                .tabular,
          ),
        ],
      ),
    );
  }
}
