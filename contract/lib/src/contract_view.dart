part of 'contract.dart';

abstract class ContractView<T extends Contract> extends StatelessWidget {
  ContractView(BuildContext context, {super.key})
      : contract = Contract.of<T>(context);

  final T contract;

  @override
  StatelessElement createElement() => _ContractElement(this);
}

class _ContractElement extends StatelessElement with _ContractView {
  _ContractElement(ContractView widget) : super(widget);

  @override
  ContractView get widget => super.widget as ContractView;

  @override
  void mount(Element? parent, Object? newSlot) {
    initContract(widget.contract, markNeedsBuild);
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    disposeContract(widget.contract, markNeedsBuild);
    super.unmount();
  }
}

class ContractBuilder<T extends Contract> extends StatefulWidget {
  const ContractBuilder({Key? key, required this.builder, this.notFoundBuilder})
      : super(key: key);

  final Widget Function(BuildContext context, T contract) builder;
  final Widget Function(BuildContext context)? notFoundBuilder;

  @override
  State<ContractBuilder<T>> createState() => _ContractBuilderState<T>();
}

class _ContractBuilderState<T extends Contract>
    extends State<ContractBuilder<T>> with _ContractView {
  T? _contract;

  @override
  void initState() {
    super.initState();

    try {
      final contract = Contract.of<T>(context);
      initContract(contract, _setState);
      _contract = contract;
    } catch (_) {}
  }

  @override
  void dispose() {
    final contract = _contract;
    if (contract != null) {
      disposeContract(contract, _setState);
    }
    _contract = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contract = _contract;
    if (contract != null) {
      return widget.builder(context, contract);
    } else if (widget.notFoundBuilder != null) {
      return widget.notFoundBuilder!(context);
    }
    throw ContractExceptions.notFoundContractAtBuilder.exception;
  }

  void _setState() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant ContractBuilder<T> oldWidget) {
    if (_contract == null) {
      try {
        final contract = Contract.of<T>(context);
        initContract(contract, _setState);
        setState(() {
          _contract = contract;
        });
      } catch (_) {}
    }

    super.didUpdateWidget(oldWidget);
  }
}

mixin _ContractView {
  void initContract(Contract contract, VoidCallback markNeedsBuild) {
    contract.addListener(markNeedsBuild);
    contract._attachView();
  }

  void disposeContract(Contract contract, VoidCallback markNeedsBuild) {
    contract.removeListener(markNeedsBuild);
    contract._detachView();
  }
}

extension _ContractViewExtension on Contract {
  void _attachView() {
    final isAttachView = this.isAttachView;
    _attachViewCount++;
    if (isAttachView != this.isAttachView) {
      didChangeLifeCycle();
    }
  }

  void _detachView() {
    final isAttachView = this.isAttachView;
    _attachViewCount--;
    if (isAttachView != this.isAttachView) {
      didChangeLifeCycle();
    }
  }
}
