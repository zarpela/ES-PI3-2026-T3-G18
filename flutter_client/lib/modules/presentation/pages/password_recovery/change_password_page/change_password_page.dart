//feito por Abdallah Ali Borges El-Khatib - RA: 25018711

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_action_button.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_input_field.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_page_scaffold.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_section_header.dart';
import 'package:flutter_client/modules/presentation/components/password_validation_card.dart';
import 'package:flutter_client/modules/presentation/pages/password_recovery/change_password_page/change_password_controller.dart';
import 'package:flutter_client/shared/app_illustrations.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

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
  String? statusMessage;
  bool isStatusError = false;

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

    //feito por Abdallah Ali Borges El-Khatib - RA: 25018711
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLoggedIn = currentUser != null;

    if (!isLoggedIn && (email.isEmpty || code.isEmpty)) {
      setState(() {
        statusMessage = 'Solicite um novo código para continuar.';
        isStatusError = true;
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      statusMessage = null;
      isStatusError = false;
    });

    final String? error;
    if (isLoggedIn) {
      error = await controller.changePasswordLoggedIn();
    } else {
      error = await controller.resetPassword(email: email, code: code);
    }

    if (!mounted) {
      return;
    }

    setState(() => isSubmitting = false);

    if (error != null) {
      setState(() {
        statusMessage = error;
        isStatusError = true;
      });
      return;
    }

    setState(() {
      statusMessage = isLoggedIn
          ? 'Senha alterada com sucesso.'
          : 'Senha redefinida com sucesso.';
      isStatusError = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      Modular.to.pop();
    } else {
      Modular.to.navigate(AppRoutes.login);
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
            title: 'Crie uma nova\nsenha',
            subtitle: 'Escolha uma senha forte para proteger\nsua conta',
            bottomSpacing: 40,
          ),
          Observer(
            builder: (_) {
              return Column(
                children: [
                  AuthInputField(
                    label: 'NOVA SENHA',
                    hint: 'Digite sua nova senha',
                    obscureText: controller.obscurePassword,
                    onChanged: controller.setPassword,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        splashRadius: 24,
                        icon: AppIllustrations.eyeIcon(
                          color: const Color(0xFF584048),
                        ),
                        onPressed: controller.toggleObscurePassword,
                      ),
                    ),
                  ),
                  AuthInputField(
                    label: 'CONFIRMAR NOVA SENHA',
                    hint: 'Repita a nova senha',
                    obscureText: controller.obscureConfirmPassword,
                    onChanged: controller.setConfirmPassword,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        splashRadius: 24,
                        icon: AppIllustrations.eyeIcon(
                          color: const Color(0xFF584048),
                        ),
                        onPressed: controller.toggleObscureConfirmPassword,
                      ),
                    ),
                  ),
                  PasswordValidationCard(
                    hasMinLength: controller.hasMinLength,
                    hasUpperAndLower: controller.hasUpperAndLower,
                    hasNumberOrSymbol: controller.hasNumberOrSymbol,
                  ),
                  if (statusMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isStatusError
                            ? const Color(0xFFFFE7E7)
                            : const Color(0xFFE9F7EE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusMessage!,
                        style: TextStyle(
                          color: isStatusError
                              ? const Color(0xFF9D1C1C)
                              : const Color(0xFF1E6B3A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  AuthActionButton(
                    label: 'Redefinir senha',
                    onPressed: submitReset,
                    isEnabled: controller.isFormValid,
                    isLoading: isSubmitting,
                    height: 64,
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    backgroundColor: const Color(0xFFC71E74),
                    disabledBackgroundColor: const Color(0x4DC71E74),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
