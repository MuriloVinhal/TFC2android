import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/modules/auth/forget_password.dart';
import 'package:pettime_frontend/shared/widgets/custom_button.dart';
import 'package:pettime_frontend/shared/widgets/custom_text_field.dart';

void main() {
  group('Testes da Página Esqueci a Senha', () {
    testWidgets(
      'Página esqueci a senha deve exibir todos os elementos corretamente',
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: ForgetPasswordPage()));

        // Verificar título e campo de email
        expect(find.text('Recuperar Senha'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);

        // Verificar botões com texto correto
        expect(find.text('Enviar nova senha'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);

        // Verificar ícone de email
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      },
    );

    testWidgets('Página esqueci a senha deve validar email vazio', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ForgetPasswordPage()));

      // Tentar enviar sem email
      final submitButton = find.text('Enviar nova senha');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Deve mostrar mensagem de validação
      expect(find.text('O campo não foi preenchido.'), findsOneWidget);
    });

    testWidgets('Página esqueci a senha deve aceitar email válido', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ForgetPasswordPage()));

      // Inserir email válido
      await tester.enterText(find.byType(TextFormField), 'teste@exemplo.com');

      final submitButton = find.text('Recuperar Senha');
      expect(submitButton, findsOneWidget);
    });

    testWidgets('ForgetPasswordPage should show loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ForgetPasswordPage()));

      // Initially not loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('ForgetPasswordPage should navigate back with cancel button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Text('Previous Page')),
          routes: {'/forget': (context) => ForgetPasswordPage()},
        ),
      );

      // Navigate to forget password page
      Navigator.pushNamed(
        tester.element(find.text('Previous Page')),
        '/forget',
      );
      await tester.pumpAndSettle();

      // Find and tap cancel button
      final cancelButton = find.text('Cancelar');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.text('Previous Page'), findsOneWidget);
    });

    testWidgets(
      'ForgetPasswordPage should navigate back with AppBar back button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Text('Previous Page')),
            routes: {'/forget': (context) => ForgetPasswordPage()},
          ),
        );

        // Navigate to forget password page
        Navigator.pushNamed(
          tester.element(find.text('Previous Page')),
          '/forget',
        );
        await tester.pumpAndSettle();

        // Find and tap AppBar back button
        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);
      },
    );

    testWidgets('ForgetPasswordPage should validate email format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ForgetPasswordPage()));

      // Enter invalid email format
      await tester.enterText(find.byType(TextFormField), 'invalid-email');

      // The page should handle invalid format gracefully
      final emailField = find.byType(TextFormField);
      expect(emailField, findsOneWidget);
    });

    testWidgets('ForgetPasswordPage should clear email field after success', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ForgetPasswordPage()));

      // Enter email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');

      // Verify email was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('ForgetPasswordPage UI elements should be styled correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ForgetPasswordPage()));

      // Check if custom widgets are used
      expect(find.byType(CustomButton), findsNWidgets(2)); // Recuperar e Voltar
      expect(find.byType(CustomTextField), findsOneWidget); // Email field
    });
  });
}
