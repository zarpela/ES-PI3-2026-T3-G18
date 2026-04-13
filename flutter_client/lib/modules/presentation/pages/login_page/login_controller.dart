import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'login_controller.g.dart';

class LoginController = LoginControllerBase with _$LoginController;

abstract class LoginControllerBase with Store {
  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String? infoMessage;

  @action
  void setEmail(String value) => email = value;

  @action
  void setPassword(String value) => password = value;

  @action
  Future<void> login() async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      errorMessage = 'Informe email e senha.';
      infoMessage = null;
      return;
    }

    isLoading = true;
    errorMessage = null;
    infoMessage = null;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      errorMessage = _mapAuthError(error);
    } catch (_) {
      errorMessage = 'Nao foi possivel fazer login agora.';
    }

    isLoading = false;
  }

  @action
  Future<void> sendPasswordResetEmail() async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      errorMessage = 'Informe seu email para recuperar a senha.';
      infoMessage = null;
      return;
    }

    isLoading = true;
    errorMessage = null;
    infoMessage = null;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmedEmail);
      infoMessage = 'Enviamos um link de redefinicao para o seu email.';
    } on FirebaseAuthException catch (error) {
      errorMessage = _mapResetError(error);
    } catch (_) {
      errorMessage = 'Nao foi possivel enviar o email de redefinicao.';
    }

    isLoading = false;
  }

  @action
  Future<void> createAccount() async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty || password.isEmpty) {
      errorMessage = 'Informe email e senha para criar a conta.';
      infoMessage = null;
      return;
    }

    isLoading = true;
    errorMessage = null;
    infoMessage = null;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      infoMessage = 'Conta criada com sucesso.';
    } on FirebaseAuthException catch (error) {
      errorMessage = _mapCreateAccountError(error);
    } catch (_) {
      errorMessage = 'Nao foi possivel criar a conta agora.';
    }

    isLoading = false;
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email invalido.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email ou senha invalidos.';
      case 'user-disabled':
        return 'Este usuario esta desativado.';
      case 'network-request-failed':
        return 'Falha de rede. Tente novamente.';
      default:
        return 'Nao foi possivel fazer login.';
    }
  }

  String _mapResetError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email invalido.';
      case 'user-not-found':
        return 'Nenhum usuario foi encontrado com esse email.';
      case 'network-request-failed':
        return 'Falha de rede. Tente novamente.';
      default:
        return 'Nao foi possivel enviar o email de redefinicao.';
    }
  }

  String _mapCreateAccountError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email invalido.';
      case 'email-already-in-use':
        return 'Ja existe uma conta com esse email.';
      case 'weak-password':
        return 'A senha precisa ter pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Falha de rede. Tente novamente.';
      default:
        return 'Nao foi possivel criar a conta.';
    }
  }
}
