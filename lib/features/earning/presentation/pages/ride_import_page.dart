import 'package:driver_analytics_app/core/domain/enums/load_status.dart';
import 'package:driver_analytics_app/core/presentation/theme/app_spacing.dart';
import 'package:driver_analytics_app/core/presentation/widgets/error_state_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/primary_button.dart';
import 'package:driver_analytics_app/core/presentation/widgets/screen_scroll_view.dart';
import 'package:driver_analytics_app/core/presentation/widgets/skeleton_box.dart';
import 'package:driver_analytics_app/features/earning/application/providers/ride_import_provider.dart';
import 'package:driver_analytics_app/features/earning/application/state/ride_import_notifier.dart';
import 'package:driver_analytics_app/features/earning/application/state/ride_import_state.dart';
import 'package:driver_analytics_app/features/earning/presentation/widgets/ride_import_candidate_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Seleciona um print da tela de corridas do Uber, roda OCR on-device
/// (ML Kit) sobre ele, mostra uma prévia resolvida (parser + geo + dedup)
/// e só grava depois que o usuário confirma. Colar o texto manualmente
/// fica como alternativa, útil se o OCR não reconhecer bem a imagem.
class RideImportPage extends ConsumerStatefulWidget {
  /// Quando aberta a partir do diálogo de finalizar jornada, as corridas
  /// confirmadas aqui já nascem associadas a esse turno.
  final String? shiftId;

  const RideImportPage({super.key, this.shiftId});

  @override
  ConsumerState<RideImportPage> createState() => _RideImportPageState();
}

class _RideImportPageState extends ConsumerState<RideImportPage> {
  final _textController = TextEditingController();
  bool _showPasteFallback = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    await ref.read(rideImportNotifierProvider.notifier).previewFromImagePath(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideImportNotifierProvider);
    final notifier = ref.read(rideImportNotifierProvider.notifier);

    // "loaded" é o parser/OCR já ter rodado — mesmo achando zero
    // corridas, isso é resultado, não o estado inicial. Usar só
    // candidates.isNotEmpty fazia zero corridas parecer "nada aconteceu"
    // e voltar pra tela de seleção em silêncio.
    final showResult = state.status == LoadStatus.loaded;
    final importableCount = state.selectedIndexes
        .where((i) => state.candidates[i].isImportable)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Importar corridas')),
      bottomNavigationBar: _bottomBar(state, notifier, showResult, importableCount),
      body: showResult ? _preview(state, notifier) : _initial(state, notifier),
    );
  }

  Widget? _bottomBar(
    RideImportState state,
    RideImportNotifier notifier,
    bool showResult,
    int importableCount,
  ) {
    if (showResult && state.candidates.isNotEmpty) {
      return PrimaryButton(
        label: importableCount > 0
            ? 'Confirmar importação ($importableCount)'
            : 'Nenhuma corrida selecionada',
        isLoading: state.isSaving,
        onPressed: importableCount == 0 || state.isSaving
            ? null
            : () async {
                await notifier.confirmImport(shiftId: widget.shiftId);
                if (!mounted) return;
                _textController.clear();
                setState(() => _showPasteFallback = false);
                _showResultSnackBar(context);
              },
      );
    }

    if (!showResult && _showPasteFallback) {
      return PrimaryButton(
        label: 'Analisar texto',
        isLoading: state.status == LoadStatus.loading,
        onPressed: state.status == LoadStatus.loading ||
                _textController.text.trim().isEmpty
            ? null
            : () => notifier.preview(_textController.text),
      );
    }

    return null;
  }

  void _showResultSnackBar(BuildContext context) {
    final state = ref.read(rideImportNotifierProvider);
    final imported = state.lastImportedCount ?? 0;
    final skipped = state.lastSkippedCount ?? 0;

    final message = skipped > 0
        ? '$imported ${imported == 1 ? 'corrida importada' : 'corridas importadas'}, '
            '$skipped ${skipped == 1 ? 'ignorada' : 'ignoradas'}'
        : '$imported ${imported == 1 ? 'corrida importada' : 'corridas importadas'}';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _initial(RideImportState state, RideImportNotifier notifier) {
    if (state.status == LoadStatus.error) {
      return ScreenScrollView(
        children: [
          ErrorStateView(
            message: 'Não consegui processar isso. Confira se é mesmo um '
                'print da tela de corridas do Uber e tenta de novo.',
            onRetry: notifier.reset,
          ),
          if (state.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Detalhes técnicos'),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    state.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    if (state.status == LoadStatus.loading) {
      return const _LoadingSkeleton();
    }

    return ScreenScrollView(
      children: [
        Text(
          'Selecione o print da tela de corridas do Uber. O texto é lido '
          'direto no aparelho (nada é enviado pra fora) e cada corrida '
          'encontrada aparece pra você conferir antes de salvar.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image_outlined),
          label: const Text('Selecionar print'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _showPasteFallback = !_showPasteFallback),
            child: Text(
              _showPasteFallback
                  ? 'Não quero colar o texto'
                  : 'Prefiro colar o texto manualmente',
            ),
          ),
        ),
        if (_showPasteFallback) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _textController,
            maxLines: 14,
            minLines: 8,
            decoration: const InputDecoration(
              labelText: 'Texto do print',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ],
    );
  }

  Widget _preview(RideImportState state, RideImportNotifier notifier) {
    return ScreenScrollView(
      children: [
        Text(
          '${state.candidates.length} '
          '${state.candidates.length == 1 ? 'corrida encontrada' : 'corridas encontradas'}',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: () {
            notifier.reset();
            setState(() => _showPasteFallback = false);
          },
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Selecionar outro print'),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (state.candidates.isEmpty)
          _EmptyResult(rawText: state.rawText)
        else
          for (var i = 0; i < state.candidates.length; i++) ...[
            RideImportCandidateTile(
              candidate: state.candidates[i],
              selected: state.selectedIndexes.contains(i),
              onChanged: state.candidates[i].isImportable
                  ? (_) => notifier.toggleSelected(i)
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

/// Nenhuma corrida reconhecida — pode ser um print de outro layout, ou
/// OCR que leu mal a imagem. Mostra o texto que foi lido (se teve algum)
/// pra dar pra diagnosticar em vez de só dizer "não achei nada".
class _EmptyResult extends StatelessWidget {
  final String? rawText;

  const _EmptyResult({required this.rawText});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Não reconheci nenhuma corrida nesse texto. Pode ser um layout '
          'de print diferente do esperado, ou o OCR não leu bem a imagem.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        if (rawText != null && rawText!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Ver texto reconhecido'),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(rawText!, style: textTheme.bodySmall),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: rawText!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Texto copiado')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ScreenScrollView(
      children: [
        for (var i = 0; i < 3; i++) ...[
          const SkeletonCard(
            children: [
              SkeletonBox(width: 120, height: 15),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 14),
              SizedBox(height: AppSpacing.xs),
              SkeletonBox(width: 180, height: 12),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
