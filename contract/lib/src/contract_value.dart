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
      throw StateError('error is not set because ConnectionState is disposed');
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

  @override
  void dispose() {
    super.dispose();

    _state = ContractValueState.disposed;
  }
}

typedef ContractValueWidgetBuilder<T> = Widget Function(BuildContext context, ContractValue<T> snapshot);

class ContractValueBuilder<T> extends StatefulWidget {
  final ContractValue<T> snapshot;
  final ContractValueWidgetBuilder<T> builder;

  const ContractValueBuilder({super.key, required this.snapshot, required this.builder});

  @override
  State<ContractValueBuilder<T>> createState() => _ContractValueBuilderState<T>();
}

class _ContractValueBuilderState<T> extends State<ContractValueBuilder<T>> {

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
  void didUpdateWidget(covariant ContractValueBuilder<T> oldWidget) {
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