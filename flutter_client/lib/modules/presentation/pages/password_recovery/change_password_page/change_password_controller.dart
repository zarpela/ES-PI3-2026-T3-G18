//feito por marcelo
import 'package:mobx/mobx.dart';

part 'change_password_controller.g.dart'; 

class ChangePasswordController = _ChangePasswordControllerBase with _$ChangePasswordController;

abstract class _ChangePasswordControllerBase with Store {


  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  bool obscurePassword = true;

  @observable
  bool obscureConfirmPassword = true;

  @action
  void clearForm(){
    password = '';
    confirmPassword = '';
    obscurePassword = true;
    obscureConfirmPassword = true;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void setConfirmPassword(String value) => confirmPassword = value;

  @action
  void toggleObscurePassword() => obscurePassword = !obscurePassword;

  @action
  void toggleObscureConfirmPassword() => obscureConfirmPassword = !obscureConfirmPassword;

  @computed
  bool get hasMinLength => password.length >= 8;

  @computed
  bool get hasUpperAndLower => 
      password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[a-z]'));

  @computed
  bool get hasNumberOrSymbol => 
      password.contains(RegExp(r'[0-9]')) || password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @computed
  bool get passwordsMatch => password.isNotEmpty && password == confirmPassword;

  @computed
  bool get isFormValid => hasMinLength && hasUpperAndLower && hasNumberOrSymbol && passwordsMatch;
}