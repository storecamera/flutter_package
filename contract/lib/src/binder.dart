part of 'contract.dart';

typedef ContractBinderLazyPut<T extends Contract> = T Function();

abstract class ContractPage extends StatefulWidget {
  final dynamic arguments;

  const ContractPage({Key? key, this.arguments}) : super(key: key);

  @protected
  @factory
  BinderContract createBinder();

  Widget build(BuildContext context);

  @override
  State<StatefulWidget> createState() =>
      createBinder(); // ignore: no_logic_in_create_state
}

typedef ContractPageCreateBinder = BinderContract Function();

class ContractPageBuilder extends ContractPage {
  final ContractPageCreateBinder binder;
  final WidgetBuilder builder;

  const ContractPageBuilder(
      {super.key,
      super.arguments,
      required this.binder,
      required this.builder});

  @override
  Widget build(BuildContext context) => builder(context);

  @override
  BinderContract createBinder() => binder();
}

typedef ContractPageInitBinder = void Function(
    BuildContext context, BinderContract binder, dynamic arguments);

abstract class ContractBinderPage extends ContractPage {
  const ContractBinderPage({
    super.key,
    super.arguments,
  });

  void bind(BuildContext context, BinderContract binder, dynamic arguments);

  @override
  DefaultBinderContract createBinder() =>
      DefaultBinderContract(initBinder: bind);

  T? getArgumentsByType<T>(dynamic arg) {
    final arguments = arg;
    if (arguments is T) {
      return arguments;
    }
    return null;
  }
}

class ContractBinderPageBuilder extends ContractBinderPage {
  final ContractPageInitBinder binder;
  final WidgetBuilder builder;

  const ContractBinderPageBuilder(
      {super.key,
      super.arguments,
      required this.binder,
      required this.builder});

  @override
  void bind(BuildContext context, BinderContract binder, dynamic arguments) =>
      this.binder(context, binder, arguments);

  @override
  Widget build(BuildContext context) => builder(context);
}

abstract class BinderContract extends State<ContractPage>
    with ContractFragment, WidgetsBindingObserver {
  ContractObserver? _observer;
  final _BinderChangeNotifier _changeNotifier = _BinderChangeNotifier();

  final Map<Type, ContractBinderLazyPut> _lazyPut = {};
  final Map<Type, Contract> _contracts = {};

  bool _init = false;
  bool _initPageState = false;
  bool _isCurrent = false;
  bool _appLifecycle = false;
  bool _resumed = false;

  dynamic get arguments => widget.arguments;

  T? getArgumentsByType<T>() {
    final arguments = this.arguments;
    if (arguments is T) {
      return arguments;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => _init
      ? _ContractBinderInheritedWidget(
          binder: this,
          child: widget.build(context),
        )
      : Container();

  @override
  void initState() {
    super.initState();

    try {
      onInit();
    } catch (_) {
      if (kDebugMode) {
        print('_ContractBinderWidgetState initState e : $_');
      }
      return;
    }

    _init = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      if (!_initPageState) {
        _initPageState = true;
        for (final contract in _contracts.values) {
          contract._attachContract(context);
        }
        _didChangeAppLifecycle(WidgetsBinding.instance.lifecycleState ==
            AppLifecycleState.resumed);
        WidgetsBinding.instance.addObserver(this);

        _contractObserverListener(ModalRoute.of(context));
        final observerWidget = context
            .getElementForInheritedWidgetOfExactType<
                ContractObserverInheritedWidget>()
            ?.widget;
        if (ModalRoute.of(context)?.settings.name != null) {
          if (observerWidget is ContractObserverInheritedWidget) {
            _observer = observerWidget.observer;
          } else {
            _observer = ContractObserver.instance;
          }
          _observer?.addListener(_contractObserverListener);
        }
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _observer?.removeListener(_contractObserverListener);
    for (final contract in _contracts.values) {
      _disposeContract(contract);
    }
    _lazyPut.clear();
    _contracts.clear();
    if (_resumed) {
      _resumed = false;
      onPause();
    }
    onDispose();
    super.dispose();
  }

  void lazyPut<T extends Contract>(ContractBinderLazyPut<T> contract) {
    _lazyPut[T] = contract;
  }

  bool put<T extends Contract>(T contract) {
    if (!_contracts.containsKey(T) && !_lazyPut.containsKey(T)) {
      _contracts[T] = contract;
      if (_init) {
        _initContract(contract);
      }
    }
    return false;
  }

  T? remove<T extends Contract>() {
    final contract = _contracts.remove(T);
    if (contract is T) {
      _disposeContract(contract);
      return contract;
    }
    return null;
  }

  T? of<T extends Contract>() => _of<T>();

  T? _of<T extends ContractFragment>() {
    final contract = _contracts[T];
    if (contract is T) {
      return contract as T;
    }
    final lazyPut = _lazyPut[T];
    if (lazyPut != null) {
      final newContract = lazyPut();
      if (newContract is T) {
        _contracts[T] = newContract;
        if (_init) {
          _initContract(newContract);
        }
        return newContract as T;
      }
    }
    return null;
  }

  void _initContract(Contract contract) {
    contract._attachContract(context);
    if (_isCurrent) {
      contract._resumePage();
    }
    if (_appLifecycle) {
      contract._resumeAppLifecycle();
    }
  }

  void _disposeContract(Contract contract) {
    contract._detachContract();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _didChangeAppLifecycle(state == AppLifecycleState.resumed);
  }

  void _didChangeAppLifecycle(bool appLifeCycle) {
    if (_appLifecycle != appLifeCycle) {
      _appLifecycle = appLifeCycle;
      _didChangedLifecycle();
      for (final contract in _contracts.values) {
        if (appLifeCycle) {
          contract._resumeAppLifecycle();
        } else {
          contract._pauseAppLifecycle();
        }
      }
    }
  }

  void _contractObserverListener(Route<dynamic>? route) {
    final isCurrent = route != null
        ? route.settings == ModalRoute.of(context)?.settings
        : false;
    if (isCurrent != _isCurrent) {
      _isCurrent = isCurrent;
      _didChangedLifecycle();
      for (final contract in _contracts.values) {
        if (isCurrent) {
          contract._resumePage();
        } else {
          contract._pausePage();
        }
      }
    }
  }

  void _didChangedLifecycle() {
    final resumed = _isCurrent && _appLifecycle;
    if (_resumed != resumed) {
      _resumed = resumed;
      if (_resumed) {
        onResume();
      } else {
        onPause();
      }
    }
  }

  @override
  void update() {
    _changeNotifier.update();
  }
}

class _BinderChangeNotifier extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

class DefaultBinderContract extends BinderContract {
  final ContractPageInitBinder initBinder;

  DefaultBinderContract({required this.initBinder});

  @override
  // ignore: must_call_super
  void onInit() {
    initBinder(context, this, arguments);
  }

  @override
  // ignore: must_call_super
  void onDispose() {}

  @override
  // ignore: must_call_super
  void onResume() {}

  @override
  // ignore: must_call_super
  void onPause() {}
}

class _ContractBinderInheritedWidget extends InheritedWidget {
  final BinderContract binder;

  const _ContractBinderInheritedWidget(
      {required this.binder, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

extension _ContractLifecycleExtension on Contract {
  void _attachContract(BuildContext context) {
    if (!isAttachContract) {
      _isAttachContractContext = context;
      didChangeLifeCycle();
    }
  }

  void _detachContract() {
    if (isAttachContract) {
      _isAttachContractContext = null;
      didChangeLifeCycle();
    }
  }

  void _resumePage() {
    if (!_pageState) {
      _pageState = true;
      didChangeLifeCycle();
    }
  }

  void _pausePage() {
    if (_pageState) {
      _pageState = false;
      didChangeLifeCycle();
    }
  }

  void _resumeAppLifecycle() {
    if (!_appLifecycleState) {
      _appLifecycleState = true;
      didChangeLifeCycle();
    }
  }

  void _pauseAppLifecycle() {
    if (_appLifecycleState) {
      _appLifecycleState = false;
      didChangeLifeCycle();
    }
  }
}
