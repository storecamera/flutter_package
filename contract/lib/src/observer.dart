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
    if(route.settings.name == null) {
      return;
    }
    this.route = route;
    _changeRoute();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if(newRoute?.settings.name == null) {
      return;
    }
    route = newRoute;
    _changeRoute();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if(previousRoute?.settings.name == null) {
      return;
    }
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

typedef ContractObserverWidgetBuilder = Widget Function(
    BuildContext context, ContractObserver observer);

class ContractObserverBuilder extends StatefulWidget {
  final ContractObserverWidgetBuilder builder;

  const ContractObserverBuilder({super.key, required this.builder});

  @override
  State<ContractObserverBuilder> createState() =>
      _ContractObserverBuilderState();
}

class _ContractObserverBuilderState extends State<ContractObserverBuilder> {
  final ContractObserver observer = ContractObserver._();

  @override
  Widget build(BuildContext context) {
    return ContractObserverInheritedWidget(
      observer: observer,
      child: widget.builder(context, observer),
    );
  }
}

class ContractObserverInheritedWidget extends InheritedWidget {
  final ContractObserver observer;

  const ContractObserverInheritedWidget(
      {super.key, required this.observer, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
