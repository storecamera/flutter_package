import 'package:flutter/widgets.dart';

typedef ContractObserverListener = void Function(Route<dynamic>? route);

class ContractObserver extends RouteObserver<ModalRoute<dynamic>> {
  static final ContractObserver _instance = ContractObserver._();

  static ContractObserver get instance => _instance;

  ContractObserver._();

  final List<ContractObserverListener> _listener = [];
  Route<dynamic>? route;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    this.route = route;
    _changeRoute();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    route = newRoute;
    _changeRoute();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    this.route = previousRoute;
    _changeRoute();
  }

  void _changeRoute() {
    for (final listener in _listener) {
      listener(route);
    }
  }

  void addListener(ContractObserverListener listener) =>
      _listener.add(listener);

  void removeListener(ContractObserverListener listener) =>
      _listener.remove(listener);
}