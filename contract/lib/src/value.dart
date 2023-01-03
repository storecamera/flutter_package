import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

part 'value_notnull.dart';
part 'value_nullable.dart';

enum ContractValueState {
  waiting,
  active,
  disposed,
}

class _Value<T> extends ChangeNotifier {
  ContractValueState _state;
  T? _value;
  Object? _error;
  final subscriptions = <ContractValueSubscription>[];

  _Value._({T? value, Object? error})
      : _value = value,
        _error = error,
        _state = value != null
            ? ContractValueState.active
            : ContractValueState.waiting;

  // static ContractNotNull<T> notNull<T>({T? value, Object? error}) =>
  //     ContractNotNull(value: value, error: error);
  //
  // static ContractNullable<T> nullable<T>({Object? error}) =>
  //     ContractNullable(error: error);

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
