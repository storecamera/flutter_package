part of 'contract.dart';

abstract class ContractWidget<T extends Fragment>
    extends StatelessWidget {
  late final T contract;

  // ignore: prefer_const_constructors_in_immutables
  ContractWidget({super.key});

  @override
  StatelessElement createElement() => _ContractElement<T>(this);
}

class _ContractElement<T extends Fragment> extends StatelessElement {
  _ContractElement(ContractWidget<T> widget) : super(widget);

  @override
  ContractWidget<T> get widget => super.widget as ContractWidget<T>;

  @override
  void mount(Element? parent, Object? newSlot) {
    if (parent != null) {
      try {
        widget.contract = Contract.of<T>(parent);
      } catch(_) {}
      _initContract(widget.contract);
    }
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    _disposeContract(widget.contract);
    super.unmount();
  }

  @override
  void update(covariant StatelessWidget newWidget) {
    (newWidget as ContractWidget<T>).contract = widget.contract;
    super.update(newWidget);
  }

  void _initContract(T contract) {
    if (contract is Contract) {
      contract.addListener(markNeedsBuild);
      contract._attachView(this);
    } else if (contract is Service) {
      contract.addListener(markNeedsBuild);
    }
  }

  void _disposeContract(T contract) {
    if (contract is Contract) {
      contract.removeListener(markNeedsBuild);
      contract._detachView(this);
    } else if (contract is Service) {
      contract.removeListener(markNeedsBuild);
    }
  }
}

class ContractBuilder<T extends Contract> extends ContractWidget<T> {
  ContractBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, T contract) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, contract);
  }
}

extension _ContractFragmentViewExtension on Contract{
  void _attachView(BuildContext context) {
    final isAttachWidget = this.isAttachWidget;
    _widgetContexts.add(context);
    if (isAttachWidget != this.isAttachWidget) {
      didChangeLifeCycle();
    }
  }

  void _detachView(BuildContext context) {
    final isAttachWidget = this.isAttachWidget;
    _widgetContexts.remove(context);
    if (isAttachWidget != this.isAttachWidget) {
      didChangeLifeCycle();
    }
  }
}