import 'dart:async';

import 'package:contract/src/exceptions.dart';
import 'package:contract/src/fragment.dart';
import 'package:contract/src/value.dart';
import 'package:flutter/material.dart';

typedef AsyncWorkerError = void Function(BuildContext context, Object e);
typedef AsyncWorkerWidgetBuilder = Widget Function(
    BuildContext context, bool loading);

mixin AsyncWorker on ContractFragment {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  final List<StreamSubscription<dynamic>> _subscriptionsList = [];

  final _state = Value(value: false);
  int _workerCount = 0;

  final List<BuildContext Function()> _widgetContexts = [];

  void showLoading() {
    if(isDisposed) {
      throw ContractExceptionAsyncWorkerDisposed(runtimeType, 'showLoading');
    }
    _workerCount++;
    _updateWorkerState();
  }

  void hideLoading() {
    if(isDisposed) {
      throw ContractExceptionAsyncWorkerDisposed(runtimeType, 'hideLoading');
    }
    _workerCount--;
    _updateWorkerState();
  }

  void _updateWorkerState() {
    final state = _workerCount > 0;
    if (_state.value != state) {
      _state.value = state;
    }
  }

  @override
  void onDispose() {
    _isDisposed = true;
    for (var element in _subscriptionsList) {
      element.cancel();
    }
    _state.dispose();
    super.onDispose();
  }

  void asyncWorker<T>(Future<T> Function() worker,
      {void Function(T data)? onData, Object? Function(Object e)? onError}) async {
    if(isDisposed) {
      throw ContractExceptionAsyncWorkerDisposed(runtimeType, 'asyncWorker');
    }

    showLoading();
    try {
      final T result = await worker();
      onData?.call(result);
    } catch (e) {
      final Object? error;
      if(onError != null) {
        error = onError(e);
      } else {
        error = e;
      }

      if (error != null) {
        final errorFunc = AsyncWorkerTheme.instance.error;
        if (errorFunc != null) {
          final context =
              _widgetContexts.isNotEmpty ? _widgetContexts.last() : null;
          if (context != null) {
            errorFunc(context, error);
          }
        }
      }
    } finally {
      hideLoading();
    }
  }

  StreamSubscription<T> subscription<T>(
    Stream<T> stream, {
    void Function(T data)? onData,
    void Function()? onDone,
    void Function(Object error)? onError,
    bool? cancelOnError,
  }) {
    if (isDisposed) {
      throw ContractExceptionAsyncWorkerDisposed(runtimeType, 'subscription');
    }
    final subscription = stream.listen(onData, onError: ([error, stackTrace]) {
      onError?.call(error);
    }, onDone: () {
      onDone?.call();
    }, cancelOnError: cancelOnError);
    _subscriptionsList.add(subscription);
    return subscription;
  }
}

enum _AsyncWorkerLoadingState { init, lock, loading, hiding }

class AsyncWorkerTheme {
  static final AsyncWorkerTheme instance = AsyncWorkerTheme._();

  factory AsyncWorkerTheme() => instance;

  AsyncWorkerTheme._();

  int showDelayMs = 100;
  int hideDelayMs = 30;

  AsyncWorkerWidgetBuilder builder = (context, loading) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );

  AsyncWorkerError? error;
}

class AsyncWorkerWidget extends StatefulWidget {
  final AsyncWorker worker;
  final int? showDelayMs;
  final int? hideDelayMs;
  final AsyncWorkerWidgetBuilder? builder;
  final Widget? child;

  const AsyncWorkerWidget({
    super.key,
    required this.worker,
    this.showDelayMs,
    this.hideDelayMs,
    this.builder,
    this.child,
  });

  @override
  State<AsyncWorkerWidget> createState() => _AsyncWorkerWidgetState();
}

class _AsyncWorkerWidgetState extends State<AsyncWorkerWidget> {

  late _AsyncWorkerLoadingState state;
  Object? _asyncIdentity;

  int get showDelayMs {
    final showDelayMs = widget.showDelayMs ?? AsyncWorkerTheme.instance.showDelayMs;
    if(showDelayMs < 0) {
      return 0;
    }
    return showDelayMs;
  }

  int get hideDelayMs {
    final hideDelayMs = widget.hideDelayMs ?? AsyncWorkerTheme.instance.hideDelayMs;
    if(hideDelayMs < 0) {
      return 0;
    }
    return hideDelayMs;
  }

  @override
  void initState() {
    super.initState();

    final state = widget.worker._state.value;
    if(state) {
      if(showDelayMs > 0) {
        this.state = _AsyncWorkerLoadingState.lock;
        final Object asyncIdentity = Object();
        _asyncIdentity = asyncIdentity;
        Future.delayed(Duration(milliseconds: showDelayMs))
            .then((data) async {
          if (mounted && _asyncIdentity == asyncIdentity) {
            setState(() {
              this.state = _AsyncWorkerLoadingState.loading;
            });
          }
        });
      } else {
        this.state = _AsyncWorkerLoadingState.loading;
      }
    } else {
      this.state = _AsyncWorkerLoadingState.init;
    }
    widget.worker._widgetContexts.add(_getContext);
    widget.worker._state.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.worker._widgetContexts.remove(_getContext);
    widget.worker._state.removeListener(_updateState);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AsyncWorkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(widget.worker != oldWidget.worker) {
      oldWidget.worker._widgetContexts.remove(_getContext);
      oldWidget.worker._state.removeListener(_updateState);
      widget.worker._widgetContexts.add(_getContext);
      widget.worker._state.addListener(_updateState);
      _updateState();
    }
  }

  void _updateState() {
    final state = widget.worker._state.value;
    if(state) {
      switch(this.state) {
        case _AsyncWorkerLoadingState.init:
          if(showDelayMs > 0) {
            this.state = _AsyncWorkerLoadingState.lock;
            final Object asyncIdentity = Object();
            _asyncIdentity = asyncIdentity;
            Future.delayed(Duration(milliseconds: showDelayMs))
                .then((data) async {
              if (mounted && _asyncIdentity == asyncIdentity) {
                setState(() {
                  this.state = _AsyncWorkerLoadingState.loading;
                });
              }
            });
          } else {
            if(mounted) {
              setState(() {
                this.state = _AsyncWorkerLoadingState.loading;
              });
            }
          }
          break;
        case _AsyncWorkerLoadingState.lock:
        case _AsyncWorkerLoadingState.loading:
          break;
        case _AsyncWorkerLoadingState.hiding:
          this.state = _AsyncWorkerLoadingState.loading;
          _asyncIdentity = null;
          break;
      }
    } else {
      switch(this.state) {
        case _AsyncWorkerLoadingState.init:
          break;
        case _AsyncWorkerLoadingState.lock:
          this.state = _AsyncWorkerLoadingState.init;
          _asyncIdentity = null;
          break;
        case _AsyncWorkerLoadingState.loading:
          if(hideDelayMs > 0) {
            this.state = _AsyncWorkerLoadingState.hiding;
            final Object asyncIdentity = Object();
            _asyncIdentity = asyncIdentity;
            Future.delayed(Duration(milliseconds: hideDelayMs))
                .then((data) async {
              if (mounted && _asyncIdentity == asyncIdentity) {
                setState(() {
                  this.state = _AsyncWorkerLoadingState.init;
                });
              }
            });
          } else {
            if(mounted) {
              setState(() {
                this.state = _AsyncWorkerLoadingState.init;
              });
            }
          }
          break;
        case _AsyncWorkerLoadingState.hiding:
          break;
      }
    }
  }

  BuildContext _getContext() => context;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    return Stack(
      children: [
        if (child != null) child,
        _buildState(),
      ],
    );
  }

  Widget _buildState() {
    switch (state) {
      case _AsyncWorkerLoadingState.init:
        return const SizedBox();
      case _AsyncWorkerLoadingState.lock:
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0x00000000),
        );
      case _AsyncWorkerLoadingState.loading:
        return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0x00000000),
            child: (widget.builder ?? AsyncWorkerTheme.instance.builder)
                .call(context, true));
      case _AsyncWorkerLoadingState.hiding:
        return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0x00000000),
            child: (widget.builder ?? AsyncWorkerTheme.instance.builder)
                .call(context, false));
    }
  }
}
