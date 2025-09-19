import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/utils/api_config.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final emailController = TextEditingController();
  bool carregando = false;

  Future<void> recuperarSenha() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('O campo não foi preenchido.')));
      return;
    }

    setState(() => carregando = true);

    final resposta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios/recuperar-senha'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailController.text.trim()}),
    );

    setState(() => carregando = false);

    if (resposta.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Caso o e-mail esteja cadastrado no sistema, a nova senha estará disponível no e-mail.',
          ),
        ),
      );
      Navigator.pop(context);
    } else if (resposta.statusCode == 404) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('e-mail inexistente')));
    } else if (resposta.statusCode == 400) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('O campo não foi preenchido.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tentar recuperar senha.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Recuperar Senha',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Ícone e título
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Informe seu e-mail cadastrado para receber uma nova senha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Formulário
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

                    const SizedBox(height: 32),

                    // Botão de enviar
                    CustomButton(
                      text: 'Enviar nova senha',
                      onPressed: recuperarSenha,
                      isLoading: carregando,
                      icon: Icons.send,
                    ),

                    const SizedBox(height: 16),

                    // Botão cancelar
                    CustomButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
