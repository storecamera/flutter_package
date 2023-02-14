part of 'snapshot.dart';

class SnapshotN<T> extends _Snapshot<T> with _SnapshotStream<T?> {

  SnapshotN() : super._();

  SnapshotN.active([T? value])
      : super._(value: value, state: SnapshotState.active);

  T? get value => _value;

  set value(T? value) {
    if (isDisposed) {
      throw const ContractExceptionValueStatus(
          'value is not set because SnapshotState is disposed');
    }
    _value = value;
    _error = null;
    _state = SnapshotState.active;
    _addToSnapshotStream(value);
    notifyListeners();
  }

  set error(Object? error) {
    if (error == null) {
      return;
    }

    if (isDisposed) {
      throw const ContractExceptionValueStatus(
          'error is not set because SnapshotState is disposed');
    }
    _error = error;
    _addErrorToSnapshotStream(error);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _disposeToSnapshotStream();
  }

  Stream<T?> asStream() {
    late final StreamController<T?> controller;
    controller = StreamController<T?>.broadcast(
      onListen: () {
        _streamControllers.add(controller);
        final error = _error;
        if (error != null) {
          controller.addError(error);
          return;
        }
        final value = _value;
        if (isActive) {
          controller.add(value);
        }
      },
      onCancel: () {
        controller.close();
        _streamControllers.remove(controller);
      },
      sync: true,
    );

    return controller.stream;
  }
}

typedef SnapshotNWidgetBuilder<T> = Widget Function(
    BuildContext context, SnapshotN<T> snapshot);
typedef SnapshotNValueBuilder<T> = Widget Function(
    BuildContext context, T? value);

class SnapshotNBuilder<T> extends SnapshotWidget<SnapshotN<T>> {
  final SnapshotNWidgetBuilder<T>? builder;
  final SnapshotNValueBuilder<T>? value;
  final SnapshotErrorBuilder<T>? error;
  final SnapshotWaitBuilder<T>? wait;

  const SnapshotNBuilder(
      {super.key,
      required super.snapshot,
      this.builder,
      this.value,
      this.error,
      this.wait});

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context, snapshot);
    } else {
      final state = snapshot.state;
      switch (state) {
        case SnapshotState.waiting:
          return wait?.call(context) ?? const SizedBox();
        case SnapshotState.active:
        case SnapshotState.disposed:
          final value = snapshot.value;
          final error = snapshot.error;
          if (error != null) {
            return this.error?.call(context, error, value) ?? const SizedBox();
          }
          return this.value?.call(context, value) ?? const SizedBox();
      }
    }
  }
}

extension SnapshotNExtension<T> on SnapshotN<T> {
  Widget builder({
    SnapshotNWidgetBuilder<T>? builder,
    SnapshotNValueBuilder<T>? value,
    SnapshotErrorBuilder<T>? error,
    SnapshotWaitBuilder<T>? wait,
  }) {
    return SnapshotNBuilder(
      snapshot: this,
      builder: builder,
      value: value,
      error: error,
      wait: wait,
    );
  }
}
