// feito por marcelo
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_client/shared/app_illustrations.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'change_password_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ChangePasswordController controller =
      Modular.get<ChangePasswordController>();

  late final Map<String, dynamic> recoveryData;
  bool isSubmitting = false;

  String get email => (recoveryData['email'] ?? '').toString();
  String get code => (recoveryData['code'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    final data = Modular.args.data;
    recoveryData = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
  }

  @override
  void dispose() {
    controller.clearForm();
    super.dispose();
  }

  Future<void> submitReset() async {
    if (!controller.isFormValid || isSubmitting) {
      return;
    }

    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicite um novo codigo para continuar.'),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);
    final error = await controller.resetPassword(email: email, code: code);
    if (!mounted) {
      return;
    }

    setState(() => isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha redefinida com sucesso.')),
    );

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    Modular.to.navigate(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC71E74)),
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crie uma nova\nsenha',
                style: TextStyle(
                  color: Color(0xFF170B58),
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escolha uma senha forte para proteger\nsua conta',
                style: TextStyle(
                  color: Color(0xFF584048),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              Observer(
                builder: (_) {
                  return Column(
                    children: [
                      _buildInputField(
                        label: 'NOVA SENHA',
                        hint: 'Digite sua nova senha',
                        obscureText: controller.obscurePassword,
                        onChanged: controller.setPassword,
                        suffixIcon: IconButton(
                          splashRadius: 24,
                          icon: AppIllustrations.eyeIcon(
                            color: const Color(0xFF584048),
                          ),
                          onPressed: controller.toggleObscurePassword,
                        ),
                      ),
                      _buildInputField(
                        label: 'CONFIRMAR NOVA SENHA',
                        hint: 'Repita a nova senha',
                        obscureText: controller.obscureConfirmPassword,
                        onChanged: controller.setConfirmPassword,
                        suffixIcon: IconButton(
                          splashRadius: 24,
                          icon: AppIllustrations.eyeIcon(
                            color: const Color(0xFF584048),
                          ),
                          onPressed: controller.toggleObscureConfirmPassword,
                        ),
                      ),
                      _buildValidationCard(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: controller.isFormValid && !isSubmitting
                              ? submitReset
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC71E74),
                            disabledBackgroundColor: const Color(
                              0xFFC71E74,
                            ).withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 0,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Redefinir senha',
                                  style: TextStyle(
                                    fontSize: 16,
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1FF),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sua senha deve conter:',
            style: TextStyle(
              color: Color(0xFF170B58),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleRow('Pelo menos 8 caracteres', controller.hasMinLength),
          _buildRuleRow(
            'Letras maiusculas e minusculas',
            controller.hasUpperAndLower,
          ),
          _buildRuleRow(
            'Pelo menos um numero ou simbolo',
            controller.hasNumberOrSymbol,
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isValid
                ? const Color(0xFFC71E74)
                : const Color(0xFF584048).withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isValid
                    ? const Color(0xFF584048)
                    : const Color(0xFF584048).withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
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
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: Color(0xFF201A1B), fontSize: 16),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xFF584048).withOpacity(0.4),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: suffixIcon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
