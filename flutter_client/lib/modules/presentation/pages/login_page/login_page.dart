import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/core/app_session.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_action_button.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_input_field.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_page_scaffold.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_section_header.dart';
import 'package:flutter_client/modules/presentation/components/auth/login_mfa_verification_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AppSession.instance.isAccessGranted &&
          controller.auth.currentUser != null) {
        controller.auth.signOut();
      }
    });
  }

  Future<void> _handleLogin() async {
    final success = await controller.login();
    if (!mounted || !success) {
      return;
    }

    if (controller.isAwaitingMfa) {
      final verified = await _showMfaDialog();
      if (!mounted) {
        return;
      }

      if (!verified) {
        await controller.cancelPendingMfa();
        if (mounted) {
          setState(() {});
        }
        return;
      }
    }

    _completeLogin();
  }

  Future<bool> _showMfaDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return LoginMfaVerificationDialog(
          email: controller.pendingMfaEmail,
          onValidateCode: controller.verifyLoginMfaCode,
          onResendCode: controller.resendLoginMfaCode,
        );
      },
    );

    return result ?? false;
  }

  void _completeLogin() {
    // Forca o reload do HomeController para o novo usuario.
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
            title: 'Ola!',
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
                    hint: '********',
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
