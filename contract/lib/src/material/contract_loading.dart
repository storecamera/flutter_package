import 'package:contract/src/value.dart';
import 'package:flutter/material.dart';

typedef ContractLoadingBuilder = Widget Function(
    BuildContext context, bool loading);

class ContractLoadingTheme {
  static final ContractLoadingTheme instance = ContractLoadingTheme._();

  factory ContractLoadingTheme() => instance;

  ContractLoadingTheme._();

  int loadingShowDelayMs = 100;
  int loadingHideDelayMs = 30;

  ContractLoadingBuilder builder = (context, loading) => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}

enum _LoadingState { init, lock, loading, hiding }

class ContractLoadingController {

  final _loadingValue = Value(value: _LoadingState.init);

  int _loadingCount = 0;

  final int _loadingShowDelayMs;

  final int _loadingHideDelayMs;

  ContractLoadingController({int? showDelayMs, int? hideDelayMs})
      : _loadingShowDelayMs =
            showDelayMs ?? ContractLoadingTheme.instance.loadingShowDelayMs,
        _loadingHideDelayMs =
            hideDelayMs ?? ContractLoadingTheme.instance.loadingHideDelayMs;

  void showContractLoading() {
    final state = _loadingValue.value;
    switch (state) {
      case _LoadingState.init:
        _loadingCount = 1;
        if (_loadingShowDelayMs > 0) {
          _loadingValue.value = _LoadingState.lock;
          Future.delayed(Duration(milliseconds: _loadingShowDelayMs))
              .then((data) async {
            if (!_loadingValue.isDisposed &&
                _loadingValue.value == _LoadingState.lock) {
              _loadingValue.value = _LoadingState.loading;
            }
          });
        }
        break;
      case _LoadingState.lock:
        _loadingCount++;
        break;
      case _LoadingState.loading:
        _loadingCount++;
        break;
      case _LoadingState.hiding:
        _loadingCount++;
        if (_loadingCount > 0) {
          _loadingValue.value = _LoadingState.loading;
        }
        break;
    }
  }

  void hideContractLoading() {
    final state = _loadingValue.value;
    switch (state) {
      case _LoadingState.init:
        _loadingCount = 0;
        break;
      case _LoadingState.lock:
        _loadingCount--;
        if (_loadingCount <= 0) {
          _loadingCount = 0;
          _loadingValue.value = _LoadingState.init;
        }
        break;
      case _LoadingState.loading:
        _loadingCount--;
        if (_loadingCount <= 0) {
          _loadingCount = 0;
          if (_loadingHideDelayMs > 0) {
            _loadingValue.value = _LoadingState.hiding;
            Future.delayed(Duration(milliseconds: _loadingHideDelayMs))
                .then((data) {
              if (!_loadingValue.isDisposed && _loadingCount <= 0) {
                _loadingValue.value = _LoadingState.init;
              }
            });
          } else {
            _loadingValue.value = _LoadingState.init;
          }
        }
        break;
      case _LoadingState.hiding:
        _loadingCount--;
        break;
    }
  }

  void dispose() {
    _loadingValue.dispose();
  }
}

class ContractLoading extends StatelessWidget {
  final ContractLoadingController controller;
  final ContractLoadingBuilder? loadingBuilder;
  final Widget? child;

  const ContractLoading({
    Key? key,
    required this.controller,
    this.loadingBuilder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          if (child != null) child!,
          controller._loadingValue.builder(valueBuilder: (context, value) {
            switch (value) {
              case _LoadingState.init:
                return Container();
              case _LoadingState.lock:
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0x00000000),
                );
              case _LoadingState.loading:
              case _LoadingState.hiding:
                return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0x00000000),
                    child: (loadingBuilder ??
                            ContractLoadingTheme.instance.builder)
                        .call(context, value == _LoadingState.loading));
            }
          }),
        ],
      );
}
