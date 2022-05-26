import 'package:flutter/material.dart';

class RoundedRectangleInkWell extends StatelessWidget {
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
  final BorderRadius? borderRadius;
  final BorderSide? side;
  final bool inkWellIsTop;

  const RoundedRectangleInkWell({
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
    this.borderRadius,
    this.side,
    this.inkWellIsTop = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return inkWellIsTop
        ? Stack(
            children: [
              _buildChild(child),
              Positioned.fill(
                child: _buildInkWell(null),
              )
            ],
          )
        : _buildInkWell(child);
  }

  Widget _buildChild(Widget child) {
    final borderRadius = this.borderRadius;
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        child: child,
      );
    }
    return child;
  }

  Widget _buildInkWell(Widget? child) {
    return Material(
      color: Colors.transparent,
      shape: side != null
          ? RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.zero, side: side!)
          : null,
      child: InkWell(
        borderRadius: borderRadius,
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
        child: child != null ? _buildChild(child) : null,
      ),
    );
  }
}
