import 'package:flutter/foundation.dart';

class Log {
  /// level 1 : Only e
  /// level 2 : i + e
  /// level 3 : d + i + e
  static int level = 3;

  static void d(Object? object, [bool printTime = false]) {
    if (level >= 3) {
      _debugPrint(object, printTime);
    }
  }

  static void i(Object? object, [bool printTime = false]) {
    if (level >= 2) {
      _debugPrint(object, printTime);
    }
  }

  static void e(Object? object, [bool printTime = false]) {
    _debugPrint(object, printTime);
  }

  static void _debugPrint(Object? msg, bool printTime) {
    if (printTime) {
      if (kDebugMode) {
        debugPrint('${_time()} : $msg');
      }
    } else {
      if (kDebugMode) {
        debugPrint(msg?.toString());
      }
    }
  }

  static String _time() {
    return DateTime.now().toString();
  }
}
