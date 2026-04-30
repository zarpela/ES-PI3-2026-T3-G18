//feito por marcelo
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  final FirebaseAuth? _auth;

  LoginControllerBase([FirebaseAuth? auth]) : _auth = auth;

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool obscurePassword = true;

  @action
  void setEmail(String value) => email = value;

  @action
  void setPassword(String value) => password = value;

  @action
  void toggleObscurePassword() => obscurePassword = !obscurePassword;

  @computed
  bool get isFormValid => email.isNotEmpty && password.isNotEmpty;

  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;

  @action
  Future<bool> login() async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      errorMessage = 'Informe e-mail e senha.';
      return false;
    }

    isLoading = true;
    errorMessage = null;

    try {
      await auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          errorMessage = 'E-mail ou senha incorretos';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta';
          break;
        case 'user-disabled':
          errorMessage = 'Usuário desativado';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
          break;
        default:
          errorMessage = 'Erro ao fazer login';
      }
      return false;
    } catch (_) {
      errorMessage = 'Erro ao fazer login';
      return false;
    } finally {
      isLoading = false;
    }
  }
}
