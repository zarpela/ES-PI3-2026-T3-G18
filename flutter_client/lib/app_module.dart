// feito por abdallah, marcelo, pedro

import 'package:dio/dio.dart';
import 'package:flutter_client/core/app_settings.dart';
import 'package:flutter_client/modules/presentation/pages/all_investments_page/all_investments_page.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_controller.dart';
import 'package:flutter_client/modules/presentation/pages/home_page/home_page.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_controller.dart';
import 'package:flutter_client/modules/presentation/pages/login_page/login_page.dart';
import 'package:flutter_client/modules/presentation/pages/marketplace_page/marketplace_controller.dart';
import 'package:flutter_client/modules/presentation/pages/marketplace_page/marketplace_page.dart';
import 'package:flutter_client/modules/presentation/pages/mfa_verification_page/mfa_verification_page.dart';
import 'package:flutter_client/modules/presentation/pages/password_recovery/change_password_page/change_password_controller.dart';
import 'package:flutter_client/modules/presentation/pages/password_recovery/change_password_page/change_password_page.dart';
import 'package:flutter_client/modules/presentation/pages/password_recovery/forgot_password_page/forgot_password_page.dart';
import 'package:flutter_client/modules/presentation/pages/register_page/register_controller.dart';
import 'package:flutter_client/modules/presentation/pages/register_page/register_page.dart';
import 'package:flutter_client/modules/presentation/pages/startup_details_page/startup_details_page.dart';
import 'package:flutter_client/modules/presentation/pages/settings_page/settings_page.dart';
import 'package:flutter_client/modules/presentation/pages/token_transaction_page/token_transaction_controller.dart';
import 'package:flutter_client/modules/presentation/pages/token_transaction_page/token_transaction_page.dart';
import 'package:flutter_client/shared/app_routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

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
    i.addLazySingleton(() => HomeController(i()));
    i.addSingleton(() => ChangePasswordController(i()));
    i.addSingleton(() => RegisterController(i()));
    i.addLazySingleton(() => MarketplaceController());
  }

  @override
  void routes(r) {
    r.child(AppRoutes.login, child: (_) => const LoginPage());
    r.child(AppRoutes.loginAlias, child: (_) => const LoginPage());
    r.child(AppRoutes.home, child: (_) => const HomePage());
    r.child(AppRoutes.register, child: (_) => const RegisterPage());
    r.child(AppRoutes.forgotPassword, child: (_) => const ForgotPasswordPage());
    r.child(AppRoutes.changePassword, child: (_) => const ChangePasswordPage());
    r.child(AppRoutes.mfaVerify, child: (_) => const MfaVerificationPage());
    r.child(AppRoutes.allInvestments, child: (_) => const AllInvestmentsPage());
    r.child(AppRoutes.marketplace, child: (_) => const MarketplacePage());
    r.child(
      AppRoutes.transactionPage,
      child: (_) {
        final payload = Modular.args.data as Map<String, dynamic>;
        final TransactionType type = payload['type'];
        final String id = payload['id'];
        return TokenTransactionPage(type: type, id: id);
      },
    );
    r.child(AppRoutes.settings, child: (_) => const SettingsPage());

    r.child(
      AppRoutes.startupDetailsPage,
      child: (_) {
        final startup = Modular.args.data as Map<String, dynamic>;
        return StartupDetailsPage(startup: startup);
      },
    );
    r.child(AppRoutes.settings, child: (_) => const SettingsPage());
  }
}
