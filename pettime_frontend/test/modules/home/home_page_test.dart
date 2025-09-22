import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/modules/home/home_page.dart';
import 'package:pettime_frontend/shared/widgets/notification_badge.dart';

void main() {
  group('Testes da Página Principal', () {
    testWidgets('Página principal deve exibir barra de app com título', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Verificar barra de app e título
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('PetTime'), findsOneWidget);
    });

    testWidgets(
      'Página principal deve mostrar indicador de carregamento inicialmente',
      (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(home: HomePage()));

        // Deve mostrar indicador de carregamento
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('Página principal deve exibir botão de ação flutuante', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Verificar FAB para adicionar novo pet
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Página principal deve ter barra de navegação inferior', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Verificar navegação inferior
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Pets'), findsOneWidget);
      expect(find.text('Agendamentos'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('Página principal deve exibir distintivo de notificação', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Verificar elementos de notificação
      expect(find.byType(NotificationBadge), findsOneWidget);
    });

    testWidgets('Página principal deve lidar com lista vazia de pets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Aguardar carregamento completar
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Deve lidar com estado vazio graciosamente
      expect(find.text('Nenhum pet cadastrado'), findsOneWidget);
    });

    testWidgets('Página principal deve navegar para página de adicionar pet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
          routes: {
            '/register-pet': (context) =>
                Scaffold(body: Text('Página Registrar Pet')),
          },
        ),
      );

      // Tocar no FAB para adicionar novo pet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Deve navegar para página de registrar pet
      expect(find.text('Página Registrar Pet'), findsOneWidget);
    });

    testWidgets('Página principal deve navegar para página de perfil', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
          routes: {
            '/profile': (context) => Scaffold(body: Text('Página de Perfil')),
          },
        ),
      );

      // Tap profile tab
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      // Should navigate to profile page
      expect(find.text('Profile Page'), findsOneWidget);
    });

    testWidgets('HomePage should navigate to appointments history', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(),
          routes: {
            '/historico': (context) => Scaffold(body: Text('History Page')),
          },
        ),
      );

      // Tap appointments tab
      await tester.tap(find.text('Agendamentos'));
      await tester.pumpAndSettle();

      // Should navigate to history page
      expect(find.text('History Page'), findsOneWidget);
    });

    testWidgets('HomePage should display pets when loaded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Wait for loading
      await tester.pump();

      // Should show pets list or empty message
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('HomePage should handle refresh action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), Offset(0, 300));
      await tester.pump();

      // Should trigger refresh
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('HomePage should show pet cards correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Wait for potential pets to load
      await tester.pumpAndSettle();

      // Verify card structure exists
      expect(find.byType(Card), findsWidgets);
    });
  });
}
