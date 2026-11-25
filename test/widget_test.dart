
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_city/main.dart';
import 'package:smart_city/presentation/providers/app_provider.dart';

void main() {
  testWidgets(
    'Smart City ilovasi ochilishi',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppProvider(),
          child: const SmartCityApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('SMART CITY'), findsOneWidget);
      expect(find.text('Xush kelibsiz!'), findsOneWidget);
      expect(find.text('Muammo yuborish'), findsOneWidget);
    },
  );
}