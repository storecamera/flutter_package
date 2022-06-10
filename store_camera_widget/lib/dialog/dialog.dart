import 'dart:async';

import 'package:flutter/material.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

class DialogTheme {}

Future<dynamic> scShowAlertDialog(
  BuildContext context, {
  String? title,
  String? text,
  Widget? content,
  List<ScDialogActionBuilder>? actions,
}) async {
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

  return null;
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
        : Container(height: 0,);
  }
}

class ScDialogActionBuilder {
  final WidgetBuilder builder;

  ScDialogActionBuilder({required this.builder});
}

class ScDialogTextAction extends ScDialogActionBuilder {
  final String text;
  final TextStyle? textStyle;
  final FutureOr Function()? onTap;

  ScDialogTextAction({required this.text, this.textStyle, this.onTap})
      : super(
            builder: (context) => TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsetsDynamic(all: 16),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(await onTap?.call());
                  },
                  child:
                      Text(text, style: textStyle ?? defaultTextStyle(context)),
                ));

  static TextStyle defaultTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge ?? const TextStyle();

  factory ScDialogTextAction.ok(BuildContext context, {String text = 'Ok'}) =>
      ScDialogTextAction(
        text: text,
        textStyle: defaultTextStyle(context)
            .copyWith(color: Theme.of(context).colorScheme.primary),
        onTap: () => true,
      );

  factory ScDialogTextAction.cancel(BuildContext context,
          {String text = 'Cancel'}) =>
      ScDialogTextAction(
          text: text,
          textStyle: defaultTextStyle(context)
              .copyWith(color: Theme.of(context).hintColor),
          onTap: () => false);
}
