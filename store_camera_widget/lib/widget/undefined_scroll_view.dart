import 'package:flutter/widgets.dart';

class UndefinedScrollView extends StatelessWidget {
  final Axis scrollDirection;
  final double? minWidth;
  final double? minHeight;
  final Clip clipBehavior;
  final Widget child;

  const UndefinedScrollView({
    Key? key,
    this.scrollDirection = Axis.vertical,
    this.minWidth,
    this.minHeight,
    this.clipBehavior = Clip.hardEdge,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch(scrollDirection) {
          case Axis.horizontal:
            final width = minWidth ?? 800;
            if (constraints.maxWidth < width) {
              return SingleChildScrollView(
                scrollDirection: scrollDirection,
                clipBehavior: clipBehavior,
                child: ConstrainedBox(
                  constraints: constraints.copyWith(maxWidth: width),
                  child: child,
                ),
              );
            }
            break;
          case Axis.vertical:
            final height = minHeight ?? 800;
            if (constraints.maxHeight < height) {
              return SingleChildScrollView(
                scrollDirection: scrollDirection,
                clipBehavior: clipBehavior,
                child: ConstrainedBox(
                  constraints: constraints.copyWith(maxHeight: height),
                  child: child,
                ),
              );
            }
            break;
        }

        return child;
      },
    );
  }
}
