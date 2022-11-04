import 'package:flutter/material.dart';

enum TextStyles {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall;

  TextStyle? _style(
    ThemeData theme, {
    bool isPrimary = false,
  }) {
    final TextTheme textTheme =
        isPrimary ? theme.primaryTextTheme : theme.textTheme;

    switch (this) {
      case TextStyles.displayLarge:
        return textTheme.displayLarge;
      case TextStyles.displayMedium:
        return textTheme.displayMedium;
      case TextStyles.displaySmall:
        return textTheme.displaySmall;
      case TextStyles.headlineLarge:
        return textTheme.headlineLarge;
      case TextStyles.headlineMedium:
        return textTheme.headlineMedium;
      case TextStyles.headlineSmall:
        return textTheme.headlineSmall;
      case TextStyles.titleLarge:
        return textTheme.titleLarge;
      case TextStyles.titleMedium:
        return textTheme.titleMedium;
      case TextStyles.titleSmall:
        return textTheme.titleSmall;
      case TextStyles.bodyLarge:
        return textTheme.bodyLarge;
      case TextStyles.bodyMedium:
        return textTheme.bodyMedium;
      case TextStyles.bodySmall:
        return textTheme.bodySmall;
      case TextStyles.labelLarge:
        return textTheme.labelLarge;
      case TextStyles.labelMedium:
        return textTheme.labelMedium;
      case TextStyles.labelSmall:
        return textTheme.labelSmall;
    }
  }

  TextStyle? style(
    ThemeData theme, {
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    TextOverflow? overflow,
    bool isPrimary = false,
  }) {
    final textStyle = _style(theme, isPrimary: isPrimary);
    if (_isCopyWith(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      overflow: overflow,
    )) {
      return textStyle?.copyWith(
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        fontFamily: fontFamily,
        overflow: overflow,
      );
    }

    return textStyle;
  }

  bool _isCopyWith({
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    TextOverflow? overflow,
  }) {
    return color != null ||
        backgroundColor != null ||
        fontSize != null ||
        fontWeight != null ||
        fontStyle != null ||
        letterSpacing != null ||
        wordSpacing != null ||
        textBaseline != null ||
        height != null ||
        decoration != null ||
        decorationColor != null ||
        decorationStyle != null ||
        decorationThickness != null ||
        fontFamily != null ||
        overflow != null;
  }
}