//feito por Marcelo
import 'package:flutter/gestures.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/shared/app_illustrations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            right: -50,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC71E74).withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B559F).withOpacity(0.05),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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

                  // Saudação
                  const Text(
                    'Olá!',
                    style: TextStyle(
                      color: Color(0xFF170B58),
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bem-vindo de volta ao futuro dos seus\ninvestimentos.',
                    style: TextStyle(
                      color: Color(0xFF584048),
                      fontSize: 16,
                      height: 1.4, 
                    ),
                  ),
                  const SizedBox(height: 48),

                  const Text(
                    'E-MAIL',
                    style: TextStyle(
                      color: Color(0xFF584048),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F1FF),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Color(0xFF584048), fontSize: 16),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        hintText: 'nome@exemplo.com',
                        hintStyle: TextStyle(
                          color: const Color(0xFF584048).withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'SENHA',
                    style: TextStyle(
                      color: Color(0xFF584048),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Input SENHA
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F1FF),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Color(0xFF584048), fontSize: 16),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(left: 24, top: 18, bottom: 18),
                        hintText: '••••••••',
                        hintStyle: TextStyle(
                          color: const Color(0xFF584048).withOpacity(0.4),
                        ),

                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            splashRadius: 24,
                            icon: AppIllustrations.eyeIcon(),
                            
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),


                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: controller login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC71E74),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0, 
                      ),
                      child: const Text(
                        'Entrar na minha conta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Modular.to.pushNamed(AppRoutes.forgotPassword);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFC71E74),
                      ),
                      child: const Text(
                        'Esqueci a senha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Aumentei o espaçamento aqui para afastar bem do botão de cima
                  const SizedBox(height: 48), 

                  // Texto limpo e direto, em uma linha só
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF584048), 
                          fontSize: 14,
                          fontWeight: FontWeight.w500, // Um peso um pouquinho maior pra dar leitura
                        ),
                        children: [
                          const TextSpan(text: 'Ainda não tem uma conta? '),
                          TextSpan(
                            text: 'Registre-se',
                            style: const TextStyle(
                              color: Color(0xFFC71E74),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Modular.to.pushNamed(AppRoutes.register);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32)
                ],
              ),
              ),
            ),
          
        ],
      ),
    );
  }
}