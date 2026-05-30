//feito por Abdallah
import 'package:flutter/material.dart';

class LoginMfaVerificationDialog extends StatefulWidget {
  const LoginMfaVerificationDialog({
    required this.email,
    required this.onValidateCode,
    required this.onResendCode,
    super.key,
  });

  final String email;
  final Future<String?> Function(String code) onValidateCode;
  final Future<String?> Function() onResendCode;

  @override
  State<LoginMfaVerificationDialog> createState() =>
      _LoginMfaVerificationDialogState();
}

class _LoginMfaVerificationDialogState
    extends State<LoginMfaVerificationDialog> {
  final TextEditingController _codeController = TextEditingController();

  bool isVerifying = false;
  bool isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código com 6 dígitos.')),
      );
      return;
    }

    setState(() => isVerifying = true);
    final error = await widget.onValidateCode(code);
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

    Navigator.of(context).pop(true);
  }

  Future<void> _handleResend() async {
    setState(() => isResending = true);
    final error = await widget.onResendCode();
    if (!mounted) {
      return;
    }

    setState(() => isResending = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Codigo reenviado com sucesso.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isVerifying && !isResending,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(false);
        }
      },
      child: Dialog(
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
                  onTap: isVerifying || isResending
                      ? null
                      : () => Navigator.of(context).pop(false),
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
                    Icons.security_rounded,
                    color: Color(0xFFC71E74),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirme seu acesso',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF170B58),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos um código de verificação para ${widget.email}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF584048),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Digite os 6 dígitos para concluir o login.',
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
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    color: Color(0xFF170B58),
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    hintText: '******',
                    hintStyle: TextStyle(
                      letterSpacing: 12,
                      color: Color(0x66584048),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isVerifying || isResending ? null : _handleVerify,
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
              TextButton(
                onPressed: isVerifying || isResending ? null : _handleResend,
                child: Text(
                  isResending ? 'REENVIANDO...' : 'REENVIAR CODIGO',
                  style: const TextStyle(
                    color: Color(0xFFC71E74),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
