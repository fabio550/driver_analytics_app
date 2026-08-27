import 'package:flutter/material.dart';

/// Estilos de texto que não mapeiam pra nenhum papel do Material TextTheme
/// (rótulos em caixa alta, badges pequenos) — centralizados aqui pra não
/// espalhar TextStyle mágico pelos widgets. Cor não entra aqui: cada
/// widget aplica a cor certa do ColorScheme por cima com copyWith.
///
/// Onde o widget já usa Theme.of(context).textTheme.xxx (a maioria das
/// telas), não mexe — isso já é o jeito certo. Isso aqui é só pros casos
/// que fugiam do tema com TextStyle cru.
class AppTextStyles {
  const AppTextStyles._();

  /// Rótulo de seção em caixa alta (ex.: "NOVO LANÇAMENTO" no sheet de
  /// tipo de ganho, "ATRIBUIR A UM TURNO" no sheet de órfãos).
  static const eyebrow = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
  );

  /// Texto pequeno e forte de badge (ex.: badge de completude do turno).
  static const badgeStrong = TextStyle(fontSize: 11, fontWeight: FontWeight.w700);

  /// Texto pequeno neutro (ex.: label de tab não selecionada, texto de
  /// chip, mensagem de erro inline).
  static const caption = TextStyle(fontSize: 12);

  /// Rótulo de tab selecionada.
  static const tabLabel = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

  /// Prefixo curto dentro de um BorderedFieldShell (ex.: "R$").
  static const fieldPrefix = TextStyle(fontSize: 14);

  /// Label do PrimaryButton.
  static const buttonLabel = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
}