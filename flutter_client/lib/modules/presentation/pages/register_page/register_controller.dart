// feito por marcelo
import 'package:mobx/mobx.dart';

part 'register_controller.g.dart';

class RegisterController = _RegisterControllerBase with _$RegisterController;

abstract class _RegisterControllerBase with Store {

  @observable
  String fullName = '';

  @observable
  String phone = '';

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  String document = ''; 

  @observable
  bool obscurePassword = true;

  @action
  void setFullName(String value) => fullName = value;

  @action
  void setPhone(String value) => phone = value;

  @action
  void setEmail(String value) => email = value;

  @action
  void setPassword(String value) => password = value;

  @action
  void setDocument(String value) => document = value;

  @action
  void toggleObscurePassword() => obscurePassword = !obscurePassword;

  @computed
  bool get hasMinLength => password.length >= 8;

  @computed
  bool get hasUpperAndLower => 
      password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[a-z]'));

  @computed
  bool get hasNumberOrSymbol => 
      password.contains(RegExp(r'[0-9]')) || password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @computed
  bool get isFormValid => 
      fullName.isNotEmpty && 
      phone.isNotEmpty && 
      email.isNotEmpty && 
      document.isNotEmpty && 
      hasMinLength && 
      hasUpperAndLower && 
      hasNumberOrSymbol;
}