// feito por Abdallah
// RA: 25018711

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_action_button.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_input_field.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_page_scaffold.dart';
import 'package:flutter_client/modules/presentation/components/auth/auth_section_header.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/mfa_verification_page/mfa_verification_controller.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MfaVerificationPage extends StatefulWidget {
  const MfaVerificationPage({super.key});

  @override
  State<MfaVerificationPage> createState() => _MfaVerificationPageState();
}

class _MfaVerificationPageState extends State<MfaVerificationPage> {
  late final MfaVerificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MfaVerificationController(Modular.get<Dio>());
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onVerify() async {
    final success = await _controller.verifyCode();
    if (!mounted) return;

    if (!success) {
      return;
    }

    Modular.get<HomeController>().load();
    Modular.to.navigate(AppRoutes.home);
  }

  Future<void> _onResend() async {
    final success = await _controller.resendCode();
    if (!mounted) return;

    _showSnack(
      success ? 'Codigo reenviado.' : (_controller.errorMessage ?? 'Erro ao reenviar codigo.'),
    );
  }

  Future<void> _onSignOut() async {
    await _controller.signOut();
    if (!mounted) return;
    Modular.to.navigate(AppRoutes.login);
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
            title: 'Verifique seu login',
            subtitle: 'Enviamos um codigo de 6 digitos\npara seu e-mail.',
            titleColor: Color(0xFF170B58),
            subtitleColor: Color(0xFF584048),
            titleFontSize: 34,
            bottomSpacing: 32,
          ),
          AuthInputField(
            label: 'CODIGO',
            hint: '000000',
            keyboardType: TextInputType.number,
            onChanged: _controller.setCode,
            maxLength: 6,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
          if (_controller.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _controller.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          AuthActionButton(
            label: 'Confirmar codigo',
            onPressed: _onVerify,
            isEnabled: _controller.isCodeValid,
            isLoading: _controller.isLoading,
            gradientColors: const [
              Color(0xFFD4147A),
              Color(0xFFAE1465),
            ],
            disabledGradientColors: const [
              Color(0xFFE4B3CF),
              Color(0xFFD4B1C6),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _controller.isLoading ? null : _onResend,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC71E74),
              ),
              child: const Text(
                'Reenviar codigo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _controller.isLoading ? null : _onSignOut,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF584048),
              ),
              child: const Text(
                'Sair',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
