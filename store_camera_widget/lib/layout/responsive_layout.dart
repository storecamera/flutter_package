import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ResponsiveDevice {
  MOBILE, // ignore: constant_identifier_names
  TABLET, // ignore: constant_identifier_names
  DESKTOP, // ignore: constant_identifier_names
}

class ResponsiveLayoutConfig {
  static final ResponsiveLayoutConfig instance = ResponsiveLayoutConfig._();

  ResponsiveLayoutConfig._();

  double _mobile = 650;
  double _tablet = 1100;

  void setMobileConstraint(double value) => _mobile = value;

  void setTableConstraint(double value) => _tablet = value;

  bool isMobile(double width) => width < _mobile;

  bool isMobileOf(BuildContext context) =>
      isMobile(MediaQuery.of(context).size.width);

  bool isTablet(double width) => width < _tablet && width >= _mobile;

  bool isTabletOf(BuildContext context) =>
      isTablet(MediaQuery.of(context).size.width);

  bool isDesktop(double width) => width >= _tablet;

  bool isDesktopOf(BuildContext context) =>
      isDesktop(MediaQuery.of(context).size.width);

  ResponsiveDevice deviceOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobile) {
      return ResponsiveDevice.MOBILE;
    } else if (width < _tablet) {
      return ResponsiveDevice.TABLET;
    } else {
      return ResponsiveDevice.DESKTOP;
    }
  }

  ResponsiveDevice device(double width) {
    if (width < _mobile) {
      return ResponsiveDevice.MOBILE;
    } else if (width < _tablet) {
      return ResponsiveDevice.TABLET;
    } else {
      return ResponsiveDevice.DESKTOP;
    }
  }
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
        return builder(
            context,
            ResponsiveLayoutConfig.instance.device(constraints.maxWidth),
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

        return builder(
            context,
            ResponsiveLayoutConfig.instance.device(constraints.maxWidth),
            constraints,
            width,
            horizontal);
      },
    );
  }
}
