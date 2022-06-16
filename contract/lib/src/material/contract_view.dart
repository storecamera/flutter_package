import 'package:contract/src/contract.dart';
import 'package:flutter/material.dart';

abstract class AppThemeView<T extends Contract> extends ContractView<T> {
  final ThemeData theme;

  AppThemeView(
    super.context, {
    super.key,
  }) : theme = Theme.of(context);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;
}
