import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/push_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../core/utils/api_config.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;
  bool senhaVisivel = false;

  Future<void> fazerLogin() async {
    setState(() => carregando = true);

    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/login');
    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'senha': senhaController.text.trim(),
        }),
      );
      print('Status:  [200m${resposta.statusCode} [0m');
      print('Body:  [200m${resposta.body} [0m');
      setState(() => carregando = false);
      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        final tipo = dados['usuario']['tipo'];
        final token = dados['token'].toString(); // Converter para String
        print('Token recebido do backend: $token'); // DEBUG
        final usuarioId = dados['usuario']['id'];

        // Salvar token e id do usuário no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final tokenLimpo = token
            .replaceAll('\n', '')
            .replaceAll('\r', '')
            .replaceAll(' ', '');
        await prefs.setString('jwt_token', tokenLimpo);
        await prefs.setInt('user_id', usuarioId);
        print('Token salvo no SharedPreferences: $tokenLimpo'); // DEBUG

        // Enviar token FCM para o backend (converter usuarioId para String)
        await PushService.sendTokenToBackend(usuarioId.toString());

        // Redirecionar baseado no tipo de usuário
        if (tipo == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-home');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        final erro = jsonDecode(resposta.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro['error'] ?? 'Erro desconhecido')),
        );
      }
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro de conexão: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
              children: [
                // Logo e título
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'PetTime',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bem vindo!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Formulário de login
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Campo de email
                      CustomTextField(
                        controller: emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      // Campo de senha
                      CustomTextField(
                        controller: senhaController,
                        hintText: 'Senha',
                        obscureText: true,
                        prefixIcon: Icons.lock_outlined,
                      ),

                      const SizedBox(height: 8),

                      // Link "Esqueceu a senha?"
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forget-password');
                          },
                          child: const Text(
                            'Esqueceu a senha?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botão de login
                      CustomButton(
                        text: 'Login',
                        onPressed: fazerLogin,
                        isLoading: carregando,
                      ),

                      const SizedBox(height: 24),

                      // Link para registro
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não possui cadastro? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'Registre-se',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
