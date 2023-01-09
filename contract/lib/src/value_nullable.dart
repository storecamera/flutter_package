part of 'value.dart';

class ValueN<T> extends _Value<T> {
  ValueN({Object? error}) : super._(value: null, error: error);

  ValueN.value({required T? value, Object? error})
      : super._(value: value, error: error, state: ContractValueState.active);

  T? get value => _value;

  set value(T? value) {
    if (state == ContractValueState.disposed) {
      throw const ContractExceptionValueStatus('value is not set because ContractValueState is disposed');
    }
    _value = value;
    _error = null;
    _state = ContractValueState.active;
    notifyListeners();
  }
}

abstract class ValueNWidget<T> extends StatefulWidget {
  final ValueN<T> value;

  const ValueNWidget({super.key, required this.value});

  @override
  State<ValueNWidget<T>> createState() =>
      _ValueNWidgetState<T>();

  Widget build(BuildContext context, ValueN<T> value);
}

class _ValueNWidgetState<T> extends State<ValueNWidget<T>> {
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
  void didUpdateWidget(covariant ValueNWidget<T> oldWidget) {
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

typedef ValueNWidgetBuilder<T> = Widget Function(
    BuildContext context, ValueN<T> value);
typedef ValueNWidgetValueBuilder<T> = Widget Function(
    BuildContext context, T? value);
typedef ValueNWidgetErrorBuilder<T> = Widget Function(
    BuildContext context, Object error, T? value);
typedef ValueNWidgetWaitBuilder<T> = Widget Function(
    BuildContext context, T? value);

class ValueNBuilder<T> extends ValueNWidget<T> {
  final ValueNWidgetBuilder<T>? builder;
  final ValueNWidgetValueBuilder<T>? valueBuilder;
  final ValueNWidgetErrorBuilder<T>? errorBuilder;
  final ValueNWidgetWaitBuilder<T>? waitBuilder;

  const ValueNBuilder(
      {super.key,
      required super.value,
      this.builder,
      this.valueBuilder,
      this.errorBuilder,
      this.waitBuilder});

  @override
  Widget build(BuildContext context, ValueN<T> value) {
    if (builder != null) {
      return builder!(context, value);
    } else {
      final state = value.state;
      if (state == ContractValueState.waiting) {
        return waitBuilder?.call(context, value.value) ?? const SizedBox();
      } else if (value.error != null) {
        return errorBuilder?.call(context, value.error!, value.value) ??
            const SizedBox();
      } else {
        return valueBuilder?.call(context, value.value) ?? const SizedBox();
      }
    }
  }
}

extension ValueNExtension<T> on ValueN<T> {
  Widget builder({
    ValueNWidgetBuilder<T>? builder,
    ValueNWidgetValueBuilder<T>? valueBuilder,
    ValueNWidgetErrorBuilder<T>? errorBuilder,
    ValueNWidgetWaitBuilder<T>? waitBuilder,
  }) {
    return ValueNBuilder(
      value: this,
      builder: builder,
      valueBuilder: valueBuilder,
      errorBuilder: errorBuilder,
      waitBuilder: waitBuilder,
    );
  }
}
