part of 'contract.dart';

typedef ContractBinderLazyPut<T extends Contract> = T Function();

abstract class ContractBinder {

  void lazyPut<T extends Contract>(ContractBinderLazyPut<T> contract);

  bool put<T extends Contract>(T contract);

  T? remove<T extends Contract>();

  T? of<T extends Contract>();
}

abstract class ContractPage<T> extends StatefulWidget {
  final T? arguments;

  const ContractPage({Key? key, this.arguments}) : super(key: key);

  bool binding(BuildContext context, ContractBinder binder, T? arguments);

  Widget build(BuildContext context);

  @override
  State<ContractPage<T>> createState() => _ContractBinder<T>();
}

class ContractPageBuilder<T> extends ContractPage<T> {
  final bool Function(BuildContext context, ContractBinder binder, T? arguments)? binder;
  final WidgetBuilder builder;

  const ContractPageBuilder(
      {Key? key, required this.binder, required this.builder, T? arguments})
      : super(key: key, arguments: arguments);

  @override
  bool binding(BuildContext context, ContractBinder binder, T? arguments) =>
      this.binder?.call(context, binder, arguments) ?? true;

  @override
  Widget build(BuildContext context) => builder(context);

}

class _ContractBinder<A> extends State<ContractPage<A>>
    with WidgetsBindingObserver
    implements ContractBinder {

  final Map<Type, ContractBinderLazyPut> _lazyPut = {};
  final Map<Type, Contract> _contracts = {};

  bool _init = false;
  bool _initPageState = false;
  bool _isCurrent = false;
  bool _appLifecycle = false;

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
      final result = widget.binding.call(context, this, widget.arguments);
      if (result == false) {
        return;
      }
    } catch (_) {
      if (kDebugMode) {
        print('_ContractBinderWidgetState initState e : $_');
      }
      return;
    }

    for(final contract in _contracts.values) {
      contract._context = () => context;
      contract._attachContract();
    }
    _didChangeAppLifecycle(WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed);
    WidgetsBinding.instance.addObserver(this);

    _init = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ContractObserver.instance.removeListener(_contractObserverListener);
    for(final contract in _contracts.values) {
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
      if(!_initPageState) {
        _initPageState = true;
        _contractObserverListener(ModalRoute.of(context));
        ContractObserver.instance.addListener(_contractObserverListener);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void lazyPut<T extends Contract>(ContractBinderLazyPut<T> contract) {
    _lazyPut[T] = contract;
  }

  @override
  bool put<T extends Contract>(T contract) {
    if(!_contracts.containsKey(T) && !_lazyPut.containsKey(T)) {
      _contracts[T] = contract;
      if(_init) {
        _initContract(contract);
      }
    }
    return false;
  }

  @override
  T? remove<T extends Contract>() {
    final contract = _contracts.remove(T);
    if(contract is T) {
      _disposeContract(contract);
      return contract;
    }
    return null;
  }

  @override
  T? of<T extends Contract>() {
    final contract = _contracts[T];
    if(contract is T) {
      return contract;
    }
    final lazyPut = _lazyPut[T];
    if(lazyPut != null) {
      final newContract = lazyPut();
      if(newContract is T) {
        _contracts[T] = newContract;
        if(_init) {
          _initContract(newContract);
        }
        return newContract;
      }
    }
    return null;
  }

  void _initContract(Contract contract) {
    contract._context = () => context;
    contract._attachContract();
    if(_isCurrent) {
      contract._resumePage();
    }
    if(_appLifecycle) {
      contract._resumeAppLifecycle();
    }
  }

  void _disposeContract(Contract contract) {
    contract._detachContract();
    contract._context = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _didChangeAppLifecycle(state == AppLifecycleState.resumed);
  }

  void _didChangeAppLifecycle(bool appLifeCycle) {
    if(_appLifecycle != appLifeCycle) {
      _appLifecycle = appLifeCycle;
      for(final contract in _contracts.values) {
        if(appLifeCycle) {
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
      for (final contract in _contracts.values) {
        if (isCurrent) {
          contract._resumePage();
        } else {
          contract._pausePage();
        }
      }
    }
  }
}

class _ContractBinderInheritedWidget extends InheritedWidget {
  final ContractBinder binder;

  const _ContractBinderInheritedWidget(
      {required this.binder, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

extension _ContractLifecycleExtension on Contract {
  void _attachContract() {
    if(!_isAttachContract) {
      _isAttachContract = true;
      didChangeLifeCycle();
    }
  }

  void _detachContract() {
    if(_isAttachContract) {
      _isAttachContract = false;
      didChangeLifeCycle();
    }
  }

  void _resumePage() {
    if(!_pageState) {
      _pageState = true;
      didChangeLifeCycle();
    }
  }

  void _pausePage() {
    if(_pageState) {
      _pageState = false;
      didChangeLifeCycle();
    }
  }

  void _resumeAppLifecycle() {
    if(!_appLifecycleState) {
      _appLifecycleState = true;
      didChangeLifeCycle();
    }
  }

  void _pauseAppLifecycle() {
    if(_appLifecycleState) {
      _appLifecycleState = false;
      didChangeLifeCycle();
    }
  }
}