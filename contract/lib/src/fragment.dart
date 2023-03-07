import 'package:contract/log.dart';

mixin ContractFragment {

  void onInit() {
    Log.i('[Contract:onInit] $runtimeType');
  }

  void onDispose() {
    Log.i('[Contract:onDispose] $runtimeType');
  }

  void onResume() {
    Log.i('[Contract:onResume] $runtimeType');
  }

  void onPause() {
    Log.i('[Contract:onPause] $runtimeType');
  }

  void update();
}