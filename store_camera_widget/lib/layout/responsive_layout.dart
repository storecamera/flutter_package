import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ResponsiveDevice {
  MOBILE, // ignore: constant_identifier_names
  TABLET, // ignore: constant_identifier_names
  DESKTOP, // ignore: constant_identifier_names
}

class ResponsiveTheme {
  static final ResponsiveTheme instance = ResponsiveTheme._();

  ResponsiveTheme._();

  double _mobile = 650;
  double _tablet = 1100;

  void setMobileConstraint(double value) => _mobile = value;

  void setTableConstraint(double value) => _tablet = value;
}

class ResponsiveHelper {

  static double get mobileWidth => ResponsiveTheme.instance._mobile;

  static double get tabletWidth => ResponsiveTheme.instance._tablet;

  static bool isMobile(double width) => width < mobileWidth;

  static bool isMobileOf(BuildContext context) =>
      isMobile(MediaQuery.of(context).size.width);

  static bool isTablet(double width) => width < tabletWidth && width >= mobileWidth;

  static bool isTabletOf(BuildContext context) =>
      isTablet(MediaQuery.of(context).size.width);

  static bool isDesktop(double width) => width >= tabletWidth;

  static bool isDesktopOf(BuildContext context) =>
      isDesktop(MediaQuery.of(context).size.width);

  static ResponsiveDevice deviceOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileWidth) {
      return ResponsiveDevice.MOBILE;
    } else if (width < tabletWidth) {
      return ResponsiveDevice.TABLET;
    } else {
      return ResponsiveDevice.DESKTOP;
    }
  }

  static ResponsiveDevice device(double width) {
    if (width < mobileWidth) {
      return ResponsiveDevice.MOBILE;
    } else if (width < tabletWidth) {
      return ResponsiveDevice.TABLET;
    } else {
      return ResponsiveDevice.DESKTOP;
    }
  }

  static double symmetricPadding(double max, double size) {
    if (max < size) {
      return (size - max) / 2;
    }
    return 0;
  }

  static double drawerWidth(BuildContext context) =>
      DrawerTheme.of(context).width ?? 304;
}

typedef ResponsiveLayoutWidgetBuilder = Widget Function(
    BuildContext context, ResponsiveDevice device, BoxConstraints constraints);

class ResponsiveLayoutBuilder extends StatelessWidget {
  final ResponsiveLayoutWidgetBuilder builder;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, ResponsiveHelper.device(constraints.maxWidth),
            constraints);
      },
    );
  }
}

typedef MaxWidthLayoutBuilder = Widget Function(
    BuildContext context,
    ResponsiveDevice device,
    BoxConstraints constraints,
    double width,
    double horizontal);

class MaxWidthLayout extends StatelessWidget {
  final double maxWidth;
  final MaxWidthLayoutBuilder builder;

  const MaxWidthLayout({
    super.key,
    this.maxWidth = 650,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width;
        final double horizontal;

        if (maxWidth < constraints.maxWidth) {
          width = maxWidth;
          horizontal = (constraints.maxWidth - maxWidth) / 2;
        } else {
          width = constraints.maxWidth;
          horizontal = 0;
        }

        return builder(context, ResponsiveHelper.device(constraints.maxWidth),
            constraints, width, horizontal);
      },
    );
  }
}
