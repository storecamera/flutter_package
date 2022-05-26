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