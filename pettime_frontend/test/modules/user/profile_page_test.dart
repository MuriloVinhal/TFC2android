import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/modules/user/profile_page.dart';

void main() {
  group('Testes da Página de Perfil', () {
    testWidgets(
      'Página de perfil deve exibir formulário de perfil do usuário',
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: ProfilePage()));

        // Verificar barra de app
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Meu Perfil'), findsOneWidget);

        // Verificar se os campos do formulário estão presentes
        expect(
          find.byType(TextFormField),
          findsNWidgets(4),
        ); // nome, email, telefone, endereco
      },
    );

    testWidgets('Página de perfil deve ter botão de editar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));

      // Aguardar página carregar
      await tester.pumpAndSettle();

      // Verificar botão de editar
      expect(find.text('Editar'), findsOneWidget);
    });

    testWidgets('Página de perfil deve habilitar modo de edição', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      // Tocar no botão de editar
      await tester.tap(find.text('Editar'));
      await tester.pump();

      // Deve mostrar botões de salvar e cancelar
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets(
      'Página de perfil deve validar campos obrigatórios no modo de edição',
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: ProfilePage()));
        await tester.pumpAndSettle();

        // Enter edit mode
        await tester.tap(find.text('Editar'));
        await tester.pump();

        // Clear a required field
        await tester.enterText(find.byType(TextFormField).first, '');

        // Try to save
        await tester.tap(find.text('Salvar'));
        await tester.pump();

        // Should show validation error
        expect(find.text('Campo obrigatório'), findsOneWidget);
      },
    );

    testWidgets('ProfilePage should validate email format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Editar'));
      await tester.pump();

      // Enter invalid email
      final emailField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'invalid-email');

      // Try to save
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      // Should show email validation error
      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('ProfilePage should have password change option', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Editar'));
      await tester.pump();

      // Should have password change option
      expect(find.text('Alterar Senha'), findsOneWidget);
    });

    testWidgets(
      'ProfilePage should show password fields when changing password',
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: ProfilePage()));
        await tester.pumpAndSettle();

        // Enter edit mode
        await tester.tap(find.text('Editar'));
        await tester.pump();

        // Enable password change
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Should show password fields
        expect(find.text('Nova Senha'), findsOneWidget);
        expect(find.text('Confirmar Senha'), findsOneWidget);
      },
    );

    testWidgets('ProfilePage should validate password confirmation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Editar'));
      await tester.pump();

      // Enable password change
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Enter mismatched passwords
      await tester.enterText(find.text('Nova Senha'), 'password123');
      await tester.enterText(find.text('Confirmar Senha'), 'different123');

      // Try to save
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      // Should show password confirmation error
      expect(find.text('Senhas não conferem'), findsOneWidget);
    });

    testWidgets('ProfilePage should cancel editing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Editar'));
      await tester.pump();

      // Make some changes
      await tester.enterText(find.byType(TextFormField).first, 'Changed Name');

      // Cancel editing
      await tester.tap(find.text('Cancelar'));
      await tester.pump();

      // Should return to view mode
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Salvar'), findsNothing);
    });

    testWidgets('ProfilePage should show loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ProfilePage should format phone number correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.text('Editar'));
      await tester.pump();

      // Enter phone number
      final phoneField = find.byType(TextFormField).at(2);
      await tester.enterText(phoneField, '11999887766');
      await tester.pump();

      // Should format phone number
      final phoneWidget = tester.widget<TextFormField>(phoneField);
      expect(phoneWidget.controller?.text, contains('('));
      expect(phoneWidget.controller?.text, contains(')'));
      expect(phoneWidget.controller?.text, contains('-'));
    });

    testWidgets('ProfilePage should have logout option', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePage(),
          routes: {'/login': (context) => Scaffold(body: Text('Login Page'))},
        ),
      );
      await tester.pumpAndSettle();

      // Should have logout button
      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('ProfilePage should navigate to login on logout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePage(),
          routes: {'/login': (context) => Scaffold(body: Text('Login Page'))},
        ),
      );
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Should navigate to login
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
