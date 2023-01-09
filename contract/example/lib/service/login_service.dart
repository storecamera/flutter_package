import 'package:contract/contract.dart';

class LoginService extends Service {
  static LoginService get instance => Service.of<LoginService>();

  bool _isLogin = false;

  bool get isLogin => _isLogin;

  set isLogin(bool value) {
    if (_isLogin != value) {
      _isLogin = value;
      update();
    }
  }
}
