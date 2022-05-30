import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class RowConstrainedBox extends SingleChildRenderObjectWidget {
  final double maxWidth;

  const RowConstrainedBox({
    super.key,
    required this.maxWidth,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RowConstrainedRenderBox(
        maxWidth: maxWidth,
      );

  @override
  void updateRenderObject(
      BuildContext context, RowConstrainedRenderBox renderObject) {
    renderObject.maxWidth = maxWidth;
  }
}

class RowConstrainedRenderBox extends RenderShiftedBox {

  RowConstrainedRenderBox({
    required double maxWidth,
    RenderBox? child,
  })  : _maxWidth = maxWidth,
        super(child);

  double _maxWidth;
  double get maxWidth => _maxWidth;
  set maxWidth(double maxWidth) {
    if(_maxWidth != maxWidth) {
      _maxWidth = maxWidth;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final child = this.child;
    if(child != null) {
      child.layout(BoxConstraints(
        minWidth: 0,
        maxWidth: constraints.maxWidth < maxWidth ? constraints.maxWidth : maxWidth,
        minHeight: constraints.minHeight,
        maxHeight: constraints.maxHeight,
      ), parentUsesSize: true);

      final measureWidth = child.size.width;
      size = Size(constraints.maxWidth, child.size.height);
      if(child.parentData is BoxParentData) {
        final childParentData = child.parentData as BoxParentData;
        childParentData.offset = Offset((constraints.maxWidth - measureWidth) / 2, 0);
      }
    }
  }
}
