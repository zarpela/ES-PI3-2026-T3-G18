import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_action_button.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_input_field.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_page_scaffold.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_section_header.dart';
import 'package:flutter_client/modules/presentation/components/password_validation_card.dart';
import 'package:flutter_client/modules/presentation/pages/register_page/register_controller.dart';
import 'package:flutter_client/shared/app_illustrations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController controller = Modular.get<RegisterController>();

  @override
  void dispose() {
    controller.clearForm();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final success = await controller.register();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Conta criada com sucesso!'
              : controller.errorMessage ?? 'Erro ao criar conta',
        ),
      ),
    );

    if (success) {
      Modular.to.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC71E74)),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthSectionHeader(
            title: 'Crie sua conta',
            subtitle:
                'Sua jornada para um futuro financeiro\nprospero comeca agora. Preencha os\ndetalhes abaixo.',
            titleColor: Color(0xFF201A1B),
            subtitleColor: Color(0xFF514347),
          ),
          Observer(
            builder: (_) {
              return Column(
                children: [
                  AuthInputField(
                    label: 'NOME COMPLETO',
                    hint: 'Como no seu RG ou CNH',
                    keyboardType: TextInputType.name,
                    onChanged: controller.setFullName,
                    labelColor: const Color(0xFF514347),
                    fillColor: const Color(0xFFFBF1F2),
                    hintColor: const Color(0x80514347),
                  ),
                  AuthInputField(
                    label: 'TELEFONE',
                    hint: '(00) 0 0000-0000',
                    keyboardType: TextInputType.phone,
                    onChanged: controller.setPhone,
                    labelColor: const Color(0xFF514347),
                    fillColor: const Color(0xFFFBF1F2),
                    hintColor: const Color(0x80514347),
                  ),
                  AuthInputField(
                    label: 'E-MAIL',
                    hint: 'seuemail@exemplo.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: controller.setEmail,
                    labelColor: const Color(0xFF514347),
                    fillColor: const Color(0xFFFBF1F2),
                    hintColor: const Color(0x80514347),
                  ),
                  AuthInputField(
                    label: 'SENHA',
                    hint: '••••••••',
                    obscureText: controller.obscurePassword,
                    onChanged: controller.setPassword,
                    labelColor: const Color(0xFF514347),
                    fillColor: const Color(0xFFFBF1F2),
                    hintColor: const Color(0x80514347),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
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
                  AuthInputField(
                    label: 'CPF',
                    hint: '000.000.000-00',
                    keyboardType: TextInputType.number,
                    onChanged: controller.setDocument,
                    labelColor: const Color(0xFF514347),
                    fillColor: const Color(0xFFFBF1F2),
                    hintColor: const Color(0x80514347),
                  ),
                  const SizedBox(height: 16),
                  AuthActionButton(
                    label: 'Cadastrar agora',
                    onPressed: _handleRegister,
                    isEnabled: controller.isFormValid,
                    isLoading: controller.isLoading,
                    height: 68,
                    borderRadius: const BorderRadius.all(Radius.circular(34)),
                    backgroundColor: const Color(0xFFC71E74),
                    disabledBackgroundColor: const Color(0x4DC71E74),
                    labelStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                  const TextSpan(
                    text: 'Ao clicar em cadastrar, voce concorda com nossos\n',
                  ),
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
                    text: 'Politica de Privacidade.',
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
    );
  }
}
