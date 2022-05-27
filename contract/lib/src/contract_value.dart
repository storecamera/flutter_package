import 'package:flutter/widgets.dart';

enum ContractValueState {
  waiting,
  active,
  disposed,
}

class ContractValue<T> {
  ContractValueState _state;
  T? _value;
  Object? _error;
  final subscriptions = <ContractValueSubscription<T>>[];

  ContractValue({T? value, Object? error})
      : _value = value,
        _error = error,
        _state = value != null
            ? ContractValueState.active
            : ContractValueState.waiting;

  ContractValueState get state => _state;

  bool get hasValue => _value != null;

  T? get valueOrNull => _value;

  T get value {
    if (_value != null) {
      return _value!;
    }
    throw NullThrownError();
  }

  set value(T value) {
    if (state == ContractValueState.disposed) {
      throw StateError('value is not set because ConnectionState is disposed');
    }
    _value = value;
    _error = null;
    _state = ContractValueState.active;
    notifyListeners();
  }

  void waiting() => state == ContractValueState.waiting;

  Object? get error => _error;

  set error(Object? error) {
    if (state == ContractValueState.disposed) {
      throw StateError('error is not set because ConnectionState is disposed');
    }
    _error = error;
    notifyListeners();
  }

  void notifyListeners() {
    if (state == ContractValueState.disposed) {
      throw StateError(
          'notifyListeners is not set because ConnectionState is disposed');
    }
    for (final subscription in subscriptions) {
      subscription._onData?.call(this);
    }
  }

  void dispose() {
    if (state == ContractValueState.disposed) {
      throw StateError('dispose is not set because ConnectionState is disposed');
    }
    _state = ContractValueState.disposed;
    for(final subscription in subscriptions) {
      subscription._onData = null;
      subscription._dispose = null;
    }
    subscriptions.clear();
  }

  ContractValueSubscription<T> listen(
      ContractValueSubscriptionListener<T> onData) {
    if (state == ContractValueState.disposed) {
      throw StateError('listen is not set because ConnectionState is disposed');
    }
    final subscription = ContractValueSubscription<T>(
        onData: onData,
        dispose: (_) {
          subscriptions.remove(_);
        });
    subscriptions.add(subscription);
    if (_state == ContractValueState.active) {
      subscription._onData?.call(this);
    }

    return subscription;
  }
}

typedef ContractValueSubscriptionListener<T> = void Function(
    ContractValue<T> value);

typedef ContractValueDispose<T> = void Function(
    ContractValueSubscription<T> subscription);

class ContractValueSubscription<T> {
  ContractValueSubscriptionListener<T>? _onData;
  ContractValueDispose<T>? _dispose;

  ContractValueSubscription(
      {required ContractValueSubscriptionListener<T> onData,
        required ContractValueDispose<T> dispose})
      : _onData = onData,
        _dispose = dispose;

  void dispose() {
    _onData = null;
    _dispose?.call(this);
    _dispose = null;
  }
}

typedef ContractValueWidgetBuilder<T> = Widget Function(
    BuildContext context, ContractValue<T> value);

class ContractValueBuilder<T> extends StatefulWidget {
  final ContractValue<T> value;
  final ContractValueWidgetBuilder<T> builder;

  const ContractValueBuilder(
      {super.key, required this.value, required this.builder});

  @override
  State<ContractValueBuilder<T>> createState() =>
      _ContractValueBuilderState<T>();
}

class _ContractValueBuilderState<T> extends State<ContractValueBuilder<T>> {

  ContractValueSubscription<T>? subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.value.listen((value) {
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
      subscription = widget.value.listen((value) {
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

extension ContractValueExtension<T> on ContractValue<T> {
  Widget builder({
    ContractValueWidgetBuilder<T>? builder,
    Widget Function(BuildContext context, T value)? valueBuilder,
    Widget Function(BuildContext context, Object error, T? value)? errorBuilder,
    Widget Function(BuildContext context, T? value)? waitingBuilder,
  }) {
    if (builder != null) {
      return ContractValueBuilder<T>(
        value: this,
        builder: builder,
      );
    } else {
      return ContractValueBuilder<T>(
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
