import 'package:dio/dio.dart';
import 'package:flutter_client/core/app_settings.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_page.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_controller.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_page.dart';
import 'package:flutter_client/modules/presentation/pages/password_recovery/change_password_page/change_password_controller.dart';
import 'package:flutter_client/modules/presentation/pages/password_recovery/change_password_page/change_password_page.dart';
import 'package:flutter_client/modules/presentation/pages/password_recovery/forgot_password_page/forgot_password_page.dart';
import 'package:flutter_client/modules/presentation/pages/register_page/register_controller.dart';
import 'package:flutter_client/modules/presentation/pages/register_page/register_page.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addSingleton(
      () => Dio(
        BaseOptions(
          baseUrl: AppSettings.baseUrl,
          sendTimeout: Duration(milliseconds: AppSettings.timeout),
          connectTimeout: Duration(milliseconds: AppSettings.timeout),
          receiveTimeout: Duration(milliseconds: AppSettings.timeout),
        ),
      ),
    );

    i.addSingleton(() => LoginController());
    i.addSingleton<HomeController>(() => HomeController());
    i.addSingleton(() => ChangePasswordController(i()));
    i.addSingleton(() => RegisterController(i()));
  }

  @override
  void routes(r) {
    r.child(AppRoutes.login, child: (_) => const LoginPage());
    r.child(AppRoutes.home, child: (_) => const HomePage());
    r.child(AppRoutes.register, child: (_) => const RegisterPage());
    r.child(AppRoutes.forgotPassword, child: (_) => const ForgotPasswordPage());
    r.child(AppRoutes.changePassword, child: (_) => const ChangePasswordPage());
  }
}