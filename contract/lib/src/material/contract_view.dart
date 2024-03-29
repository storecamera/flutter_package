import 'package:contract/src/contract.dart';
import 'package:contract/src/fragment.dart';
import 'package:flutter/material.dart';

abstract class ContractThemeWidget<T extends ContractFragment> extends ContractWidget<T> {
  final ThemeData theme;

  ContractThemeWidget({
    super.key,
    required BuildContext context,
  }) : theme = Theme.of(context);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;
}
