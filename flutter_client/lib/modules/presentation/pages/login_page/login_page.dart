//feito por abdallah, gabriel e marcelo
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_action_button.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_input_field.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_page_scaffold.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_section_header.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_controller.dart';
import 'package:flutter_client/shared/app_illustrations.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = Modular.get<LoginController>();

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _parseApiMessage(dynamic data, {required String fallback}) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }

  Future<void> _handleLogin() async {
    final success = await controller.login();
    if (!mounted || !success) {
      return;
    }

    // A partir daqui o usuario ja autenticou no FirebaseAuth.
    // Antes de liberar acesso ao app, consultamos o backend para saber se o
    // MFA esta habilitado; se estiver, exigimos o codigo enviado por e-mail.
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    if (!mounted) return;

    if (token == null) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      _showSnack('Nao foi possivel validar sua sessao. Tente novamente.');
      return;
    }

    final dio = Modular.get<Dio>();

    try {
      // Consulta o status do MFA no backend (Firestore).
      final response = await dio.get(
        '/mfa/status',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      final enabled = data is Map ? data['enabled'] == true : false;

      if (enabled) {
        // Dispara o envio do codigo para o e-mail cadastrado e navega para a tela
        // de verificacao. O usuario so entra na home apos confirmar o codigo.
        await dio.post(
          '/mfa/request-code',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (!mounted) return;
        Modular.to.navigate(AppRoutes.mfaVerify);
        return;
      }
    } on DioException catch (e) {
      final message = _parseApiMessage(
        e.response?.data,
        fallback: 'Erro ao verificar autenticacao em duas etapas.',
      );
      // Falhou em checar/solicitar MFA: faz logout para evitar acesso sem validacao.
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      _showSnack(message);
      return;
    } catch (_) {
      // Mesmo comportamento para erros nao esperados.
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      _showSnack('Erro ao verificar autenticacao em duas etapas.');
      return;
    }

    Modular.get<HomeController>().load();
    Modular.to.navigate(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      showDecorations: true,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'MesclaInvest',
              style: TextStyle(
                color: Color(0xFF170B58),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 64),
          const AuthSectionHeader(
            title: 'Olá!',
            subtitle: 'Bem-vindo de volta ao futuro dos seus\ninvestimentos.',
            titleColor: Color(0xFF170B58),
            subtitleColor: Color(0xFF584048),
            titleFontSize: 42,
            bottomSpacing: 48,
          ),
          Observer(
            builder: (_) {
              return Column(
                children: [
                  AuthInputField(
                    label: 'E-MAIL',
                    hint: 'nome@exemplo.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: controller.setEmail,
                    textColor: const Color(0xFF584048),
                  ),
                  AuthInputField(
                    label: 'SENHA',
                    hint: '••••••••',
                    obscureText: controller.obscurePassword,
                    onChanged: controller.setPassword,
                    textColor: const Color(0xFF584048),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        splashRadius: 24,
                        icon: AppIllustrations.eyeIcon(),
                        onPressed: controller.toggleObscurePassword,
                      ),
                    ),
                  ),
                  if (controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  AuthActionButton(
                    label: 'Entrar na minha conta',
                    onPressed: _handleLogin,
                    isEnabled: controller.isFormValid,
                    isLoading: controller.isLoading,
                    gradientColors: const [
                      Color(0xFFD4147A),
                      Color(0xFFAE1465),
                    ],
                    disabledGradientColors: const [
                      Color(0xFFE4B3CF),
                      Color(0xFFD4B1C6),
                    ],
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4147A).withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    trailing: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => Modular.to.pushNamed(AppRoutes.forgotPassword),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC71E74),
              ),
              child: const Text(
                'Esqueci a senha',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF584048),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: 'Ainda nao tem uma conta? '),
                  TextSpan(
                    text: 'Registre-se',
                    style: const TextStyle(
                      color: Color(0xFFC71E74),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Modular.to.pushNamed(AppRoutes.register),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
