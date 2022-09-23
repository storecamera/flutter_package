import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum ContractValueState {
  waiting,
  active,
  disposed,
}

class ContractValue<T> extends ChangeNotifier {
  ContractValueState _state;
  T? _value;
  Object? _error;
  final subscriptions = <ContractValueSubscription>[];

  ContractValue._({T? value, Object? error})
      : _value = value,
        _error = error,
        _state = value != null
            ? ContractValueState.active
            : ContractValueState.waiting;

  static ContractNotNull<T> notNull<T>({T? value, Object? error}) =>
      ContractNotNull(value: value, error: error);

  static ContractNullable<T> nullable<T>({Object? error}) =>
      ContractNullable(error: error);

  ContractValueState get state => _state;

  bool get hasValue => _value != null;

  bool get isWaiting => state == ContractValueState.waiting;

  bool get isDisposed => state == ContractValueState.disposed;

  Object? get error => _error;

  set error(Object? error) {
    if (state == ContractValueState.disposed) {
      throw StateError('error is not set because ConnectionState is disposed');
    }
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    if (state == ContractValueState.disposed) {
      throw StateError(
          'dispose is not set because ConnectionState is disposed');
    }
    _state = ContractValueState.disposed;
    for (final subscription in subscriptions) {
      subscription._data = null;
      subscription._dispose = null;
    }
    subscriptions.clear();
    _valueStreamSubscription?.cancel();
    super.dispose();
  }

  void clear() {
    if (state == ContractValueState.disposed) {
      throw StateError(
          'clear is not set because ConnectionState is disposed');
    }
    _state = ContractValueState.waiting;
    _value = null;
    for (final subscription in subscriptions) {
      subscription._data = null;
      subscription._dispose = null;
    }
    subscriptions.clear();
    _valueStreamSubscription?.cancel();
    super.dispose();
  }

  ContractValueSubscription listen(VoidCallback listener,
      [bool initNotify = false]) {
    if (state == ContractValueState.disposed) {
      throw StateError('listen is not set because ConnectionState is disposed');
    }

    final subscription = ContractValueSubscription._(
        onData: listener,
        onDispose: (_) {
          final onData = _._data;
          if (onData != null) {
            subscriptions.remove(_);
            removeListener(onData);
          }
        });

    addListener(listener);
    subscriptions.add(subscription);
    if (initNotify) {
      listener();
    }

    return subscription;
  }

  StreamSubscription<T>? _valueStreamSubscription;

  void valueFromSteam(Stream<T> stream) {
    _valueStreamSubscription?.cancel();
    _valueStreamSubscription = stream.listen((event) {
      _value = event;
      _error = null;
      _state = ContractValueState.active;
      notifyListeners();
    }, onError: (Object error, [StackTrace? stackTrace]) {
      if (kDebugMode) {
        print(error.toString());
      }
      _error = error;
      notifyListeners();
    });
  }
}

typedef _ContractValueDispose = void Function(
    ContractValueSubscription subscription);

class ContractValueSubscription {
  VoidCallback? _data;
  _ContractValueDispose? _dispose;

  ContractValueSubscription._(
      {required VoidCallback onData, required _ContractValueDispose onDispose})
      : _data = onData,
        _dispose = onDispose;

  void dispose() {
    final onData = _data;
    if (onData != null) {
      _dispose?.call(this);
      _data = null;
      _dispose = null;
    }
  }
}

class ContractNotNull<T> extends ContractValue<T> {
  ContractNotNull({T? value, Object? error})
      : super._(value: value, error: error);

  T get value {
    if (_value != null) {
      return _value!;
    }
    throw NullThrownError();
  }

  T? get valueOrNull => _value;

  set value(T value) {
    if (state == ContractValueState.disposed) {
      throw StateError('value is not set because ConnectionState is disposed');
    }
    _value = value;
    _error = null;
    _state = ContractValueState.active;
    notifyListeners();
  }
}

class ContractNullable<T> extends ContractValue<T> {
  ContractNullable({Object? error}) : super._(value: null, error: error);

  T? get value => _value;

  set value(T? value) {
    if (state == ContractValueState.disposed) {
      throw StateError('value is not set because ConnectionState is disposed');
    }
    _value = value;
    _error = null;
    _state = ContractValueState.active;
    notifyListeners();
  }
}

// class ContractValue<T> {
//   ContractValueState _state;
//   T? _value;
//   Object? _error;
//   final subscriptions = <ContractValueSubscription<T>>[];
//
//   ContractValue({T? value, Object? error})
//       : _value = value,
//         _error = error,
//         _state = value != null
//             ? ContractValueState.active
//             : ContractValueState.waiting;
//
//   ContractValueState get state => _state;
//
//   bool get hasValue => _value != null;
//
//   T? get valueOrNull => _value;
//
//   T get value {
//     if (_value != null) {
//       return _value!;
//     }
//     throw NullThrownError();
//   }
//
//   set value(T value) {
//     if (state == ContractValueState.disposed) {
//       throw StateError('value is not set because ConnectionState is disposed');
//     }
//     _value = value;
//     _error = null;
//     _state = ContractValueState.active;
//     notifyListeners();
//   }
//
//   void clear() {
//     if (state == ContractValueState.disposed) {
//       throw StateError('value is not set because ConnectionState is disposed');
//     }
//
//     _value = null;
//     _error = null;
//     _state = ContractValueState.waiting;
//   }
//
//   bool get isWaiting => state == ContractValueState.waiting;
//
//   bool get isDisposed => state == ContractValueState.disposed;
//
//   Object? get error => _error;
//
//   set error(Object? error) {
//     if (state == ContractValueState.disposed) {
//       throw StateError('error is not set because ConnectionState is disposed');
//     }
//     _error = error;
//     notifyListeners();
//   }
//
//   void notifyListeners() {
//     if (state == ContractValueState.disposed) {
//       throw StateError(
//           'notifyListeners is not set because ConnectionState is disposed');
//     }
//     for (final subscription in subscriptions) {
//       subscription._onData?.call(this);
//     }
//   }
//
//   void dispose() {
//     if (state == ContractValueState.disposed) {
//       throw StateError('dispose is not set because ConnectionState is disposed');
//     }
//     _state = ContractValueState.disposed;
//     for(final subscription in subscriptions) {
//       subscription._onData = null;
//       subscription._dispose = null;
//     }
//     subscriptions.clear();
//     _valueStreamSubscription?.cancel();
//   }
//
//   ContractValueSubscription<T> listen(
//       ContractValueSubscriptionListener<T> onData) {
//     if (state == ContractValueState.disposed) {
//       throw StateError('listen is not set because ConnectionState is disposed');
//     }
//     final subscription = ContractValueSubscription<T>(
//         onData: onData,
//         dispose: (_) {
//           subscriptions.remove(_);
//         });
//     subscriptions.add(subscription);
//     if (_state == ContractValueState.active) {
//       subscription._onData?.call(this);
//     }
//
//     return subscription;
//   }
//
//   StreamSubscription<T>? _valueStreamSubscription;
//   void valueFromSteam(Stream<T> stream) {
//     _valueStreamSubscription?.cancel();
//     _valueStreamSubscription = stream.listen((event) {
//       value = event;
//     });
//   }
// }
//
// typedef ContractValueSubscriptionListener<T> = void Function(
//     ContractValue<T> value);
//
// typedef ContractValueDispose<T> = void Function(
//     ContractValueSubscription<T> subscription);
//
// class ContractValueSubscription<T> {
//   ContractValueSubscriptionListener<T>? _onData;
//   ContractValueDispose<T>? _dispose;
//
//   ContractValueSubscription(
//       {required ContractValueSubscriptionListener<T> onData,
//         required ContractValueDispose<T> dispose})
//       : _onData = onData,
//         _dispose = dispose;
//
//   void dispose() {
//     _onData = null;
//     _dispose?.call(this);
//     _dispose = null;
//   }
// }
//
typedef ContractValueWidgetBuilder<T extends ContractValue> = Widget Function(
    BuildContext context, T value);

class ContractValueBuilder<T extends ContractValue> extends StatefulWidget {
  final T value;
  final ContractValueWidgetBuilder<T> builder;

  const ContractValueBuilder(
      {super.key, required this.value, required this.builder});

  @override
  State<ContractValueBuilder<T>> createState() =>
      _ContractValueBuilderState<T>();
}

class _ContractValueBuilderState<T extends ContractValue>
    extends State<ContractValueBuilder<T>> {
  ContractValueSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.value.listen(() {
      _didChangedSnapshot();
    });
  }

  @override
  void dispose() {
    subscription?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ContractValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      subscription?.dispose();
      subscription = widget.value.listen(() {
        _didChangedSnapshot();
      });
      _didChangedSnapshot();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.value);
  }

  void _didChangedSnapshot() => setState(() {});
}

extension ContractNotNullBuilder<T> on ContractNotNull<T> {
  Widget builder({
    ContractValueWidgetBuilder<ContractNotNull<T>>? builder,
    Widget Function(BuildContext context, T value)? valueBuilder,
    Widget Function(BuildContext context, Object error, T? value)? errorBuilder,
    Widget Function(BuildContext context, T? value)? waitingBuilder,
  }) {
    if (builder != null) {
      return ContractValueBuilder<ContractNotNull<T>>(
        value: this,
        builder: builder,
      );
    } else {
      return ContractValueBuilder<ContractNotNull<T>>(
        value: this,
        builder: (context, contractValue) {
          if (contractValue.state == ContractValueState.waiting) {
            return waitingBuilder?.call(context, contractValue.valueOrNull) ??
                Container();
          } else if (contractValue.error != null) {
            return errorBuilder?.call(
                    context, contractValue.error!, contractValue.valueOrNull) ??
                Container();
          } else if (contractValue.hasValue) {
            return valueBuilder?.call(context, contractValue.value) ??
                Container();
          }
          return Container();
        },
      );
    }
  }
}

extension ContractNullableBuilder<T> on ContractNullable<T> {
  Widget builder({
    ContractValueWidgetBuilder<ContractNullable<T>>? builder,
    Widget Function(BuildContext context, T? value)? valueBuilder,
    Widget Function(BuildContext context, Object error, T? value)? errorBuilder,
    Widget Function(BuildContext context, T? value)? waitingBuilder,
  }) {
    if (builder != null) {
      return ContractValueBuilder<ContractNullable<T>>(
        value: this,
        builder: builder,
      );
    } else {
      return ContractValueBuilder<ContractNullable<T>>(
        value: this,
        builder: (context, contractValue) {
          if (contractValue.state == ContractValueState.waiting) {
            return waitingBuilder?.call(context, contractValue.value) ??
                Container();
          } else if (contractValue.error != null) {
            return errorBuilder?.call(
                    context, contractValue.error!, contractValue.value) ??
                Container();
          } else {
            return valueBuilder?.call(context, contractValue.value) ??
                Container();
          }
        },
      );
    }
  }
}
