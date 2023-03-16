import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

typedef ToastContainerDecorationBuilder = Decoration? Function(
    BuildContext context, Color color);

class ToastStyle extends ThemeExtension<ToastStyle> {
  static const Duration defaultDuration = Duration(seconds: 5);
  static const int defaultHideDelayMs = 30;
  static const bool defaultUseSafeArea = true;

  static const AlignmentGeometry defaultAlignment = Alignment.center;
  static const EdgeInsetsGeometry defaultPadding = EdgeInsets.all(16);

  static const ToastAnimationType defaultAnimationType =
      ToastAnimationType.opacity;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Curve defaultAnimationCurve = Curves.easeOutBack;

  const ToastStyle({
    this.duration,
    this.useSafeArea,
    this.alignment,
    this.padding,
    this.animationType,
    this.animationDuration,
    this.animationCurve,
    this.titleTextStyle,
    this.messageTextStyle,
    this.titleMessageSpace,
    this.containerColor,
    this.containerPadding,
    this.containerDecoration,
    this.containerUseBlur,
  });

  final Duration? duration;

  final bool? useSafeArea;

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;

  final ToastAnimationType? animationType;
  final Duration? animationDuration;
  final Curve? animationCurve;

  final TextStyle? titleTextStyle;
  final TextStyle? messageTextStyle;
  final double? titleMessageSpace;

  final Color? containerColor;
  final EdgeInsetsGeometry? containerPadding;
  final ToastContainerDecorationBuilder? containerDecoration;
  final bool? containerUseBlur;

  @override
  ThemeExtension<ToastStyle> copyWith({
    Duration? duration,
    bool? useSafeArea,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    ToastAnimationType? animationType,
    Duration? animationDuration,
    Curve? animationCurve,
    TextStyle? titleTextStyle,
    TextStyle? messageTextStyle,
    double? titleMessageSpace,
    Color? containerColor,
    EdgeInsetsGeometry? containerPadding,
    ToastContainerDecorationBuilder? containerDecoration,
    bool? containerUseBlur,
  }) =>
      ToastStyle(
        duration: duration ?? this.duration,
        useSafeArea: useSafeArea ?? this.useSafeArea,
        alignment: alignment ?? this.alignment,
        padding: padding ?? this.padding,
        animationType: animationType ?? this.animationType,
        animationDuration: animationDuration ?? this.animationDuration,
        animationCurve: animationCurve ?? this.animationCurve,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        titleMessageSpace: titleMessageSpace ?? this.titleMessageSpace,
        messageTextStyle: messageTextStyle ?? this.messageTextStyle,
        containerColor: containerColor ?? this.containerColor,
        containerPadding: containerPadding ?? this.containerPadding,
        containerDecoration: containerDecoration ?? this.containerDecoration,
        containerUseBlur: containerUseBlur ?? this.containerUseBlur,
      );

  @override
  ThemeExtension<ToastStyle> lerp(
      covariant ThemeExtension<ToastStyle>? other, double t) {
    return this;
  }
}

enum ToastAnimationType {
  opacity,
  ltr,

  /// left to right
  ttb,

  /// top to bottom
  rtl,

  /// right to left
  btt,

  /// bottom to top
}

class Toasts {
  static final Toasts instance = Toasts._();

  factory Toasts() => instance;

  Toasts._();

  Toast? _toast;

  Future<void> show(BuildContext context,
      {ToastStyle? style, required WidgetBuilder builder}) {
    _toast?.hide();
    _toast = Toast(
      style: style,
    );
    return _toast!.show(context, builder);
  }

  Future<void> showText({
    required BuildContext context,
    ToastStyle? style,
    Widget? titleWidget,
    String? titleText,
    TextStyle? titleTextStyle,
    Widget? messageWidget,
    TextStyle? messageTextStyle,
    String? messageText,
    double? titleMessageSpace,
  }) {
    return _toast!.show(context, (context) {
      final theme = Theme.of(context).extension<ToastStyle>();
      final titleStyle = titleTextStyle ??
          style?.titleTextStyle ??
          theme?.titleTextStyle ??
          Theme.of(context).textTheme.titleSmall ??
          const TextStyle();

      Widget? title;
      if (titleWidget != null) {
        title = DefaultTextStyle(style: titleStyle, child: titleWidget);
      } else if (titleText != null) {
        title = Text(
          titleText,
          style: titleStyle,
        );
      }

      Widget? message;
      if (messageWidget != null) {
        if (messageTextStyle != null) {
          message =
              DefaultTextStyle(style: messageTextStyle, child: messageWidget);
        } else {
          message = messageWidget;
        }
      } else if (messageText != null) {
        title = Text(
          messageText,
          style: messageTextStyle,
        );
      }

      double space = titleMessageSpace ??
          style?.titleMessageSpace ??
          theme?.titleMessageSpace ??
          8;
      return ToastContainer(
        style: style,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) title,
            if (title != null && message != null)
              SizedBox(
                height: space,
              ),
            if (message != null) message,
          ],
        ),
      );
    });
  }
}

class Toast {
  final ToastStyle? style;
  OverlayEntry? _overlayEntry;

  Toast({
    this.style,
  });

  Future<void> show(BuildContext context, WidgetBuilder builder) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }

    final c = Completer();
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      final theme = Theme.of(context).extension<ToastStyle>();

      final useSafeArea = style?.useSafeArea ??
          theme?.useSafeArea ??
          ToastStyle.defaultUseSafeArea;
      EdgeInsetsGeometry padding =
          style?.padding ?? theme?.padding ?? ToastStyle.defaultPadding;

      if (useSafeArea) {
        final data = MediaQuery.of(context);
        padding = padding.add(data.padding);
      }
      final textStyle = style?.messageTextStyle ??
          theme?.messageTextStyle ??
          Theme.of(context).textTheme.bodyMedium;

      final child = _ToastOverlayWidget(
        onFinish: hide,
        onDispose: () {
          c.complete(null);
        },
        duration:
            style?.duration ?? theme?.duration ?? ToastStyle.defaultDuration,
        animationType: style?.animationType ??
            theme?.animationType ??
            ToastStyle.defaultAnimationType,
        animationDuration: style?.animationDuration ??
            theme?.animationDuration ??
            ToastStyle.defaultAnimationDuration,
        animationCurve: style?.animationCurve ??
            theme?.animationCurve ??
            ToastStyle.defaultAnimationCurve,
        child: textStyle != null
            ? DefaultTextStyle(style: textStyle, child: builder(context))
            : builder(context),
      );

      return Align(
          alignment: style?.alignment ??
              theme?.alignment ??
              ToastStyle.defaultAlignment,
          child: Padding(padding: padding, child: child));
    });

    Overlay.of(context).insert(_overlayEntry!);
    return c.future;
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _ToastOverlayWidget extends StatefulWidget {
  final void Function() onFinish;
  final void Function() onDispose;

  final Duration duration;

  final ToastAnimationType animationType;
  final Duration animationDuration;
  final Curve animationCurve;

  final Widget child;

  const _ToastOverlayWidget({
    required this.onFinish,
    required this.onDispose,
    required this.duration,
    required this.animationType,
    required this.animationDuration,
    required this.animationCurve,
    required this.child,
  });

  @override
  _ToastOverlayState createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool finishStatus = false;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: widget.animationDuration, vsync: this);
    _animation =
        CurvedAnimation(parent: _controller, curve: widget.animationCurve)
          ..addListener(() {
            if (finishStatus && !_controller.isAnimating) {
              widget.onFinish();
            }
            setState(() {});
          });

    _controller.forward();

    Future.delayed(widget.duration).then((value) {
      if (mounted && !finishStatus) {
        finishStatus = true;
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.onDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.animationType) {
      case ToastAnimationType.opacity:
        final value = _animation.value < 0
            ? 0.0
            : _animation.value > 1.0
                ? 1.0
                : _animation.value;
        return Opacity(
          opacity: value,
          child: widget.child,
        );
      case ToastAnimationType.ltr:
        final value = _animation.value - 1;
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset(value, 0.0),
            child: widget.child,
          ),
        );
      case ToastAnimationType.ttb:
        final value = _animation.value - 1;
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset(0.0, value),
            child: widget.child,
          ),
        );
      case ToastAnimationType.rtl:
        final value = 1 - _animation.value;
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset(value, 0.0),
            child: widget.child,
          ),
        );
      case ToastAnimationType.btt:
        final value = 1 - _animation.value;
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset(0.0, value),
            child: widget.child,
          ),
        );
    }
  }
}

class ToastContainer extends StatelessWidget {
  final ToastStyle? style;
  final Widget child;

  const ToastContainer({
    super.key,
    this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<ToastStyle>();
    final color = style?.containerColor ??
        theme?.containerColor ??
        Theme.of(context).cardColor;

    final padding = style?.containerPadding ??
        theme?.containerPadding ??
        ToastStyle.defaultPadding;
    final Decoration? decoration;
    final ToastContainerDecorationBuilder? decorationBuilder =
        style?.containerDecoration ?? theme?.containerDecoration;
    if (decorationBuilder != null) {
      decoration = decorationBuilder(context, color);
    } else {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          width: 1.5,
          color: color.withOpacity(0.2),
        ),
      );
    }

    Widget child = Container(
      padding: padding,
      decoration: decoration,
      color: decoration == null ? color : null,
      child: this.child,
    );
    final useBlur = style?.containerUseBlur ?? theme?.containerUseBlur ?? true;
    if (useBlur) {
      child = BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), child: child);
    }

    return child;
  }
}
