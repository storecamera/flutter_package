import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract class Links {
  String get linkName;
  String get linkPath;
}

extension LinksExtension on Links {
  void pushNamed(
    BuildContext context, {
    Map<String, String> params = const <String, String>{},
    Map<String, String> queryParams = const <String, String>{},
    Object? extra,
  }) {
    context.pushNamed(linkName,
        params: params, queryParams: queryParams, extra: extra);
  }

  void goNamed(
      BuildContext context, {
        Map<String, String> params = const <String, String>{},
        Map<String, String> queryParams = const <String, String>{},
        Object? extra,
      }) {
    context.goNamed(linkName,
        params: params, queryParams: queryParams, extra: extra);
  }

  void pop(BuildContext context) {
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;
    if (canPop) {
      context.pop();
    } else {
      context.goNamed(linkName);
    }
  }
}