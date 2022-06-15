import 'package:flutter/foundation.dart';

/// level 1 : Only e
/// level 2 : i + e
/// level 3 : v + i + e
var logLevel = 3;

// ignore: camel_case_types
class log {
  static void v(Object? object) {
    if (kDebugMode) {
      if(logLevel >= 3) {
        print(object);
      }
    }
  }

  static void i(Object? object) {
    if (kDebugMode) {
      if(logLevel >= 2) {
        print(object);
      }
    }
  }

  static void e(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }
}