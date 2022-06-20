import 'package:flutter/material.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

typedef AppDropdownChanged<T> = void Function(T value);

class ScDropdownButton<T> extends StatelessWidget {
  final T? value;
  final bool enabled;
  final Iterable<T> items;
  final String Function(T) valueToString;
  final AppDropdownChanged<T> onChanged;

  const ScDropdownButton({
    Key? key,
    this.value,
    this.enabled = true,
    required this.items,
    required this.valueToString,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButton<T>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem<T>(
        value: e,
        child: Padding(
          padding: contentPadding,
          child: Text(
            valueToString(e),
            style: e == value
                ? theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.primary)
                : theme.textTheme.bodyLarge,
          ),
        ),
      ))
          .toList(),
      onChanged: enabled
          ? (_) {
        if (_ != null && _ != value) {
          onChanged.call(_);
        }
      }
          : null,
    );
  }
}

class ScDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final double? maxWidth;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final Iterable<T> items;
  final String Function(T) valueToString;
  final AppDropdownChanged<T> onChanged;

  const ScDropdownFormField({
    Key? key,
    this.value,
    this.maxWidth,
    this.labelText,
    this.errorText,
    this.enabled = true,
    required this.items,
    required this.valueToString,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        constraints:
        maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
        labelText: labelText,
        errorText: errorText,
        contentPadding: contentPadding,
      ),
      isExpanded: true,
      selectedItemBuilder: (context) => items.map((e) {
        final text = valueToString(e);
        final child = Text(
          text,
          style: theme.textTheme.bodyLarge,
        );
        return text.isNotEmpty ? FittedBox(child: child) : child;
      }).toList(),
      items: items.map((e) {
        final text = valueToString(e);
        final child = Text(
          text,
          style: e == value
              ? theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.primary)
              : theme.textTheme.bodyLarge,
        );
        return DropdownMenuItem<T>(
          value: e,
          child: text.isNotEmpty ? FittedBox(child: child) : child,
        );
      }).toList(),
      onChanged: enabled
          ? (_) {
        if (_ != null && _ != value) {
          onChanged.call(_);
        }
      }
          : null,
    );
  }
}