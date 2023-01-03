import 'package:flutter/foundation.dart';

class Log {
  static void i(Object? object, [bool printTime = false]) {
    _print(object, printTime);
  }

  static void d(Object? object, [bool printTime = false]) {
    _debugPrint(object, printTime);
  }

  static void _print(Object? msg, bool printTime) {
    if(printTime) {
      if (kDebugMode) {
        print('${_time()} : $msg');
      }
    } else {
      if (kDebugMode) {
        print(msg);
      }
    }
  }

  static void _debugPrint(Object? msg, bool printTime) {
    if(printTime) {
      if (kDebugMode) {
        debugPrint('${_time()} : $msg');
      }
    } else {
      if (kDebugMode) {
        debugPrint(msg?.toString());
      }
    }
  }

  static String _time(){
    return DateTime.now().toString();
  }
}
