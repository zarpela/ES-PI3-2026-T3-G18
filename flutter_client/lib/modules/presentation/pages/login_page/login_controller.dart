import 'package:mobx/mobx.dart';

part 'login_controller.g.dart';

class LoginController = _LoginControllerBase with _$LoginController;

abstract class _LoginControllerBase with Store {
  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  void setEmail(String value) => email = value;

  @action
  void setPassword(String value) => password = value;

  @action
  Future<void> login() async {
    isLoading = true;
    errorMessage = null;

    // TODO: chamar AuthRepository
    await Future.delayed(const Duration(seconds: 1));

    isLoading = false;
  }
}
