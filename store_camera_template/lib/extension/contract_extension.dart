import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:contract/contract.dart';
import 'package:store_camera_template/exception/exceptions.dart';
import 'package:store_camera_template/log.dart';
import 'package:store_camera_widget/toast/toast_material.dart';

Future<void> Function(BuildContext context, Object error)
    defaultContractSubscriptionError = (context, _) async {
  final String message;
  if (_ is StoreCameraException) {
    message = _.message;
  } else {
    message = _.toString();
  }
  showToast(context, message: message);
};

mixin ContractSubscription on Contract {
  final _compositeSubscription = CompositeSubscription();
  final _contractLoadingController = ContractLoadingController();

  @override
  void dispose() {
    _compositeSubscription.dispose();
    _contractLoadingController.dispose();
    super.dispose();
  }

  StreamSubscription<T> subscription<T>(
    Stream<T> stream, {
    void Function(T data)? onData,
    void Function()? onDone,
    void Function(Object error)? onError,
    bool? cancelOnError,
  }) {
    return _compositeSubscription.add(
      stream.listen(onData, onError: ([error, stackTrace]) {
        onError?.call(error);
      }, onDone: () {
        onDone?.call();
      }, cancelOnError: cancelOnError),
    );
  }

  StreamSubscription<T> subscriptionWithLoading<T>({
    required Stream<T> stream,
    void Function(T data)? onData,
    void Function()? onDone,
    Object? Function(Object exception)? onError,
    void Function()? onShowLoading,
    void Function()? onHideLoading,
  }) {
    final void Function() showLoading = onShowLoading ?? showAppLoading;
    final void Function() hideLoading = onHideLoading ?? hideAppLoading;

    return _compositeSubscription.add(
      stream.doOnListen(() {
        showLoading.call();
      }).listen(onData, onError: ([error, stackTrace]) {
        log.i('subscriptionWithLoading onError : ${error.toString()}');
        hideLoading.call();
        final onErrorFunction = onError;
        if (onErrorFunction != null) {
          final result = onErrorFunction(error);
          if (result != null) {
            defaultContractSubscriptionError(context, result);
          }
          return;
        }

        defaultContractSubscriptionError(context, error);
      }, onDone: () {
        hideLoading.call();
        onDone?.call();
      }, cancelOnError: true),
    );
  }

  // Future<void> showErrorPopup(Object error) async {
  //   final context = Contract.of(context);
  //   if (context != null) {
  //     if (error is DioError) {
  //       if(kReleaseMode) {
  //         return await R.dialog.showTextDialog(
  //             context: context,
  //             title: '네트워크 에러가 발생했습니다',
  //             body: '잠시 후 다시 시도해 주세요',
  //             buttons: [
  //               AppDialogTextButtonPositive(
  //                 text: '확인',
  //               )
  //             ]);
  //       } else {
  //         return await R.dialog.showTextDialog(
  //             context: context,
  //             title: error.response?.statusCode?.toString(),
  //             body: error.response?.data['message']?.toString() ??
  //                 error.response?.statusMessage,
  //             buttons: [
  //               AppDialogTextButtonPositive(
  //                 text: '확인',
  //               )
  //             ]);
  //       }
  //     } else if (error is CBException) {
  //       return await R.dialog.showTextDialog(
  //           context: context,
  //           title: error.title,
  //           body: error.body,
  //           buttons: [
  //             AppDialogTextButtonPositive(
  //               text: '확인',
  //             )
  //           ]);
  //     } else if (error is CBExceptionType2) {
  //       return await R.dialog.showTextLine2Dialog(
  //           context: context,
  //           title: error.title,
  //           body: error.body,
  //           buttons: [
  //             AppDialogTextButtonPositive(
  //               text: '확인',
  //             )
  //           ]);
  //     } else {
  //       return await R.dialog.showTextDialog(
  //           context: context,
  //           title: '알수없는 에러가 발생했습니다',
  //           buttons: [
  //             AppDialogTextButtonPositive(
  //               text: '확인',
  //             )
  //           ]);
  //     }
  //   }
  //   return null;
  // }

  ContractLoadingController get loadingController => _contractLoadingController;

  void showAppLoading() => _contractLoadingController.showContractLoading();

  void hideAppLoading() => _contractLoadingController.hideContractLoading();
}
