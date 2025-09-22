import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/shared/widgets/custom_button.dart';

void main() {
  group('Testes do Widget CustomButton', () {
    testWidgets('CustomButton deve exibir texto corretamente', (
      WidgetTester tester,
    ) async {
      const buttonText = 'Botão Teste';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: buttonText, onPressed: () {}),
          ),
        ),
      );

      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('CustomButton deve lidar com toque corretamente', (
      WidgetTester tester,
    ) async {
      bool foiTocado = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Toque em Mim',
              onPressed: () {
                foiTocado = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      await tester.pumpAndSettle();

      expect(foiTocado, isTrue);
    });

    testWidgets('CustomButton deve mostrar estado de carregamento', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Carregando',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CustomButton should be disabled when onPressed is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CustomButton(text: 'Disabled', onPressed: null)),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('CustomButton should display icon when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'With Icon',
              icon: Icons.star,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('CustomButton should apply custom styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Styled Button',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              width: 200,
              height: 60,
              borderRadius: 20,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<CustomButton>(find.byType(CustomButton));
      expect(button.backgroundColor, equals(Colors.red));
      expect(button.textColor, equals(Colors.white));
      expect(button.width, equals(200));
      expect(button.height, equals(60));
      expect(button.borderRadius, equals(20));
    });
  });
}
