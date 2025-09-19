import 'package:flutter/material.dart';
import 'modules/auth/login_page.dart';
import 'modules/auth/register_page.dart';
import 'modules/auth/forget_password.dart'; // Importe a página de redefinição de senha
import 'modules/home/home_page.dart';
import 'modules/user/profile_page.dart';
import 'modules/home/register_pet_page.dart';
import 'modules/home/admin_home_page.dart';
import 'modules/home/presilhas_list_page.dart';
import 'modules/home/presilhas_cadastro_page.dart';
import 'modules/home/perfumes_list_page.dart';
import 'modules/home/perfumes_cadastro_page.dart';
import 'modules/home/admin_agendamentos_page.dart';
import 'modules/home/admin_historico_page.dart';
import 'data/services/push_service.dart';
import 'modules/home/notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushService.init();
  runApp(PettimeApp());
}

class PettimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PETTIME',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forget-password': (context) =>
            ForgetPasswordPage(), // Adicione esta linha
        '/home': (context) => HomePage(), // Adicionada a rota home
        '/profile': (context) =>
            ProfilePage(), // Adicionada a rota de edição de cadastro
        '/register-pet': (context) =>
            RegisterPetPage(), // Nova rota de cadastro de pet
        '/admin-home': (context) => AdminHomePage(), // Home do admin
        '/presilhas': (context) => PresilhasListPage(), // Listagem de presilhas
        '/presilhas/cadastro': (context) =>
            PresilhasCadastroPage(), // Cadastro de presilhas
        '/perfumes': (context) => PerfumesListPage(), // Listagem de perfumes
        '/perfumes/cadastro': (context) =>
            PerfumesCadastroPage(), // Cadastro/edição de perfumes
        '/admin-agendamentos': (context) =>
            AdminAgendamentosPage(), // Agendamentos do admin
        '/admin-historico': (context) =>
            AdminHistoricoPage(), // Histórico do admin
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}
