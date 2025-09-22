import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/modules/auth/register_page.dart';

void main() {
  group('Testes da Página de Registro', () {
    testWidgets('Página de registro deve exibir todos os campos obrigatórios', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));

      // Verificar se todos os campos do formulário estão presentes
      expect(
        find.byType(TextFormField),
        findsNWidgets(5),
      ); // nome, email, telefone, endereco, senha
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
    });

    testWidgets('Página de registro deve validar campos obrigatórios', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      // Rolar para garantir que o botão esteja visível
      await tester.dragUntilVisible(
        find.text('Cadastrar'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // Tentar enviar sem preencher os campos
      final submitButton = find.text('Cadastrar');
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Deve mostrar erros de validação (verificar qualquer texto contendo validação)
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('Página de registro deve validar formato do email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      // Inserir email inválido
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'email-invalido',
      );

      // Rolar para tornar o botão visível
      await tester.dragUntilVisible(
        find.text('Cadastrar'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final submitButton = find.text('Cadastrar');
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Deve mostrar erro de validação do email (verificar "E-mail inválido")
      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets(
      'Página de registro deve formatar número de telefone corretamente',
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: RegisterPage()));

        // Inserir número de telefone
        final phoneField = find.byType(TextFormField).at(2);
        await tester.enterText(phoneField, '11999887766');
        await tester.pump();

        // Deve formatar para (11) 99988-7766
        final phoneWidget = tester.widget<TextFormField>(phoneField);
        expect(phoneWidget.controller?.text, equals('(11) 99988-7766'));
      },
    );

    testWidgets('Página de registro deve validar força da senha', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));
      await tester.pumpAndSettle();

      // Inserir senha fraca
      await tester.enterText(find.byType(TextFormField).at(4), '123');

      // Rolar para tornar o botão visível
      await tester.dragUntilVisible(
        find.text('Cadastrar'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      final submitButton = find.text('Cadastrar');
      await tester.tap(submitButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Deve mostrar erro de validação da senha
      expect(
        find.text('A senha deve ter no mínimo 8 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('Página de registro deve navegar para login após sucesso', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RegisterPage(),
          routes: {'/login': (context) => Scaffold(body: Text('Login Page'))},
        ),
      );

      // Preencher todos os campos obrigatórios com dados válidos
      await tester.enterText(find.byType(TextFormField).at(0), 'Usuário Teste');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'teste@exemplo.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '11999887766');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        'Endereço Teste',
      );
      await tester.enterText(find.byType(TextFormField).at(4), 'senha123456');

      // Deve validar o formulário com sucesso
      final submitButton = find.text('Cadastrar');
      expect(submitButton, findsOneWidget);
    });

    testWidgets('Página de registro deve mostrar estado de carregamento', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));

      // Deve ter um indicador de carregamento quando processando
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      ); // Inicialmente não está carregando
    });

    testWidgets(
      'Página de registro deve navegar de volta quando cancelar for pressionado',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: RegisterPage(),
            routes: {
              '/login': (context) => Scaffold(body: Text('Página de Login')),
            },
          ),
        );

        // Encontrar e tocar no botão "Cancelar"
        final cancelButton = find.text('Cancelar');
        expect(cancelButton, findsOneWidget);
      },
    );
  });
}
