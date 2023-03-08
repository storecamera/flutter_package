import 'dart:async';

import 'package:contract/src/exceptions.dart';
import 'package:contract/src/fragment.dart';
import 'package:contract/src/snapshot/snapshot.dart';
import 'package:flutter/material.dart';

typedef AsyncWorkerLoadingBuilder = Widget Function(
    BuildContext context, bool loading);
typedef AsyncWorkerErrorBuilder = void Function(BuildContext context, Object e);

mixin AsyncWorker on ContractFragment, ContractContext {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  final List<StreamSubscription<dynamic>> _subscriptionsList = [];

  final _state = Snapshot.notnull(false);
  int _workerCount = 0;

  void showLoading() {
    if (isDisposed) {
      throw ContractExceptionAsyncWorkerDisposed(runtimeType, 'showLoading');
    }
    _workerCount++;
    _updateWorkerState();
  }

  void hideLoading() {
    if (isDisposed) {
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
      {void Function(T data)? onData,
      Object? Function(Object e)? onError}) async {
    if (isDisposed) {
      throw ContractExceptionAsyncWorkerDisposed(runtimeType, 'asyncWorker');
    }

    showLoading();
    try {
      final T result = await worker();
      if (isDisposed) {
        return;
      }
      onData?.call(result);
    } catch (e) {
      if (isDisposed) {
        return;
      }
      try {
        final Object? error;
        if (onError != null) {
          error = onError(e);
        } else {
          error = e;
        }

        if (error == null) {
          return;
        }

        final context = contractContext;
        if (context == null) {
          return;
        }

        Theme.of(context)
            .extension<AsyncWorkerStyle>()
            ?.errorBuilder
            ?.call(context, error);
      } catch (_) {}
    } finally {
      if (!isDisposed) {
        hideLoading();
      }
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

typedef AsyncWorkerControllerContext = BuildContext? Function();

class AsyncWorkerController
    with ContractFragment, ContractContext, AsyncWorker {
  final AsyncWorkerControllerContext? asyncWorkerControllerContext;

  AsyncWorkerController({required this.asyncWorkerControllerContext});

  void dispose() {
    onDispose();
  }

  @override
  BuildContext? get contractContext => asyncWorkerControllerContext?.call();
}

enum _AsyncWorkerLoadingState { init, lock, loading, hiding }

class AsyncWorkerStyle extends ThemeExtension<AsyncWorkerStyle> {
  static const int defaultShowDelayMs = 100;
  static const int defaultHideDelayMs = 30;

  static Widget defaultLoadingBuilder(context, loading) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );

  const AsyncWorkerStyle(
      {this.showDelayMs,
      this.hideDelayMs,
      this.loadingBuilder,
      this.errorBuilder});

  final int? showDelayMs;
  final int? hideDelayMs;

  final AsyncWorkerLoadingBuilder? loadingBuilder;
  final AsyncWorkerErrorBuilder? errorBuilder;

  @override
  ThemeExtension<AsyncWorkerStyle> copyWith({
    int? showDelayMs,
    int? hideDelayMs,
    AsyncWorkerLoadingBuilder? loadingBuilder,
    AsyncWorkerErrorBuilder? errorBuilder,
  }) =>
      AsyncWorkerStyle(
        showDelayMs: showDelayMs ?? this.showDelayMs,
        hideDelayMs: hideDelayMs ?? this.hideDelayMs,
        loadingBuilder: loadingBuilder ?? this.loadingBuilder,
        errorBuilder: errorBuilder ?? this.errorBuilder,
      );

  @override
  ThemeExtension<AsyncWorkerStyle> lerp(
      covariant ThemeExtension<AsyncWorkerStyle>? other, double t) {
    return this;
  }
}

class AsyncWorkerWidget extends StatefulWidget {
  final AsyncWorker worker;
  final AsyncWorkerStyle? style;
  final Widget? child;

  const AsyncWorkerWidget({
    super.key,
    required this.worker,
    this.style,
    this.child,
  });

  @override
  State<AsyncWorkerWidget> createState() => _AsyncWorkerWidgetState();
}

class _AsyncWorkerWidgetState extends State<AsyncWorkerWidget> {
  late _AsyncWorkerLoadingState state;
  Object? _asyncIdentity;

  int _getShowDelayMs(BuildContext context) {
    final showDelayMs = widget.style?.showDelayMs ??
        Theme.of(context).extension<AsyncWorkerStyle>()?.showDelayMs ??
        AsyncWorkerStyle.defaultShowDelayMs;
    if (showDelayMs < 0) {
      return 0;
    }
    return showDelayMs;
  }

  int _getHideDelayMs(BuildContext context) {
    final hideDelayMs = widget.style?.hideDelayMs ??
        Theme.of(context).extension<AsyncWorkerStyle>()?.hideDelayMs ??
        AsyncWorkerStyle.defaultHideDelayMs;
    if (hideDelayMs < 0) {
      return 0;
    }
    return hideDelayMs;
  }

  AsyncWorkerLoadingBuilder _getLoadingBuilder(BuildContext context) =>
      widget.style?.loadingBuilder ??
      Theme.of(context).extension<AsyncWorkerStyle>()?.loadingBuilder ??
      AsyncWorkerStyle.defaultLoadingBuilder;

  @override
  void initState() {
    super.initState();

    if (widget.worker._state.value) {
      state = _AsyncWorkerLoadingState.loading;
    } else {
      state = _AsyncWorkerLoadingState.init;
    }
    widget.worker._state.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.worker._state.removeListener(_updateState);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AsyncWorkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.worker != oldWidget.worker) {
      oldWidget.worker._state.removeListener(_updateState);
      widget.worker._state.addListener(_updateState);
      _updateState();
    }
  }

  void _updateState() {
    if (!mounted) {
      return;
    }

    final state = widget.worker._state.value;
    if (state) {
      switch (this.state) {
        case _AsyncWorkerLoadingState.init:
          final showDelayMs = _getShowDelayMs(context);
          if (showDelayMs > 0) {
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
            if (mounted) {
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
      switch (this.state) {
        case _AsyncWorkerLoadingState.init:
          break;
        case _AsyncWorkerLoadingState.lock:
          this.state = _AsyncWorkerLoadingState.init;
          _asyncIdentity = null;
          break;
        case _AsyncWorkerLoadingState.loading:
          final hideDelayMs = _getHideDelayMs(context);
          if (hideDelayMs > 0) {
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
            if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    return Stack(
      children: [
        if (child != null) child,
        _buildState(context),
      ],
    );
  }

  Widget _buildState(BuildContext context) {
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
            child: _getLoadingBuilder(context)(context, true));
      case _AsyncWorkerLoadingState.hiding:
        return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0x00000000),
            child: _getLoadingBuilder(context)(context, false));
    }
  }
}
