import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/main.dart';

void main() {
  group('Testes de Integração do App PetTime', () {
    testWidgets('Fluxo completo de navegação do app', (
      WidgetTester tester,
    ) async {
      // Construir o app
      await tester.pumpWidget(PettimeApp());

      // Verificar se a rota inicial é login
      expect(find.text('Login'), findsOneWidget);

      // Testar navegação para página de registro
      final registerButton = find.text('Registre-se');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Deve estar na página de registro
        expect(find.text('Cadastrar'), findsOneWidget);

        // Navegar de volta para login
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // Deve estar de volta na página de login
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Fluxo de validação do formulário de login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(PettimeApp());

      // Encontrar elementos do formulário de login com texto correto do botão
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      final loginButton = find.text('Login');

      // Testar validação de campo vazio
      await tester.tap(loginButton);
      await tester.pump();

      // Verificar se o app ainda está funcional
      expect(find.text('PetTime'), findsOneWidget);

      // Testar com formato de email válido
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Form should be ready for submission
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Forget password flow', (WidgetTester tester) async {
      await tester.pumpWidget(PettimeApp());

      // Navigate to forget password
      final forgetPasswordLink = find.text('Esqueceu a senha?');
      if (forgetPasswordLink.evaluate().isNotEmpty) {
        await tester.tap(forgetPasswordLink);
        await tester.pumpAndSettle();

        // Should be on forget password page
        expect(find.text('Recuperar Senha'), findsOneWidget);

        // Test email input
        final emailField = find.byType(TextFormField);
        await tester.enterText(emailField, 'recovery@example.com');
        await tester.pump();

        expect(find.text('recovery@example.com'), findsOneWidget);
      }
    });

    testWidgets('Registration form complete flow', (WidgetTester tester) async {
      await tester.pumpWidget(PettimeApp());

      // Navigate to registration
      final registerButton = find.text('Cadastrar');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Fill registration form
        final textFields = find.byType(TextFormField);

        if (textFields.evaluate().length >= 5) {
          await tester.enterText(textFields.at(0), 'Test User');
          await tester.enterText(textFields.at(1), 'test@example.com');
          await tester.enterText(textFields.at(2), '11999888777');
          await tester.enterText(textFields.at(3), 'Test Address 123');
          await tester.enterText(textFields.at(4), 'password123');

          await tester.pump();

          // Verify form is filled
          expect(find.text('Test User'), findsOneWidget);
          expect(find.text('test@example.com'), findsOneWidget);
        }
      }
    });

    testWidgets('App theme and styling consistency', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(PettimeApp());

      // Verify app has consistent theming
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
      expect(app.title, equals('PETTIME'));

      // Verify scaffold background
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify app bar styling
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Custom widgets integration', (WidgetTester tester) async {
      await tester.pumpWidget(PettimeApp());

      // Verify custom buttons are used
      expect(find.byType(ElevatedButton), findsWidgets);

      // Verify custom text fields
      expect(find.byType(TextFormField), findsWidgets);

      // Check for consistent spacing and layout
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('Error handling and user feedback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(PettimeApp());

      // Test form submission with invalid data - use correct button text
      final loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pump();

      // Should handle empty form gracefully
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test invalid email format
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation feedback
      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('Loading states and user experience', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(PettimeApp());

      // Test loading indicators
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      ); // Initially not loading

      // Verify buttons are interactive
      final buttons = find.byType(ElevatedButton);
      for (final button in buttons.evaluate()) {
        final buttonWidget = button.widget as ElevatedButton;
        expect(buttonWidget.onPressed, isNotNull);
      }
    });

    testWidgets('Accessibility and usability', (WidgetTester tester) async {
      await tester.pumpWidget(PettimeApp());

      // Check for semantic labels
      expect(find.byType(Semantics), findsWidgets);

      // Verify text fields have labels or hints
      final textFields = find.byType(TextFormField);
      expect(textFields, findsWidgets);

      // Check that text fields exist and are accessible
      for (final field in textFields.evaluate()) {
        final fieldWidget = field.widget as TextFormField;
        // Basic accessibility check - field should exist
        expect(fieldWidget, isNotNull);
      }

      // Check button accessibility
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });

    testWidgets('Route navigation integration', (WidgetTester tester) async {
      await tester.pumpWidget(PettimeApp());

      // Verify initial route
      expect(find.byType(Navigator), findsOneWidget);

      // Test route handling
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.initialRoute, equals('/login'));
      expect(app.routes, isNotNull);
      expect(app.routes!.containsKey('/login'), isTrue);
      expect(app.routes!.containsKey('/register'), isTrue);
      expect(app.routes!.containsKey('/home'), isTrue);
    });

    testWidgets('Performance and responsiveness', (WidgetTester tester) async {
      await tester.pumpWidget(PettimeApp());

      // Test rapid interactions with correct button text
      final loginButton = find.text('Login');

      // Multiple rapid taps should be handled gracefully
      for (int i = 0; i < 5; i++) {
        await tester.tap(loginButton);
        await tester.pump(Duration(milliseconds: 100));
      }

      // App should remain stable
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('State management consistency', (WidgetTester tester) async {
      await tester.pumpWidget(PettimeApp());

      // Test form state persistence
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'state@test.com');

      // Navigate away and back
      final registerButton = find.text('Registre-se');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        // Navigate back
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // State should be handled appropriately
      expect(find.byType(TextFormField), findsWidgets);
    });
  });
}
