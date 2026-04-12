//feito por Marcelo
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_client/shared/app_illustrations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); 

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = Modular.get<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -50,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC71E74).withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B559F).withOpacity(0.05),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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

                  const Text(
                    'Olá!',
                    style: TextStyle(
                      color: Color(0xFF170B58),
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bem-vindo de volta ao futuro dos seus\ninvestimentos.',
                    style: TextStyle(
                      color: Color(0xFF584048),
                      fontSize: 16,
                      height: 1.4, 
                    ),
                  ),
                  const SizedBox(height: 48),

                  Observer(
                    builder: (_) {
                      return Column(
                        children: [
                          _buildInputField(
                            label: 'E-MAIL',
                            hint: 'nome@exemplo.com',
                            keyboardType: TextInputType.emailAddress,
                            onChanged: controller.setEmail, 
                          ),
                          
                          _buildInputField(
                            label: 'SENHA',
                            hint: '••••••••',
                            obscureText: controller.obscurePassword,
                            onChanged: controller.setPassword, 
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                splashRadius: 24,
                                icon: AppIllustrations.eyeIcon(),
                                onPressed: controller.toggleObscurePassword, 
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  ),

                  const SizedBox(height: 24), 

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: controller login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC71E74),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0, 
                      ),
                      child: const Text(
                        'Entrar na minha conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.forgotPassword);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFC71E74),
                      ),
                      child: const Text(
                        'Esqueci a senha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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
                          const TextSpan(text: 'Ainda não tem uma conta? '),
                          TextSpan(
                            text: 'Registre-se',
                            style: const TextStyle(
                              color: Color(0xFFC71E74),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Modular.to.pushNamed(AppRoutes.register);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MÉTODO REUTILIZÁVEL E ALINHADO
  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF584048),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF6F1FF),
              borderRadius: BorderRadius.circular(32),
            ),
            child: TextField(
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: Color(0xFF584048), fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), 
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xFF584048).withOpacity(0.4),
                ),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}