part of 'contract.dart';

typedef ContractServiceLazyPut<T extends Service> = T Function();

class Service extends ChangeNotifier with ContractFragment {
  static T of<T extends Service>() {
    final service = _Services.instance.of<T>();
    if (service != null) {
      return service;
    }
    throw ContractExceptions.notFoundService.exception;
  }

  static bool put<T extends Service>(T service) =>
      _Services.instance.put<T>(service);

  static void lazyPut<T extends Service>(ContractServiceLazyPut<T> service) =>
      _Services.instance.lazyPut<T>(service);

  static void remove<T extends Service>() => _Services.instance.remove<T>();

  static void disposeService() => _Services.instance.dispose();

  @override
  @protected
  @mustCallSuper
  void dispose() {
    onDispose();
    super.dispose();
  }

  @override
  void update() {
    notifyListeners();
  }
}

class _Services {
  static final _Services _instance = _Services._();

  static _Services get instance => _instance;

  _Services._();

  final Map<Type, ContractServiceLazyPut> _lazyPut = {};
  final Map<Type, Service> _services = {};

  void lazyPut<T extends Service>(ContractServiceLazyPut<T> service) {
    _lazyPut[T] = service;
  }

  bool put<T extends Service>(T service) {
    if (!_services.containsKey(T) && !_lazyPut.containsKey(T)) {
      // ignore: invalid_use_of_protected_member
      _services[T] = service..onInit();
      return true;
    }
    return false;
  }

  void remove<T extends Service>() {
    _services.remove(T)?.dispose();
  }

  T? of<T extends Service>() => _of<T>();

  T? _of<T extends ContractFragment>() {
    final service = _services[T];
    if (service is T) {
      return service as T;
    }
    final lazyPut = _lazyPut[T];
    if (lazyPut != null) {
      final newService = lazyPut();
      if (newService is T) {
        // ignore: invalid_use_of_protected_member
        _services[T] = newService..onInit();
        return newService as T;
      }
    }

    return null;
  }

  void dispose() {
    for (final service in _services.values) {
      service.dispose();
    }
    _lazyPut.clear();
    _services.clear();
  }
}
