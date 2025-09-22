import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pettime_frontend/main.dart';

void main() {
  group('Testes do Widget PettimeApp', () {
    testWidgets('App deve carregar com página de login', (
      WidgetTester tester,
    ) async {
      // Construir nosso app e disparar um frame
      await tester.pumpWidget(PettimeApp());

      // Verificar se o app carrega e mostra elementos de login
      expect(find.text('PETTIME'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Navegação do app deve funcionar corretamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(PettimeApp());

      // Verificar se a rota inicial é login
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
