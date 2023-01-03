part of 'value.dart';

class Value<T> extends _Value<T> {
  Value({T? value, Object? error})
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

abstract class ValueWidget<T> extends StatefulWidget {
  final Value<T> value;

  const ValueWidget({super.key, required this.value});

  @override
  State<ValueWidget<T>> createState() =>
      _ValueWidgetState<T>();

  Widget build(BuildContext context, Value<T> value);
}

class _ValueWidgetState<T> extends State<ValueWidget<T>> {
  ContractValueSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.value.listen(_didChangedValue);
  }

  @override
  void dispose() {
    subscription?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ValueWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      subscription?.dispose();
      subscription = widget.value.listen(_didChangedValue);
      _didChangedValue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, widget.value);
  }

  void _didChangedValue() => setState(() {});
}

typedef ValueWidgetBuilder<T> = Widget Function(
    BuildContext context, Value<T> value);
typedef ValueWidgetValueBuilder<T> = Widget Function(
    BuildContext context, T value);
typedef ValueWidgetErrorBuilder<T> = Widget Function(
    BuildContext context, Object error, T? value);
typedef ValueWidgetWaitBuilder<T> = Widget Function(
    BuildContext context, T? value);

class ValueBuilder<T> extends ValueWidget<T> {
  final ValueWidgetBuilder<T>? builder;
  final ValueWidgetValueBuilder<T>? valueBuilder;
  final ValueWidgetErrorBuilder<T>? errorBuilder;
  final ValueWidgetWaitBuilder<T>? waitBuilder;

  const ValueBuilder(
      {super.key,
      required super.value,
      this.builder,
      this.valueBuilder,
      this.errorBuilder,
      this.waitBuilder});

  @override
  Widget build(BuildContext context, Value<T> value) {
    if (builder != null) {
      return builder!(context, value);
    } else {
      final state = value.state;
      if (state == ContractValueState.waiting) {
        return waitBuilder?.call(context, value.valueOrNull) ??
            const SizedBox();
      } else if (value.error != null) {
        return errorBuilder?.call(context, value.error!, value.valueOrNull) ??
            const SizedBox();
      } else if (value.hasValue) {
        return valueBuilder?.call(context, value.value) ?? const SizedBox();
      }

      return const SizedBox();
    }
  }
}

extension ValueExtension<T> on Value<T> {
  Widget builder({
    ValueWidgetBuilder<T>? builder,
    ValueWidgetValueBuilder<T>? valueBuilder,
    ValueWidgetErrorBuilder<T>? errorBuilder,
    ValueWidgetWaitBuilder<T>? waitBuilder,
  }) {
    return ValueBuilder(value: this,
      builder: builder,
      valueBuilder: valueBuilder,
      errorBuilder: errorBuilder,
      waitBuilder: waitBuilder,
    );
  }
}
