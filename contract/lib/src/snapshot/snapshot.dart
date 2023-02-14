import 'dart:async';

import 'package:contract/src/exceptions.dart';
import 'package:flutter/widgets.dart';

part 'snapshot_nullable.dart';

enum SnapshotState {
  waiting,
  active,
  disposed,
}

abstract class _Snapshot<T> extends ChangeNotifier {
  SnapshotState _state;
  T? _value;
  Object? _error;

  _Snapshot._({T? value, SnapshotState? state})
      : _value = value,
        _state = state ??
            (value != null ? SnapshotState.active : SnapshotState.waiting);

  SnapshotState get state => _state;

  bool get hasValue => _value != null;

  bool get isWaiting => state == SnapshotState.waiting;

  bool get isActive => state == SnapshotState.active;

  bool get isError => _error != null;

  bool get isDisposed => state == SnapshotState.disposed;

  Object? get error => _error;

  @override
  void dispose() {
    if (isDisposed) {
      return;
    }
    _state = SnapshotState.disposed;
    super.dispose();
  }
}

class Snapshot<T> extends _Snapshot<T> with _SnapshotStream<T> {
  Snapshot([T? value]) : super._(value: value);

  static Snapshot<T> notnull<T>([T? value]) => Snapshot<T>(value);

  static SnapshotN<T> nullable<T>() => SnapshotN();

  static SnapshotN<T> nullableAndInit<T>([T? value]) => SnapshotN.active(value);

  T get value {
    if (_value != null) {
      return _value!;
    }
    throw const ContractExceptionValueStatus('value is null');
  }

  T? get valueOrNull => _value;

  set value(T value) {
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

  Stream<T> asStream() {
    late final StreamController<T> controller;
    controller = StreamController<T>.broadcast(
      onListen: () {
        _streamControllers.add(controller);
        final error = _error;
        if (error != null) {
          controller.addError(error);
          return;
        }
        final value = _value;
        if (isActive && value != null) {
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

mixin _SnapshotStream<T> {
  final Set<StreamController<T>> _streamControllers = {};

  void _addToSnapshotStream(T value) {
    for (final controller in _streamControllers) {
      if (controller.hasListener && !controller.isClosed) {
        controller.add(value);
      }
    }
  }

  void _addErrorToSnapshotStream(Object error) {
    for (final controller in _streamControllers) {
      if (controller.hasListener && !controller.isClosed) {
        controller.addError(error);
      }
    }
  }

  void _disposeToSnapshotStream() {
    for (final controller in _streamControllers) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _streamControllers.clear();
  }
}

// ignore: library_private_types_in_public_api
abstract class SnapshotWidget<T extends _Snapshot> extends StatelessWidget {
  final T snapshot;

  const SnapshotWidget({super.key, required this.snapshot});

  @override
  SnapshotElement<T> createElement() => SnapshotElement<T>(this);
}

// ignore: library_private_types_in_public_api
class SnapshotElement<T extends _Snapshot> extends StatelessElement {
  SnapshotElement(SnapshotWidget<T> super.widget);

  @override
  SnapshotWidget<T> get widget => super.widget as SnapshotWidget<T>;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget.snapshot.addListener(markNeedsBuild);
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    widget.snapshot.removeListener(markNeedsBuild);
    super.unmount();
  }

  @override
  void update(SnapshotWidget<T> newWidget) {
    if (widget.snapshot != newWidget.snapshot) {
      widget.snapshot.removeListener(markNeedsBuild);
      newWidget.snapshot.addListener(markNeedsBuild);
    }
    super.update(newWidget);
  }
}

typedef SnapshotWidgetBuilder<T> = Widget Function(
    BuildContext context, Snapshot<T> snapshot);
typedef SnapshotValueBuilder<T> = Widget Function(
    BuildContext context, T value);
typedef SnapshotErrorBuilder<T> = Widget Function(
    BuildContext context, Object error, T? value);
typedef SnapshotWaitBuilder<T> = Widget Function(BuildContext context);

class SnapshotBuilder<T> extends SnapshotWidget<Snapshot<T>> {
  final SnapshotWidgetBuilder<T>? builder;
  final SnapshotValueBuilder<T>? value;
  final SnapshotErrorBuilder<T>? error;
  final SnapshotWaitBuilder<T>? wait;

  const SnapshotBuilder(
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
          final value = snapshot.valueOrNull;
          final error = snapshot.error;
          if (error != null) {
            return this.error?.call(context, error, value) ?? const SizedBox();
          }

          if (value != null) {
            return this.value?.call(context, value) ?? const SizedBox();
          }
          return const SizedBox();
      }
    }
  }
}

extension SnapshotExtension<T> on Snapshot<T> {
  Widget builder({
    SnapshotWidgetBuilder<T>? builder,
    SnapshotValueBuilder<T>? value,
    SnapshotErrorBuilder<T>? error,
    SnapshotWaitBuilder<T>? wait,
  }) {
    return SnapshotBuilder(
      snapshot: this,
      builder: builder,
      value: value,
      error: error,
      wait: wait,
    );
  }
}
