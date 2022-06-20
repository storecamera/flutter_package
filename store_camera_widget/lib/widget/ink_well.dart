import 'package:flutter/material.dart';

class InkWellWithShape extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;
  final ValueChanged<bool>? onHighlightChanged;
  final ValueChanged<bool>? onHover;
  final Color? backgroundColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final Color? splashColor;
  final Color? shadowColor;

  final ShapeBorder? shape;
  final double? elevation;
  final bool inkWellIsTop;

  const InkWellWithShape({
    Key? key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.shadowColor,
    this.shape,
    this.elevation,
    this.inkWellIsTop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      shape: shape,
      clipBehavior: shape != null ? Clip.antiAlias : Clip.none,
      elevation: elevation ?? 0,
      child: inkWellIsTop ? Stack(
        children: [
          child,
          Positioned.fill(
            child: _buildInkWell(null),
          )
        ],
      ) : _buildInkWell(child),
    );
  }

  Widget _buildInkWell(Widget? child) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onHighlightChanged: onHighlightChanged,
        onHover: onHover,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        child: child,
      ),
    );
  }
}
