import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'exceptions.dart';

class Service extends ChangeNotifier {
  static T of<T extends Service>() {
    final service = _Services.instance.of<T>();
    if (service != null) {
      return service;
    }
    throw ContractExceptions.notFoundService.exception;
  }

  static bool put<T extends Service>(T service) =>
      _Services.instance.put<T>(service);

  static void lazyPut<T extends Service>(ServiceLazyPut<T> service) =>
      _Services.instance.lazyPut<T>(service);

  static void remove<T extends Service>() => _Services.instance.remove<T>();

  static void disposeService() => _Services.instance.dispose();

  @protected
  @mustCallSuper
  void init() {}

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
  }
}

typedef ServiceLazyPut<T extends Service> = T Function();

class _Services {

  static final _Services _instance = _Services._();

  static _Services get instance => _instance;

  _Services._();

  final Map<Type, ServiceLazyPut> _lazyPut = {};
  final Map<Type, Service> _services = {};

  void lazyPut<T extends Service>(ServiceLazyPut<T> service) {
    _lazyPut[T] = service;
  }

  bool put<T extends Service>(T service) {
    if (!_services.containsKey(T) && !_lazyPut.containsKey(T)) {
      _services[T] = service..init();
      return true;
    }
    return false;
  }

  void remove<T extends Service>() {
    _services.remove(T)?.dispose();
  }

  T? of<T extends Service>() {
    final service = _services[T];
    if (service is T) {
      return service;
    }
    final lazyPut = _lazyPut[T];
    if(lazyPut != null) {
      final newService = lazyPut();
      if(newService is T) {
        _services[T] = newService..init();
        return newService;
      }
    }

    return null;
  }

  void dispose() {
    for(final service in _services.values) {
      service.dispose();
    }
    _lazyPut.clear();
    _services.clear();
  }
}

