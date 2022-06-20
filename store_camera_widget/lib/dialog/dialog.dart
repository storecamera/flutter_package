import 'dart:async';

import 'package:flutter/material.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

class ScDialogTheme {
  static final ScDialogTheme instance = ScDialogTheme._();

  factory ScDialogTheme() => instance;

  ScDialogTheme._();

  WidgetBuilder loadingBuilder = (context) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}

Future<dynamic> scAlertDialog(
  BuildContext context, {
  String? title,
  String? text,
  Widget? content,
  List<ScDialogActionBuilder>? actions,
}) =>
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: title != null ? Text(title) : null,
              content: content ??
                  ScDialogTextContentWidget(
                    text: text,
                  ),
              actions: actions?.map((e) => e.builder(context)).toList(),
            ));

const singleTextEditDialogDecoration = InputDecoration(
  contentPadding: EdgeInsetsDynamic(horizontal: 8, vertical: 4),
  constraints: BoxConstraints(minWidth: 650, maxWidth: 650),
);

Future<dynamic> scSingleTextEditDialog(
  BuildContext context, {
  String? title,
  String? initText,
  InputDecoration? decoration,
}) async {
  String text = initText ?? '';
  return await showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: title != null ? Text(title) : null,
                content: TextFormField(
                  initialValue: initText,
                  decoration: (decoration ?? singleTextEditDialogDecoration),
                  textAlignVertical: TextAlignVertical.center,
                  autofocus: true,
                  onChanged: (_) {
                    if (text.isNotEmpty != _.isNotEmpty) {
                      setState(() {
                        text = _;
                      });
                    } else {
                      text = _;
                    }
                  },
                ),
                actions: [
                  ScDialogTextAction.ok(context,
                      enabled: text.isNotEmpty,
                      onTap: () => text).builder(context),
                  ScDialogTextAction.cancel(context).builder(context),
                ],
              );
            },
          ));
}

Widget listSelectDialogBuilder<T>(BuildContext context, int index,
    bool selected, T item, GestureTapCallback onTap) {
  return ListTile(
    leading: selected ? const Icon(Icons.check) : Text('${index + 1}'),
    title: Text(item.toString()),
    selected: selected,
    onTap: onTap,
  );
}

Future<T?> scListSelectDialog<T>(
  BuildContext context, {
  String? title,
  T? item,
  required List<T> items,
  Widget Function(BuildContext context, int index, bool selected, T item,
          GestureTapCallback onTap)?
      itemBuilder,
}) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: title != null ? Text(title) : null,
            content: SizedBox(
              width: 650,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return (itemBuilder ?? listSelectDialogBuilder<T>).call(
                      context, index, items[index] == item, items[index], () {
                    Navigator.of(context).pop(items[index]);
                  });
                },
                itemCount: items.length,
              ),
            ),
            actions: [
              ScDialogTextAction.cancel(context, onTap: () => null).builder(
                context,
              ),
            ],
          ));
}

class ScDialogTextContentWidget extends StatelessWidget {
  final String? text;

  const ScDialogTextContentWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final text = this.text;
    return text != null
        ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650), child: Text(text))
        : Container(
            height: 0,
          );
  }
}

class ScDialogActionBuilder {
  final WidgetBuilder builder;

  ScDialogActionBuilder({required this.builder});
}

class ScDialogTextAction extends ScDialogActionBuilder {
  final String text;
  final TextStyle? textStyle;
  final bool enabled;
  final FutureOr Function()? onTap;

  ScDialogTextAction(
      {required this.text, this.textStyle, this.enabled = true, this.onTap})
      : super(
            builder: (context) => TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsetsDynamic(all: 16),
                  ),
                  onPressed: enabled
                      ? () async {
                          Navigator.of(context).pop(await onTap?.call());
                        }
                      : null,
                  child:
                      Text(text, style: textStyle ?? defaultTextStyle(context)),
                ));

  static TextStyle defaultTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge ?? const TextStyle();

  factory ScDialogTextAction.ok(BuildContext context,
          {String text = 'Ok',
          bool enabled = true,
          FutureOr Function()? onTap}) =>
      ScDialogTextAction(
        text: text,
        textStyle: defaultTextStyle(context).copyWith(
            color: enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor),
        enabled: enabled,
        onTap: onTap ?? () => true,
      );

  factory ScDialogTextAction.cancel(BuildContext context,
          {String text = 'Cancel', FutureOr Function()? onTap}) =>
      ScDialogTextAction(
          text: text,
          textStyle: defaultTextStyle(context)
              .copyWith(color: Theme.of(context).hintColor),
          onTap: onTap ?? () => false);
}

class ScListSelectItem<T> {
  final T item;
  final String text;

  ScListSelectItem(this.item, {required this.text});

  @override
  String toString() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScListSelectItem &&
          runtimeType == other.runtimeType &&
          item == other.item;

  @override
  int get hashCode => item.hashCode;
}
