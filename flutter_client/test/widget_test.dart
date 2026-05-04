//feito por marcelo
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_client/app_module.dart';
import 'package:flutter_client/app_widget.dart';

void main() {
  testWidgets('Teste', (WidgetTester tester) async {
    await tester.pumpWidget(ModularApp(
      module: AppModule(),
      child: const AppWidget(),
    ));

    expect(find.byType(AppWidget), findsOneWidget);
  });
}
