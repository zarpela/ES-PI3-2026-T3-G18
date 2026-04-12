//feito por Marcelo
import 'package:flutter/material.dart';
import 'package:flutter_client/modules/presentation/components/password_validation_card.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_client/shared/app_illustrations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  String _password = '';

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasUpperAndLower => _password.contains(RegExp(r'[A-Z]')) && _password.contains(RegExp(r'[a-z]'));
  bool get _hasNumberOrSymbol => _password.contains(RegExp(r'[0-9]')) || _password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

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

              _buildInputField(
                label: 'NOME COMPLETO',
                hint: 'Como no seu RG ou CNH',
                keyboardType: TextInputType.name,
              ),
              
              _buildInputField(
                label: 'TELEFONE',
                hint: '(00) 0 0000-0000',
                keyboardType: TextInputType.phone,
              ),
              
              _buildInputField(
                label: 'E-MAIL',
                hint: 'seuemail@exemplo.com',
                keyboardType: TextInputType.emailAddress,
              ),

              _buildInputField(
                label: 'SENHA',
                hint: 'Mínimo 8 caracteres',
                obscureText: _obscurePassword,
                onChanged: (value) {
                  setState(() {
                    _password = value; 
                  });
                },
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    splashRadius: 24,
                    icon: AppIllustrations.eyeIcon(
                      color: const Color(0xFF514347),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              PasswordValidationCard(
                hasMinLength: _hasMinLength,
                hasUpperAndLower: _hasUpperAndLower,
                hasNumberOrSymbol: _hasNumberOrSymbol,
              ),
              
              const SizedBox(height: 24),

              _buildInputField(
                label: 'CPF',
                hint: '000.000.000-00',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC71E74).withOpacity(0.15),
                      offset: const Offset(0, 10),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (_hasMinLength && _hasUpperAndLower && _hasNumberOrSymbol) ? () {
                    // TODO: controller cadastrar
                    Modular.to.pop();
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