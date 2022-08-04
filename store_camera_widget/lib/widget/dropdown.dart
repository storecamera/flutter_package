import 'package:flutter/material.dart';
import 'package:store_camera_widget/dialog/dialog.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

class ScDropdownButton<T> extends StatelessWidget {
  final T? value;
  final bool enabled;
  final Iterable<T> items;
  final String Function(T) valueToString;
  final EdgeInsetsGeometry padding;
  final ValueChanged<T> onChanged;

  const ScDropdownButton({
    Key? key,
    this.value,
    this.enabled = true,
    this.padding = contentPadding,
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
          padding: padding,
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
        if (_ != null) {
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
  final EdgeInsetsGeometry padding;
  final Iterable<T> items;
  final String Function(T) valueToString;
  final ValueChanged<T> onChanged;

  const ScDropdownFormField({
    Key? key,
    this.value,
    this.maxWidth,
    this.labelText,
    this.errorText,
    this.padding = contentPadding,
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
        contentPadding: padding,
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
        if (_ != null) {
          onChanged.call(_);
        }
      }
          : null,
    );
  }
}

class ScDropdownFormFieldOtherString extends StatelessWidget {
  final String? value;
  final double? maxWidth;
  final String? labelText;
  final String? errorText;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final List<String> items;
  final String otherItem;

  final Future<dynamic> Function(BuildContext context, String value)?
  onOtherValue;
  final void Function(String value) onChanged;

  const ScDropdownFormFieldOtherString({
    super.key,
    this.value,
    this.maxWidth,
    this.labelText,
    this.errorText,
    this.enabled = true,
    this.padding = contentPadding,
    required this.items,
    required this.otherItem,
    this.onOtherValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = this.value != null && this.items.contains(this.value)
        ? this.value
        : otherItem;
    final items = [...this.items, otherItem];

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        constraints:
        maxWidth != null ? BoxConstraints(maxWidth: maxWidth!) : null,
        labelText: labelText,
        errorText: errorText,
        contentPadding: padding,
      ),
      isExpanded: true,
      selectedItemBuilder: (context) => items.map((e) {
        final text = e == otherItem ? this.value ?? '' : e;
        final child = Text(
          text,
          style: theme.textTheme.bodyLarge,
        );
        return text.isNotEmpty ? FittedBox(child: child) : child;
      }).toList(),
      items: items.map((e) {
        final child = Text(
          e,
          style: e == value
              ? theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.primary)
              : theme.textTheme.bodyLarge,
        );
        return DropdownMenuItem<String>(
          value: e,
          child: e.isNotEmpty ? FittedBox(child: child) : child,
        );
      }).toList(),
      onChanged: enabled
          ? (_) async {
        if (_ == null) {
          return;
        }
        String changedValue = _;
        if (changedValue == otherItem) {
          if (onOtherValue != null) {
            final result =
            await onOtherValue!.call(context, this.value ?? '');
            if (result is String) {
              changedValue = result;
            }
          } else {
            final result = await scSingleTextEditDialog(context,
                title: labelText, initText: this.value);
            if (result is String) {
              changedValue = result;
            }
          }
        }

        if (changedValue.isNotEmpty) {
          onChanged(changedValue);
        }
      }
          : null,
    );
  }
}