//feito por marcelo
import 'package:flutter/material.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart'; 

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recuperação de\nSenha',
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
                    'Enviaremos um link para o seu e-\nmail para redefinir sua senha',
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
                      keyboardType: TextInputType.emailAddress,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(color: Color(0xFF201A1B), fontSize: 16),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
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
                      onPressed: () {
                        _showVerificationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC71E74),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Enviar instruções',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send_outlined, color: Colors.white, size: 18),
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

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6), 
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0), 
          ),
          insetPadding: const EdgeInsets.all(24), 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                    child: Icon(Icons.mark_email_read_rounded, color: Color(0xFFC71E74), size: 32),
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
                      counterText: "", 
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      hintText: '••••••',
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
                    onPressed: () {
                      if(true){ //TODO: controller verificar codigo
                        // TODO: passar para pagina de alteração de senha
                        Modular.to.pushNamed(AppRoutes.changePassword);
                        return;
                      }
                      // TODO: mostrar error
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC71E74),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
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
                  onPressed: () {

                  },
                  child: const Text(
                    'NÃO RECEBI O CÓDIGO',
                    style: TextStyle(
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
        );
      },
    );
  }
}