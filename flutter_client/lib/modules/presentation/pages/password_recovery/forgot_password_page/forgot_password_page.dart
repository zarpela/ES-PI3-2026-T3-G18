//feito por marcelo
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/shared/app_routes.dart';
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
        showVerificationDialog(context);
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

    return 'Nao foi possivel concluir a solicitacao.';
  }

  String _buildApiMessage(Map<String, dynamic> data) {
    return (data['message'] ?? data['error'] ?? 'Codigo enviado com sucesso.')
        .toString();
  }

  void showVerificationDialog(BuildContext context) {
    codeController.clear();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext dialogContext) {
        var isVerifying = false;
        var isResending = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
              insetPadding: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF584048),
                        ),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mark_email_read_rounded,
                          color: Color(0xFFC71E74),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Digite o codigo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF170B58),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enviamos um codigo de verificacao para o\nseu e-mail cadastrado. Por favor, insira os\n6 digitos abaixo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF584048),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F1FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 12.0,
                          color: Color(0xFF170B58),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          hintText: '******',
                          hintStyle: TextStyle(
                            letterSpacing: 12.0,
                            color: const Color(0xFF584048).withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                final email =
                                    (lastRequestedEmail ?? emailController.text)
                                        .trim();
                                final code = codeController.text.trim();

                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Informe o e-mail antes de continuar.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (code.length != 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Digite o codigo com 6 digitos.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() => isVerifying = true);
                                final error = await validateCode(
                                  email: email,
                                  code: code,
                                );

                                if (!mounted || !dialogContext.mounted) {
                                  return;
                                }

                                setDialogState(() => isVerifying = false);

                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                  return;
                                }

                                Navigator.of(dialogContext).pop();
                                Modular.to.pushNamed(
                                  AppRoutes.changePassword,
                                  arguments: {'email': email, 'code': code},
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC71E74),
                          disabledBackgroundColor: const Color(
                            0xFFC71E74,
                          ).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: isVerifying
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
                                'Verificar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<int>(
                      valueListenable: resendAttempts,
                      builder: (_, attempts, __) {
                        return ValueListenableBuilder<int>(
                          valueListenable: resendCountdown,
                          builder: (_, countdown, ___) {
                            final timerActive = attempts >= 2 && countdown > 0;
                            final canResend = !timerActive && !isResending;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: canResend
                                      ? () async {
                                          setDialogState(
                                            () => isResending = true,
                                          );
                                          await sendInstructions(
                                            openDialog: false,
                                            isResend: true,
                                          );
                                          if (!mounted ||
                                              !dialogContext.mounted) {
                                            return;
                                          }
                                          setDialogState(
                                            () => isResending = false,
                                          );
                                        }
                                      : null,
                                  child: Text(
                                    isResending
                                        ? 'REENVIANDO...'
                                        : 'NAO RECEBI O CODIGO',
                                    style: const TextStyle(
                                      color: Color(0xFFC71E74),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                if (timerActive) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reenviar em $resendCountdownLabel',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF584048,
                                      ).withOpacity(0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC71E74)),
          onPressed: () {
            Modular.to.pop();
          },
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC71E74).withOpacity(0.06),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B559F).withOpacity(0.06),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recuperacao de\nSenha',
                    style: TextStyle(
                      color: Color(0xFF170B58),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enviaremos um codigo para o seu e-\nmail para redefinir sua senha',
                    style: TextStyle(
                      color: Color(0xFF584048),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'E-MAIL CADASTRADO',
                    style: TextStyle(
                      color: Color(0xFFC71E74),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F1FF),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        color: Color(0xFF201A1B),
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 22,
                        ),
                        hintText: 'seu@email.com',
                        hintStyle: TextStyle(
                          color: const Color(0xFF584048).withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC71E74).withOpacity(0.2),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isSending ? null : () => sendInstructions(),
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
                      child: isSending
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Enviar instrucoes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
