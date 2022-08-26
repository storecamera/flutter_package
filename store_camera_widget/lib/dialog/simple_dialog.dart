import 'dart:async';

import 'package:flutter/material.dart';
import 'package:store_camera_widget/dialog/dialog.dart';

typedef DialogActionsBuilder = List<Widget>? Function(BuildContext context);

Future<dynamic> showTextDialog(
  BuildContext context, {
  String? title,
  String? text,
  MainAxisAlignment? actionsAlignment,
  DialogActionsBuilder? actionsBuilder,
}) =>
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: SimpleDialogTitle(
                child: Text(title ?? ''),
              ),
              content:
                  SimpleDialogContent(child: text != null ? Text(text) : null),
              actionsAlignment:
                  actionsAlignment ?? MainAxisAlignment.spaceBetween,
              actions: actionsBuilder?.call(context),
            ));

Future<dynamic> showSimpleDialog(
  BuildContext context, {
  String? title,
  Widget? content,
  MainAxisAlignment? actionsAlignment,
  DialogActionsBuilder? actionsBuilder,
}) =>
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: SimpleDialogTitle(
                child: Text(title ?? ''),
              ),
              content: SimpleDialogContent(child: content),
              actionsAlignment:
                  actionsAlignment ?? MainAxisAlignment.spaceBetween,
              actions: actionsBuilder?.call(context),
            ));

class SimpleDialogTitle extends StatelessWidget {
  final Widget? child;

  const SimpleDialogTitle({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: child ?? const SizedBox()),
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close)),
      ],
    );
  }
}

class SimpleDialogContent extends StatelessWidget {
  final Widget? child;

  const SimpleDialogContent({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 650,
      child: child,
    );
  }
}

Future<dynamic> showSelectListDialog<T>(
  BuildContext context, {
  String? title,
  T? item,
  required List<T> items,
  Widget Function(BuildContext context, int index, bool selected, T item,
          GestureTapCallback onTap)?
      itemBuilder,
  MainAxisAlignment? actionsAlignment,
  DialogActionsBuilder? actionsBuilder,
}) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: SimpleDialogTitle(
              child: Text(title ?? ''),
            ),
            content: SimpleDialogContent(
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
            actionsAlignment:
                actionsAlignment ?? MainAxisAlignment.spaceBetween,
            actions: actionsBuilder?.call(context),
          ));
}
