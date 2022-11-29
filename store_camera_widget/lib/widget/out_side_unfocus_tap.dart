import 'package:flutter/material.dart';

class OutSideUnFocusTab extends StatelessWidget {

  final Widget child;

  const OutSideUnFocusTab({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus && focusScopeNode.hasFocus) {
          focusScopeNode.unfocus();
        }
      },
      child: child,
    );
  }
}

typedef OutSideUnFocusWidgetBuilder = Widget Function(
    BuildContext context, BoxConstraints constraints, bool showKeyboard);

class OutSideUnFocusBuilder extends StatelessWidget {
  final OutSideUnFocusWidgetBuilder builder;

  const OutSideUnFocusBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus && focusScopeNode.hasFocus) {
          focusScopeNode.unfocus();
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return builder(context, constraints,
              MediaQuery.of(context).viewInsets.bottom > 0);
        },
      ),
    );
  }
}