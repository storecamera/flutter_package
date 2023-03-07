import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:store_camera_widget/painting/edge_insets.dart';

typedef InitToastTheme = ToastTheme Function(BuildContext context);

class ToastTheme {
  final Duration duration;

  final bool useSafeArea;

  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  final ToastAnimationType animationType;
  final Duration animationDuration;
  final Curve animationCurve;

  final TextStyle textStyle;

  const ToastTheme({
    this.duration = const Duration(seconds: 3),
    this.useSafeArea = true,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(16),
    this.animationType = ToastAnimationType.opacity,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutBack,
    this.textStyle = const TextStyle(),
  });

  ToastTheme copyWith({
    Duration? duration,
    bool? useSafeArea,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    ToastAnimationType? animationType,
    Duration? animationDuration,
    Curve? animationCurve,
    TextStyle? textStyle,
  }) {
    return ToastTheme(
      duration: duration ?? this.duration,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      alignment: alignment ?? this.alignment,
      padding: padding ?? this.padding,
      animationType: animationType ?? this.animationType,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      textStyle: textStyle ?? this.textStyle,
    );
  }
}

enum ToastAnimationType {
  opacity,
  ltr, /// left to right
  ttb, /// top to bottom
  rtl, /// right to left
  btt, /// bottom to top
}

class Toast {
  static final Toast instance = Toast._();

  factory Toast() => instance;

  Toast._();

  ToastTheme? _theme;
  InitToastTheme? _initToastTheme;

  void updateToastTheme(InitToastTheme initToastTheme) {
    _initToastTheme = initToastTheme;
    _theme = null;
  }

  _Toast? _toast;

  void show(BuildContext context, {
    Duration? duration,
    bool? useSafeArea,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    ToastAnimationType? animationType,
    Duration? animationDuration,
    Curve? animationCurve,
    void Function()? onDispose,
    required Widget child}) {
    _theme ??= _initToastTheme?.call(context) ?? const ToastTheme();

    _toast?.hide();
    _toast = _Toast(
        duration: duration,
        useSafeArea: useSafeArea,
        alignment: alignment,
        padding: padding,
        animationType: animationType,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        onDispose: onDispose,
        child: child
    )..show(context, _theme!);
  }
}

class _Toast {
  final Duration? duration;

  final bool? useSafeArea;

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;

  final ToastAnimationType? animationType;
  final Duration? animationDuration;
  final Curve? animationCurve;

  final void Function()? onDispose;

  final Widget child;

  OverlayEntry? _overlayEntry;

  _Toast({
    this.duration,
    this.useSafeArea,
    this.alignment,
    this.padding,
    this.animationType,
    this.animationDuration,
    this.animationCurve,
    this.onDispose,
    required this.child,
  });

  void show(BuildContext context, ToastTheme theme) {
    if(_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: (BuildContext context) {
        var useSafeArea = this.useSafeArea ?? theme.useSafeArea;
        var padding = this.padding ?? theme.padding;

        if(useSafeArea) {
          final data = MediaQuery.of(context);
          padding = padding.add(data.padding);
        }

        final child = _ToastOverlayWidget(
          onFinish: hide,
          onDispose: () {
            if(onDispose != null) {
              onDispose!();
            }
          },
          duration: duration ?? theme.duration,
          animationType: animationType ?? theme.animationType,
          animationDuration: animationDuration ?? theme.animationDuration,
          animationCurve: animationCurve ?? theme.animationCurve,
          child: DefaultTextStyle(
            style: theme.textStyle,
              child: this.child),
        );

        return Align(
            alignment: alignment ?? theme.alignment,
            child: Padding(
                padding: padding,
                child: child
            )
        );
      });

      Overlay.of(context).insert(_overlayEntry!);
    }
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
    Key? key,
    required this.onFinish,
    required this.onDispose,
    required this.duration,
    required this.animationType,
    required this.animationDuration,
    required this.animationCurve,
    required this.child,
  }) : super(key: key);

  @override
  _ToastOverlayState createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlayWidget> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  bool finishStatus = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.animationDuration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.animationCurve)
          ..addListener(() {
            if (finishStatus && !_controller.isAnimating) {
              widget.onFinish();
            }
            setState(() {});
          });

    _controller.forward();

    Future.delayed(widget.duration).then((value) {
      if(mounted && !finishStatus) {
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
    switch(widget.animationType) {
      case ToastAnimationType.opacity:
        final value = _animation.value < 0 ? 0.0 : _animation.value > 1.0 ? 1.0 : _animation.value;
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

class DefaultToastWidget extends StatelessWidget {
  final Color color;
  final double startOpacity;
  final double endOpacity;
  final double borderOpacity;
  final double radius;
  final EdgeInsetsGeometry padding;

  final Widget child;

  const DefaultToastWidget({
    super.key,
    this.color = const Color(0xFFFFFFFF),
    this.startOpacity = 0.9,
    this.endOpacity = 0.6,
    this.borderOpacity = 0.2,
    this.radius = 4,
    this.padding = const EdgeInsetsDynamic(all: 16),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(startOpacity),
              color.withOpacity(endOpacity)
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          border: Border.all(
            width: 1.5,
            color: color.withOpacity(borderOpacity),
          ),
        ),
        child: child,
      ),
    );
  }
}



