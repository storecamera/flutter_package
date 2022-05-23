import 'package:flutter/widgets.dart';

enum ContractSnapshotState {
  waiting,
  active,
  disposed,
}

class ContractSnapshot<T> extends ChangeNotifier {
  ContractSnapshotState _state;
  T? _value;
  Object? _error;

  ContractSnapshot({T? value, Object? error})
      : _value = value,
        _error = error,
        _state = value != null
            ? ContractSnapshotState.active
            : ContractSnapshotState.waiting;

  ContractSnapshotState get state => _state;

  bool get hasValue => _value != null;

  T? get valueOrNull => _value;

  T get value {
    if (_value != null) {
      return _value!;
    }
    throw NullThrownError();
  }

  set value(T value) {
    if (state == ContractSnapshotState.disposed) {
      throw StateError('error is not set because ConnectionState is disposed');
    }
    _value = value;
    _error = null;
    _state = ContractSnapshotState.active;
    notifyListeners();
  }

  void waiting() => state == ContractSnapshotState.waiting;

  Object? get error => _error;

  set error(Object? error) {
    if (state == ContractSnapshotState.disposed) {
      throw StateError('error is not set because ConnectionState is disposed');
    }
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();

    _state = ContractSnapshotState.disposed;
  }
}

typedef ContractSnapshotWidgetBuilder<T> = Widget Function(BuildContext context, ContractSnapshot<T> snapshot);

class ContractSnapshotBuilder<T> extends StatefulWidget {
  final ContractSnapshot<T> snapshot;
  final ContractSnapshotWidgetBuilder<T> builder;

  const ContractSnapshotBuilder({super.key, required this.snapshot, required this.builder});

  @override
  State<ContractSnapshotBuilder<T>> createState() => _ContractSnapshotBuilderState<T>();
}

class _ContractSnapshotBuilderState<T> extends State<ContractSnapshotBuilder<T>> {

  @override
  void initState() {
    super.initState();
    widget.snapshot.addListener(_didChangedSnapshot);
  }

  @override
  void dispose() {
    widget.snapshot.removeListener(_didChangedSnapshot);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ContractSnapshotBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.snapshot != oldWidget.snapshot) {
      oldWidget.snapshot.removeListener(_didChangedSnapshot);
      widget.snapshot.addListener(_didChangedSnapshot);
      _didChangedSnapshot();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.snapshot);
  }

  void _didChangedSnapshot() => setState(() {});
}