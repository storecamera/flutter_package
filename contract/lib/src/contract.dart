import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'contract_observer.dart';
import 'exceptions.dart';

part 'contract_binder.dart';
part 'contract_view.dart';

class Contract extends ChangeNotifier {

  static ContractBinder binder(BuildContext context) {
    ContractBinder? binder;
    if (context is StatefulElement && context.state is ContractBinder) {
      binder = context.state as ContractBinder;
    } else {
      binder = context.dependOnInheritedWidgetOfExactType<_ContractBinderInheritedWidget>()?.binder;
    }
    if (binder != null) {
      return binder;
    }

    throw ContractExceptions.notFoundContractBinder.exception;
  }

  static T of<T extends Contract>(BuildContext context) {
    final contract = binder(context).of<T>();
    if (contract is T) {
      return contract;
    }
    throw ContractExceptions.notFoundContract.exception;
  }

  static void lazyPut<T extends Contract>(
          BuildContext context, ContractBinderLazyPut<T> contract) =>
      binder(context).lazyPut(contract);

  static bool put<T extends Contract>(BuildContext context, T contract) =>
      binder(context).put(contract);

  static T? remove<T extends Contract>(BuildContext context) =>
      binder(context).remove<T>();

  bool _init = false;
  bool _disposed = false;
  bool _resumed = false;

  bool _isAttachContract = false; // ignore: prefer_final_fields
  bool get isAttachContract => _isAttachContract;

  int _attachViewCount = 0; // ignore: prefer_final_fields
  bool get isAttachView => _attachViewCount > 0;

  bool _pageState = false; // ignore: prefer_final_fields
  bool _appLifecycleState = false; // ignore: prefer_final_fields

  @protected
  @mustCallSuper
  void init() {}

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
  }

  void resumeLifeCycle() {}

  void pauseLifeCycle() {}

  @mustCallSuper
  void didChangeLifeCycle() {
    if(isAttachContract) {
      if(!_init) {
        _init = true;
        init();
      }

      final resumed = _pageState && _appLifecycleState && isAttachView;
      if(_resumed != resumed) {
        _resumed = resumed;
        if(_resumed) {
          resumeLifeCycle();
        } else {
          pauseLifeCycle();
        }
      }
    } else if(!isAttachView && !_disposed) {
      if(_resumed) {
        _resumed = false;
        pauseLifeCycle();
      }
      _disposed = true;
      dispose();
    }
  }

  BuildContext Function()? _context;

  BuildContext get context {
    final context = _context?.call();
    if (context != null) {
      return context;
    }
    throw ContractExceptions.notFoundContractContext.exception;
  }
}