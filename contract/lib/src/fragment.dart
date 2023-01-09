import 'package:contract/src/log.dart';
import 'package:flutter/foundation.dart';

mixin ContractFragment {
  @protected
  @mustCallSuper
  void onInit() {
    Log.i('[Contract:onInit] $runtimeType');
  }

  @protected
  @mustCallSuper
  void onDispose() {
    Log.i('[Contract:onDispose] $runtimeType');
  }

  @protected
  @mustCallSuper
  void onResume() {
    Log.i('[Contract:onResume] $runtimeType');
  }

  @protected
  @mustCallSuper
  void onPause() {
    Log.i('[Contract:onPause] $runtimeType');
  }

  void update();
}