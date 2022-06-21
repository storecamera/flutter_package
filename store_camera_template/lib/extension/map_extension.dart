
import 'package:flutter/foundation.dart';

extension MapExtension on Map {
  T? get<T>(dynamic key, {T? Function(Map map)? converter, bool debug = false}) {
    if (debug) {
      if (kDebugMode) {
        print(
            'MAP EXTENSION key : $key, value ${this[key]}, T : $T, Type : ${this[key]?.runtimeType}');
      }
    }

    switch (T) {
      case int:
        return (dynamicToInt(this[key]) as T?);
      case double:
        return (dynamicToDouble(this[key]) as T?);
      case String:
        return (dynamicToString(this[key]) as T?);
      case bool:
        return (dynamicToBool(this[key]) as T?);
      case Map:
        return this[key] is Map ? this[key] : null;
      default:
        final value = this[key];
        if (value is Map && converter != null) {
          return converter(value);
        }
        return value is T ? value : null;
    }
  }

  T notNull<T>(dynamic key, {T? Function(Map map)? converter}) {
    dynamic value;
    switch (T) {
      case int:
        value = dynamicToInt(this[key]);
        break;
      case double:
        value = dynamicToDouble(this[key]);
        break;
      case String:
        value = dynamicToString(this[key]);
        break;
      case bool:
        value = dynamicToBool(this[key]);
        break;
      case Map:
        value = this[key] is Map ? this[key] : null;
        break;
      default:
        final map = this[key];
        if (map is Map && converter != null) {
          value = converter(map);
        } else {
          value = map;
        }
        break;
    }

    if (value is T) {
      return value;
    }
    throw NullThrownError();
  }

  List<T> getList<T>(dynamic key, [T Function(Map map)? converter]) {
    final results = <T>[];

    final list = this[key];
    if (list is List) {
      try {
        for (final obj in list) {
          T? value;
          switch (T) {
            case int:
              value = dynamicToInt(obj) as T?;
              break;
            case double:
              value = dynamicToDouble(obj) as T?;
              break;
            case String:
              value = dynamicToString(obj) as T?;
              break;
            case bool:
              value = dynamicToBool(obj) as T?;
              break;
            case Map:
              value = obj is Map ? obj as T : null;
              break;
            default:
              if (obj is Map && converter != null) {
                value = converter(obj);
              }
              break;
          }

          if (value != null) {
            results.add(value);
          }
        }
      } catch (_) {
        if (kDebugMode) {
          print('Map getList Error $_');
        }
      }
    }

    return results;
  }

  void removeNull() => removeWhere((key, value) => value == null);
}

bool? dynamicToBool(dynamic value) {
  if (value is bool) {
    return value;
  } else {
    return null;
  }
}

int? dynamicToInt(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is double) {
    return value.toInt();
  } else if (value is String) {
    return int.tryParse(value);
  } else {
    return null;
  }
}

double? dynamicToDouble(dynamic value) {
  if (value is double) {
    return value;
  } else if (value is int) {
    return value.toDouble();
  } else if (value is String) {
    return double.tryParse(value);
  } else {
    return null;
  }
}

String? dynamicToString(dynamic value) {
  if (value is String) {
    return value;
  } else {
    return value?.toString();
  }
}
