// feito por marcelo
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'app_module.dart';
import 'app_widget.dart';
import 'firebase_options.dart';

void main() {
  final startupError = ValueNotifier<String?>(null);

  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        startupError.value = details.exceptionAsString();
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        startupError.value = error.toString();
        return true;
      };

      runApp(_BootstrapApp(startupError: startupError));
    },
    (error, stackTrace) {
      startupError.value = error.toString();
    },
  );
}

class _BootstrapApp extends StatelessWidget {
  const _BootstrapApp({required this.startupError});

  final ValueNotifier<String?> startupError;

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (details) => Material(
      color: const Color(0xFFFCF8FF),
      child: _StartupStateScreen(
        title: 'Erro na interface',
        subtitle: details.exceptionAsString(),
      ),
    );

    return ValueListenableBuilder<String?>(
      valueListenable: startupError,
      builder: (context, errorMessage, child) {
        if (errorMessage != null && errorMessage.isNotEmpty) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _StartupStateScreen(
              title: 'O app encontrou um erro',
              subtitle: errorMessage,
            ),
          );
        }

        return FutureBuilder<FirebaseApp>(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: _StartupStateScreen(
                  title: 'Carregando MesclaInvest...',
                  subtitle: 'Inicializando a aplicação.',
                  loading: true,
                ),
              );
            }

            if (snapshot.hasError) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: _StartupStateScreen(
                  title: 'Não foi possível iniciar o app',
                  subtitle: '${snapshot.error}',
                ),
              );
            }

            return ModularApp(module: AppModule(), child: const AppWidget());
          },
        );
      },
    );
  }
}

class _StartupStateScreen extends StatelessWidget {
  const _StartupStateScreen({
    required this.title,
    required this.subtitle,
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF170B58),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF584048),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
