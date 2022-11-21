import 'package:flutter/foundation.dart';

/// level 1 : Only e
/// level 2 : i + e
/// level 3 : v + i + e
var logLevel = 3;

// ignore: camel_case_types
typedef log = Log;

class Log {
  static void v(Object? object, [bool printTime = false]) {
    if(logLevel >= 3) {
      _printMsg(object, printTime);
    }
  }

  static void i(Object? object, [bool printTime = false]) {
    if(logLevel >= 2) {
      _printMsg(object, printTime);
    }
  }

  static void e(Object? object, [bool printTime = false]) {
    _printMsg(object, printTime);
  }

  static void _printMsg(Object? msg, bool printTime) {
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

  static String _time(){
    return DateTime.now().toString();
  }
}