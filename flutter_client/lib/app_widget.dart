// feito por marcelo
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MesclaInvest',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.pink,
        fontFamily: 'Montserrat',
      ),
      routerConfig: Modular.routerConfig, 
      debugShowCheckedModeBanner: false,
    );
  }
}