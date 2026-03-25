// feito por marcelo

import 'package:flutter_client/core/app_settings.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';

class AppModule extends Module {

  @override
  void binds(i) 
  {
    i.addSingleton(() => Dio(
      BaseOptions(
        baseUrl: AppSettings.baseUrl,
        sendTimeout: Duration( milliseconds: AppSettings.timeout),
        connectTimeout: Duration( milliseconds: AppSettings.timeout),
        receiveTimeout: Duration( milliseconds: AppSettings.timeout),
      )
    ));
  }

}
