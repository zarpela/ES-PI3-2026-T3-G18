//feito por Marcelo
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/password_validation_card.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_client/shared/app_illustrations.dart';
import 'register_controller.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final controller = Modular.get<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC71E74)),
          onPressed: () {
            Modular.to.pop();
          },
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crie sua conta',
                style: TextStyle(
                  color: Color(0xFF201A1B),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sua jornada para um futuro financeiro\npróspero começa agora. Preencha os\ndetalhes abaixo.',
                style: TextStyle(
                  color: Color(0xFF514347),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              Observer(
                builder: (_) {
                  return Column(
                    children: [
                      _buildInputField(
                        label: 'NOME COMPLETO',
                        hint: 'Como no seu RG ou CNH',
                        keyboardType: TextInputType.name,
                        onChanged: controller.setFullName,
                      ),
                      
                      _buildInputField(
                        label: 'TELEFONE',
                        hint: '(00) 0 0000-0000',
                        keyboardType: TextInputType.phone,
                        onChanged: controller.setPhone,
                      ),
                      
                      _buildInputField(
                        label: 'E-MAIL',
                        hint: 'seuemail@exemplo.com',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: controller.setEmail,
                      ),

                      _buildInputField(
                        label: 'SENHA',
                        hint: 'Mínimo 8 caracteres',
                        obscureText: controller.obscurePassword,
                        onChanged: controller.setPassword,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            splashRadius: 24,
                            icon: AppIllustrations.eyeIcon(
                              color: const Color(0xFF514347),
                            ),
                            onPressed: controller.toggleObscurePassword,
                          ),
                        ),
                      ),

                      PasswordValidationCard(
                        hasMinLength: controller.hasMinLength,
                        hasUpperAndLower: controller.hasUpperAndLower,
                        hasNumberOrSymbol: controller.hasNumberOrSymbol,
                      ),

                      const SizedBox(height: 24),

                      _buildInputField(
                        label: 'CPF',
                        hint: '000.000.000-00',
                        keyboardType: TextInputType.number,
                        onChanged: controller.setDocument,
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 68,
                        child: ElevatedButton(
                          onPressed: controller.isFormValid ? () {
                            // Modular.to.pushNamed('/home');
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC71E74),
                            disabledBackgroundColor: const Color(0xFFC71E74).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                            elevation: 0, 
                          ),
                          child: const Text(
                            'Cadastrar agora',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 24),

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF514347),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Ao clicar em cadastrar, você concorda com nossos\n'),
                      TextSpan(
                        text: 'Termos de Uso',
                        style: const TextStyle(
                          color: Color(0xFFC71E74),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                      const TextSpan(text: ' e '),
                      TextSpan(
                        text: 'Política de Privacidade.',
                        style: const TextStyle(
                          color: Color(0xFF514347),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF514347),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFBF1F2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: TextField(
              obscureText: obscureText,
              keyboardType: keyboardType,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center, 
              style: const TextStyle(color: Color(0xFF201A1B), fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xFF514347).withOpacity(0.5), 
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