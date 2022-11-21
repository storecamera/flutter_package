import 'dart:math' as math;

import 'package:flutter/material.dart';

class DecoratorTextFormWidget extends StatelessWidget {
  final String? text;
  final InputDecoration? decoration;

  final TextStyle? style;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;

  final bool isFocused;
  final bool isHovering;
  final bool isFitted;

  const DecoratorTextFormWidget({
    super.key,
    this.text,
    this.decoration,
    this.style,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.isFocused = false,
    this.isHovering = false,
    this.isFitted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = this.text ?? '';

    final InputDecoration effectiveDecoration =
        (decoration ?? const InputDecoration()).applyDefaults(
      theme.inputDecorationTheme,
    );

    return InputDecorator(
        decoration: effectiveDecoration,
        isEmpty: text.isEmpty,
        isFocused: isFocused,
        isHovering: isHovering,
        child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: _height(theme)),
            child: _buildText(theme, text)));
  }

  Widget _buildText(ThemeData theme, String text) {
    if (text.isEmpty) {
      return const SizedBox();
    }
    final child = Text(
      text,
      style: style ?? theme.textTheme.titleMedium,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
    );

    if (isFitted) {
      return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.bottomStart,
          child: child);
    }

    return child;
  }

  static double _height(ThemeData theme) {
    final fontSize = theme.textTheme.titleMedium?.fontSize ?? 0;
    const defaultHeight = 22.0;

    return math.max(fontSize, defaultHeight);
  }
}
