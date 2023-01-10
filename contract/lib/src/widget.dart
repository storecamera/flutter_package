part of 'contract.dart';

abstract class ContractWidget<T extends ContractFragment>
    extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ContractWidget({super.key});

  late final T contract;

  Widget build(BuildContext context);

  @override
  State<ContractWidget<T>> createState() => _ContractWidgetState<T>();
}

class _ContractWidgetState<T extends ContractFragment> extends State<ContractWidget<T>> {

  @override
  void initState() {
    super.initState();
    try {
      widget.contract = Contract.of<T>(context);
    } catch (_) {}
    _initContract(widget.contract);
  }

  @override
  void dispose() {
    _disposeContract(widget.contract);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ContractWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.contract = oldWidget.contract;
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }

  void _initContract(T contract) {
    if (contract is BinderContract) {
      contract._changeNotifier.addListener(_markNeedsBuild);
    } else if (contract is Contract) {
      contract.addListener(_markNeedsBuild);
      contract._attachView(context);
    } else if (contract is Service) {
      contract.addListener(_markNeedsBuild);
    }
  }

  void _disposeContract(T contract) {
    if (contract is BinderContract) {
      contract._changeNotifier.removeListener(_markNeedsBuild);
    } else if (contract is Contract) {
      contract.removeListener(_markNeedsBuild);
      contract._detachView(context);
    } else if (contract is Service) {
      contract.removeListener(_markNeedsBuild);
    }
  }

  void _markNeedsBuild() {
    setState(() {});
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