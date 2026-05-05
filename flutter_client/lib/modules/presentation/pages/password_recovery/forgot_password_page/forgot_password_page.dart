import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_action_button.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_input_field.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_page_scaffold.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_section_header.dart';
import 'package:flutter_client/modules/presentation/components/password_recovery/password_recovery_verification_dialog.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final Dio dio = Modular.get<Dio>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final ValueNotifier<int> resendCountdown = ValueNotifier<int>(0);
  final ValueNotifier<int> resendAttempts = ValueNotifier<int>(0);

  bool isSending = false;
  String? lastRequestedEmail;
  Timer? resendTimer;

  @override
  void dispose() {
    resendTimer?.cancel();
    resendCountdown.dispose();
    resendAttempts.dispose();
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void startResendCountdown() {
    resendTimer?.cancel();
    resendCountdown.value = 30;

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value <= 1) {
        resendCountdown.value = 0;
        timer.cancel();
        return;
      }

      resendCountdown.value -= 1;
    });
  }

  String get resendCountdownLabel {
    final seconds = resendCountdown.value.toString().padLeft(2, '0');
    return '00:$seconds';
  }

  Future<void> sendInstructions({
    bool openDialog = true,
    bool isResend = false,
  }) async {
    final typedEmail = emailController.text.trim();

    if (typedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o e-mail cadastrado.')),
      );
      return;
    }

    if (!isResend) {
      resendTimer?.cancel();
      resendCountdown.value = 0;
      resendAttempts.value = 0;
    }

    setState(() => isSending = true);
    lastRequestedEmail = typedEmail;

    try {
      final response = await dio.post(
        'forgot-password',
        data: {'identifier': typedEmail},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (!mounted) {
        return;
      }

      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      lastRequestedEmail = (data['email'] ?? typedEmail).toString();
      if (isResend) {
        resendAttempts.value += 1;
      }
      if (isResend && resendAttempts.value >= 2) {
        startResendCountdown();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_buildApiMessage(data))));

      if (openDialog) {
        showVerificationDialog();
      }
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }

      final data = error.response?.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_buildApiMessage(map))));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_extractErrorMessage(error))));
      }
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  Future<String?> validateCode({
    required String email,
    required String code,
  }) async {
    try {
      await dio.post(
        'verify-reset-code',
        data: {'email': email.trim(), 'code': code.trim()},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return null;
    } on DioException catch (error) {
      return _extractErrorMessage(error);
    } catch (_) {
      return 'Nao foi possivel validar o codigo.';
    }
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final message = map['message'] ?? map['error'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'A solicitacao demorou demais. Tente novamente.';
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      return 'Nao foi possivel conectar ao servidor. Verifique a API e tente novamente.';
    }

    return 'Nao foi possivel concluir a solicitacao.';
  }

  String _buildApiMessage(Map<String, dynamic> data) {
    return (data['message'] ?? data['error'] ?? 'Codigo enviado com sucesso.')
        .toString();
  }

  void showVerificationDialog() {
    codeController.clear();

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) {
        return PasswordRecoveryVerificationDialog(
          codeController: codeController,
          email: (lastRequestedEmail ?? emailController.text).trim(),
          resendAttempts: resendAttempts,
          resendCountdown: resendCountdown,
          resendCountdownLabel: resendCountdownLabel,
          onValidateCode: (email, code) =>
              validateCode(email: email, code: code),
          onResendCode: () =>
              sendInstructions(openDialog: false, isResend: true),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      showDecorations: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC71E74)),
          onPressed: () => Modular.to.pop(),
        ),
        title: const Text(
          'MesclaInvest',
          style: TextStyle(
            color: Color(0xFF170B58),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthSectionHeader(
            title: 'Recuperacao de\nSenha',
            subtitle:
                'Enviaremos um codigo para o seu e-mail para redefinir sua senha',
            titleFontSize: 32,
            titleHeight: 1.2,
            bottomSpacing: 48,
          ),
          AuthInputField(
            label: 'E-MAIL CADASTRADO',
            hint: 'seu@email.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            labelColor: const Color(0xFFC71E74),
            labelFontSize: 10,
            labelLetterSpacing: 0.8,
          ),
          const SizedBox(height: 16),
          AuthActionButton(
            label: 'Enviar instrucoes',
            onPressed: () => sendInstructions(),
            isEnabled: !isSending,
            isLoading: isSending,
            height: 64,
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            backgroundColor: const Color(0xFFC71E74),
            disabledBackgroundColor: const Color(0x4DC71E74),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC71E74).withValues(alpha: 0.2),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
            trailing: const Icon(
              Icons.send_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
