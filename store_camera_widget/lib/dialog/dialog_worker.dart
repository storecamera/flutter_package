import 'dart:async';

import 'package:flutter/material.dart';

import 'dialog.dart';

Future<dynamic> scDialogWorker({
  required BuildContext context,
  required Future worker,
  WidgetBuilder? loadingBuilder,
}) =>
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) => _DialogWorker(
              worker: worker,
              loadingBuilder: loadingBuilder,
            ));

class _DialogWorker extends StatefulWidget {
  final Future worker;
  final WidgetBuilder? loadingBuilder;

  const _DialogWorker({required this.worker, this.loadingBuilder});

  @override
  State<_DialogWorker> createState() => _DialogWorkerState();
}

class _DialogWorkerState extends State<_DialogWorker> {

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      final result = await widget.worker;
      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context, _);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.loadingBuilder ?? ScDialogTheme.instance.loadingBuilder).call(context);
  }
}
