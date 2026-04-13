import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_controller.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController = Modular.get<LoginController>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Observer(
                builder: (_) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MesclaInvest',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Entre com seu email para continuar.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: loginController.setEmail,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: loginController.setPassword,
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    if (loginController.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loginController.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (loginController.infoMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        loginController.infoMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: loginController.isLoading ? null : _handleLogin,
                      child: loginController.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Entrar'),
                    ),
                    OutlinedButton(
                      onPressed: loginController.isLoading
                          ? null
                          : _handleCreateAccount,
                      child: const Text('Criar conta'),
                    ),
                    TextButton(
                      onPressed: loginController.isLoading
                          ? null
                          : _handlePasswordReset,
                      child: const Text('Esqueci minha senha'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    loginController.setEmail(_emailController.text);
    loginController.setPassword(_passwordController.text);

    await loginController.login();

    if (!mounted) return;

    if (loginController.errorMessage == null) {
      Modular.to.navigate('/home');
    }
  }

  Future<void> _handlePasswordReset() async {
    loginController.setEmail(_emailController.text);
    await loginController.sendPasswordResetEmail();
  }

  Future<void> _handleCreateAccount() async {
    loginController.setEmail(_emailController.text);
    loginController.setPassword(_passwordController.text);
    await loginController.createAccount();
  }
}
