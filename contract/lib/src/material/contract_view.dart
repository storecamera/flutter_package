import 'package:contract/src/contract.dart';
import 'package:flutter/material.dart';

abstract class ContractThemeView<T extends Contract> extends ContractView<T> {
  final ThemeData theme;

  ContractThemeView(
    super.context, {
    super.key,
  }) : theme = Theme.of(context);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;
}
