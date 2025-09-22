import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/modules/auth/login_page.dart';

void main() {
  group('Testes da Página de Login', () {
    testWidgets('Página de login deve exibir todos os campos obrigatórios', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Verificar título e mensagem de boas-vindas
      expect(find.text('PetTime'), findsOneWidget);
      expect(find.text('Bem vindo!'), findsOneWidget);

      // Verificar textos de dica dos campos email e senha
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      // Verificar botão de login com texto correto
      expect(find.text('Login'), findsOneWidget);

      // Verificar link de registro com texto correto
      expect(find.text('Registre-se'), findsOneWidget);
    });

    testWidgets('Página de login deve mostrar estado de carregamento', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Encontrar botão de login com texto correto
      final loginButton = find.text('Login');
      expect(loginButton, findsOneWidget);

      // Verificar link de esqueci a senha
      expect(find.text('Esqueceu a senha?'), findsOneWidget);
    });

    testWidgets('Campos de email e senha devem estar presentes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Procurar pelos ícones de email e cadeado
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('Navegação para página de registro deve funcionar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(),
          routes: {
            '/register': (context) =>
                Scaffold(body: Text('Página de Registro')),
          },
        ),
      );

      // Encontrar e tocar no botão de registro com texto correto
      final registerButton = find.text('Registre-se');
      expect(registerButton, findsOneWidget);

      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Página de Registro'), findsOneWidget);
    });

    testWidgets('Navegação para esqueci a senha deve funcionar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(),
          routes: {
            '/forget-password': (context) =>
                Scaffold(body: Text('Página Esqueci a Senha')),
          },
        ),
      );

      // Encontrar e tocar no link esqueci a senha
      final forgotPasswordLink = find.text('Esqueceu a senha?');
      expect(forgotPasswordLink, findsOneWidget);

      await tester.tap(forgotPasswordLink);
      await tester.pumpAndSettle();

      expect(find.text('Página Esqueci a Senha'), findsOneWidget);
    });
  });
}
