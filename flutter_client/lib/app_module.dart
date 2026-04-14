// feito por marcelo

import 'package:flutter_client/core/app_settings.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_page.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_controller.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_page.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AppModule extends Module {

  @override
  void binds(i) {
    // i.addInstance(FirebaseFirestore.instance); //TODO: configurar firebvase

    // Dio singleton
    i.addSingleton(() => Dio(
      BaseOptions(
        baseUrl: AppSettings.baseUrl,
        sendTimeout: Duration(milliseconds: AppSettings.timeout),
        connectTimeout: Duration(milliseconds: AppSettings.timeout),
        receiveTimeout: Duration(milliseconds: AppSettings.timeout),
      )
    ));

    // Controllers
    i.addSingleton(LoginController.new);
    i.addSingleton(() => HomeController(i<Dio>()));
<<<<<<< Updated upstream
=======
    i.addSingleton(ChangePasswordController.new);
    i.addSingleton(RegisterController.new); // Já recebe Dio automaticamente
>>>>>>> Stashed changes
  }

  @override
  void routes(r) {
    r.child(AppRoutes.login, child: (_) => const LoginPage());
    r.child(AppRoutes.home,  child: (_) => const HomePage());
<<<<<<< Updated upstream
=======
    r.child(AppRoutes.register, child: (_) => const RegisterPage());
    r.child(AppRoutes.catalogo, child: (context) => const HomePage());
    r.child(AppRoutes.forgotPassword, child: (_) => const ForgotPasswordPage());
    r.child(AppRoutes.changePassword, child: (_) => const ChangePasswordPage());
>>>>>>> Stashed changes
  }
}
