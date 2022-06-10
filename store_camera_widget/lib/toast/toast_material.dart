import 'package:flutter/material.dart';

import 'toast.dart';

class MaterialToastWidget extends StatelessWidget {
  final Color? color;
  final Widget child;

  const MaterialToastWidget({super.key, this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return DefaultToastWidget(
      color: color ?? Theme.of(context).colorScheme.onSurface,
      child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 650),
          child: child),
    );
  }
}

void showToast(BuildContext context,
    {String? title,
    TextStyle? titleTextStyle,
    String? message,
    TextStyle? messageTextStyle,
    Color? textColor,
    Color? backgroundColor}) {
  Toast.instance.show(context,
      child: MaterialToastWidget(
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title,
                  style: titleTextStyle ??
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor ??
                              Theme.of(context).colorScheme.surface),
                ),
              if (title != null && message != null)
                const SizedBox(
                  height: 8,
                ),
              if (message != null)
                Text(
                  message,
                  style: messageTextStyle ??
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor ??
                              Theme.of(context).colorScheme.surface),
                ),
            ],
          )));
}
