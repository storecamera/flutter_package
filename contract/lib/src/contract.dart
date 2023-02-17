import 'package:contract/src/fragment.dart';
import 'package:contract/src/value.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'observer.dart';
import 'exceptions.dart';

part 'binder.dart';

part 'service.dart';

part 'widget.dart';

class Contract extends ChangeNotifier with ContractFragment {
  static BinderContract _binder(BuildContext context) {
    if (context is StatefulElement && context.state is BinderContract) {
      return context.state as BinderContract;
    } else {
      final widget = context
          .getElementForInheritedWidgetOfExactType<
              _ContractBinderInheritedWidget>()
          ?.widget;
      if (widget is _ContractBinderInheritedWidget) {
        return widget.binder;
      }
    }

    throw const ContractExceptionNotFoundBinderFromParent();
  }

  static Element? _parent(BuildContext? buildContext) {
    Element? element;
    buildContext?.visitAncestorElements((e) {
      element = e;
      return false;
    });
    return element;
  }

  static T binder<T extends BinderContract>(BuildContext context) {
    if (context is StatefulElement && context.state is T) {
      return context.state as T;
    }

    BuildContext? buildContext = context;
    while (buildContext != null) {
      final inheritedElement = context.getElementForInheritedWidgetOfExactType<
          _ContractBinderInheritedWidget>();
      buildContext = _parent(inheritedElement);
      if (inheritedElement != null) {
        final binder =
            (inheritedElement.widget as _ContractBinderInheritedWidget).binder;
        if (binder is T) {
          return binder;
        }
      }
    }

    throw ContractExceptionNotFoundBinder(T);
  }

  static T of<T extends ContractFragment>(BuildContext context) {
    if (context is StatefulElement && context.state is BinderContract) {
      final binder = context.state as BinderContract;
      if (binder is T) {
        return binder as T;
      }

      final contract = binder._of<T>();
      if (contract != null) {
        return contract;
      }
    }

    BuildContext? buildContext = context;
    while (buildContext != null) {
      InheritedElement? inheritedElement =
          buildContext.getElementForInheritedWidgetOfExactType<
              _ContractBinderInheritedWidget>();
      buildContext = _parent(inheritedElement);
      if (inheritedElement != null) {
        final binder =
            (inheritedElement.widget as _ContractBinderInheritedWidget).binder;

        if (binder is T) {
          return binder as T;
        }

        final contract = binder._of<T>();
        if (contract != null) {
          return contract;
        }
      }
    }

    final service = _Services.instance._of<T>();
    if (service != null) {
      return service;
    }

    throw ContractExceptionNotFoundContract(T);
  }

  static void lazyPut<T extends Contract>(
          BuildContext context, ContractBinderLazyPut<T> contract) =>
      _binder(context).lazyPut(contract);

  static bool put<T extends Contract>(BuildContext context, T contract) =>
      _binder(context).put(contract);

  static T? remove<T extends Contract>(BuildContext context) =>
      _binder(context).remove<T>();

  static Value<T> value<T>({T? value, Object? error}) =>
      Value<T>(value: value, error: error);

  static ValueN<T> valueN<T>({Object? error}) =>
      ValueN<T>(error: error);

  static ValueN<T> valueNInit<T>({T? value, Object? error}) =>
      ValueN<T>.value(value: value, error: error);

  bool _init = false;
  bool _disposed = false;
  bool _resumed = false;

  BuildContext? _isAttachContractContext;

  bool get isAttachContract => _isAttachContractContext != null;

  final List<BuildContext> _widgetContexts = [];

  bool get isAttachWidget => _widgetContexts.isNotEmpty;

  bool _pageState = false; // ignore: prefer_final_fields
  bool _appLifecycleState = false; // ignore: prefer_final_fields

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  void didChangeLifeCycle() {
    if (isAttachContract) {
      if (!_init) {
        _init = true;
        onInit();
      }

      final resumed = _pageState && _appLifecycleState && isAttachWidget;
      if (_resumed != resumed) {
        _resumed = resumed;
        if (_resumed) {
          onResume();
        } else {
          onPause();
        }
      }
    } else if (!isAttachWidget && !_disposed) {
      if (_resumed) {
        _resumed = false;
        onPause();
      }
      _disposed = true;
      dispose();
    }
  }

  BuildContext get context {
    if (_widgetContexts.isNotEmpty) {
      return _widgetContexts.last;
    }
    if (_isAttachContractContext != null) {
      return _isAttachContractContext!;
    }
    throw ContractExceptionContext(runtimeType);
  }

  @override
  void update() {
    notifyListeners();
  }
}
