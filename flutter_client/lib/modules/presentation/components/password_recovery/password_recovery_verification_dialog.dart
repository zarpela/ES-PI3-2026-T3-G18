//feito por Abdallah Ali Borges El-Khatib - RA: 25018711
import 'package:flutter/material.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PasswordRecoveryVerificationDialog extends StatefulWidget {
  const PasswordRecoveryVerificationDialog({
    required this.codeController,
    required this.email,
    required this.resendAttempts,
    required this.resendCountdown,
    required this.onValidateCode,
    required this.onResendCode,
    super.key,
  });

  final TextEditingController codeController;
  final String email;
  final ValueNotifier<int> resendAttempts;
  final ValueNotifier<int> resendCountdown;
  final Future<String?> Function(String email, String code) onValidateCode;
  final Future<void> Function() onResendCode;

  @override
  State<PasswordRecoveryVerificationDialog> createState() =>
      _PasswordRecoveryVerificationDialogState();
}

class _PasswordRecoveryVerificationDialogState
    extends State<PasswordRecoveryVerificationDialog> {
  bool isVerifying = false;
  bool isResending = false;

  Future<void> _handleVerify() async {
    final email = widget.email.trim();
    final code = widget.codeController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o e-mail antes de continuar.')),
      );
      return;
    }

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código com 6 dígitos.')),
      );
      return;
    }

    setState(() => isVerifying = true);
    final error = await widget.onValidateCode(email, code);
    if (!mounted) {
      return;
    }

    setState(() => isVerifying = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.of(context).pop();
    Modular.to.pushNamed(
      AppRoutes.changePassword,
      arguments: {'email': email, 'code': code},
    );
  }

  Future<void> _handleResend() async {
    setState(() => isResending = true);
    await widget.onResendCode();
    if (!mounted) {
      return;
    }

    setState(() => isResending = false);
  }

  String _formatCountdownLabel(int secondsRemaining) {
    final seconds = secondsRemaining.toString().padLeft(2, '0');
    return '00:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Color(0xFF584048)),
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
              'Digite o código',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF170B58),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enviamos um código de verificação para o\nseu e-mail cadastrado. Por favor, insira os\n6 dígitos abaixo.',
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
                controller: widget.codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 12,
                  color: Color(0xFF170B58),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  hintText: '******',
                  hintStyle: TextStyle(
                    letterSpacing: 12,
                    color: const Color(0x66584048),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isVerifying ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC71E74),
                  disabledBackgroundColor: const Color(0x4DC71E74),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                  minimumSize: const Size.fromHeight(56),
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
              valueListenable: widget.resendAttempts,
              builder: (context, attempts, child) {
                return ValueListenableBuilder<int>(
                  valueListenable: widget.resendCountdown,
                  builder: (context, countdown, nestedChild) {
                    final timerActive = attempts >= 2 && countdown > 0;
                    final canResend = !timerActive && !isResending;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: canResend ? _handleResend : null,
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
                            'Reenviar em ${_formatCountdownLabel(countdown)}',
                            style: const TextStyle(
                              color: Color(0xB3584048),
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
  }
}
