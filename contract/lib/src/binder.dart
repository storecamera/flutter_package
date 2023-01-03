part of 'contract.dart';

typedef ContractBinderLazyPut<T extends Contract> = T Function();

abstract class ContractPage extends StatefulWidget {
  final dynamic arguments;

  const ContractPage({Key? key, this.arguments}) : super(key: key);

  @protected
  @factory
  PageBinder createBinder();

  Widget build(BuildContext context);

  @override
  State<StatefulWidget> createState() =>
      createBinder(); // ignore: no_logic_in_create_state
}

typedef ContractPageBinder = void Function(BuildContext context, PageBinder binder, dynamic arguments);

class ContractPageBuilder extends ContractPage {
  final ContractPageBinder binder;
  final WidgetBuilder builder;

  const ContractPageBuilder(
      {super.key,
      super.arguments,
      required this.binder,
      required this.builder});

  @override
  Widget build(BuildContext context) => builder(context);

  @override
  DefaultPageBinder createBinder() => DefaultPageBinder(initBinder: binder);
}

abstract class PageBinder extends State<ContractPage> with Fragment, WidgetsBindingObserver {

  final Map<Type, ContractBinderLazyPut> _lazyPut = {};
  final Map<Type, Contract> _contracts = {};

  bool _init = false;
  bool _initPageState = false;
  bool _isCurrent = false;
  bool _appLifecycle = false;
  bool _resumed = false;

  dynamic get arguments => widget.arguments;

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
  void dispose() {
    onDispose();

    WidgetsBinding.instance.removeObserver(this);
    ContractObserver.instance.removeListener(_contractObserverListener);
    for (final contract in _contracts.values) {
      _disposeContract(contract);
    }
    _lazyPut.clear();
    _contracts.clear();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) {
      if (!_initPageState) {
        _initPageState = true;
        for (final contract in _contracts.values) {
          contract._attachContract();
        }
        _didChangeAppLifecycle(WidgetsBinding.instance.lifecycleState ==
            AppLifecycleState.resumed);
        WidgetsBinding.instance.addObserver(this);

        _contractObserverListener(ModalRoute.of(context));
        ContractObserver.instance.addListener(_contractObserverListener);
      }
    } else {
      Navigator.pop(context);
    }
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

  T? _of<T extends Fragment>() {
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
    contract._attachContract();
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
    if(_resumed != resumed) {
      _resumed = resumed;
      if(_resumed) {
        onResume();
      } else {
        onPause();
      }
    }
  }

  @override
  void update() {
    setState(() {});
  }
}

class DefaultPageBinder extends PageBinder {
  final ContractPageBinder initBinder;

  DefaultPageBinder({required this.initBinder});

  @override
  void onInit() {
    super.onInit();
    initBinder(context, this, arguments);
  }
}

class _ContractBinderInheritedWidget extends InheritedWidget {
  final PageBinder binder;

  const _ContractBinderInheritedWidget(
      {required this.binder, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

extension _ContractFragmentLifecycleExtension on Contract {
  void _attachContract() {
    if (!_isAttachContract) {
      _isAttachContract = true;
      didChangeLifeCycle();
    }
  }

  void _detachContract() {
    if (_isAttachContract) {
      _isAttachContract = false;
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