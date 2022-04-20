import 'package:flutter/widgets.dart';
import 'exceptions.dart';
import 'service.dart';

class ServiceBuilder<T extends Service> extends StatefulWidget {
  const ServiceBuilder({Key? key, required this.builder, this.notFoundBuilder})
      : super(key: key);

  final Widget Function(BuildContext context, T service) builder;
  final Widget Function(BuildContext context)? notFoundBuilder;

  @override
  State<ServiceBuilder<T>> createState() => _ServiceBuilderState<T>();
}

class _ServiceBuilderState<T extends Service> extends State<ServiceBuilder<T>> {
  T? _service;

  @override
  void initState() {
    super.initState();

    try {
      final service = Service.of<T>();
      service.addListener(_setState);
      _service = service;
    } catch (_) {}
  }

  @override
  void dispose() {
    final service = _service;
    if (service != null) {
      service.removeListener(_setState);
    }
    _service = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = _service;
    if (service != null) {
      return widget.builder(context, service);
    } else if (widget.notFoundBuilder != null) {
      return widget.notFoundBuilder!(context);
    }
    throw ContractExceptions.notFoundServiceAtBuilder.exception;
  }

  void _setState() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ServiceBuilder<T> oldWidget) {
    if (_service == null) {
      try {
        final service = Service.of<T>();
        service.addListener(_setState);
        setState(() {
          _service = service;
        });
      } catch (_) {}
    }

    super.didUpdateWidget(oldWidget);
  }
}
