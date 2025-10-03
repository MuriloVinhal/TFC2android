import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/api_config.dart';
import '../../core/utils/error_handler.dart';
import '../../core/utils/validators.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();
  final senhaController = TextEditingController();

  final telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool carregando = false;

  Future<void> cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/register');
    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'telefone': telefoneFormatter.getUnmaskedText(),
          'endereco': enderecoController.text.trim(),
          'senha': senhaController.text.trim(),
        }),
      );
      print('Status:  [200m${resposta.statusCode} [0m');
      print('Body:  [200m${resposta.body} [0m');
      setState(() => carregando = false);
      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        Navigator.pop(context);
      } else {
        final erro = jsonDecode(resposta.body);
        final mensagemErro = ErrorHandler.extractErrorMessage(
          erro,
          'Erro ao cadastrar',
        );

        print('Erro ao cadastrar: ${resposta.statusCode} - ${resposta.body}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensagemErro)));
      }
    } catch (e) {
      setState(() => carregando = false);
      final mensagemErro = ErrorHandler.handleConnectionError(e);
      print('Erro de conexão: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErro)));
    }
  }

  String? validarEmail(String? value) {
    if (value == null || value.isEmpty) return 'Informe um e-mail';
    if (!value.contains('@')) return 'E-mail inválido';
    return null;
  }

  String? validarTexto(String? value, String campo, {int min = 1}) {
    if (value == null || value.trim().length < min) {
      return '$campo deve ter no mínimo $min caracteres';
    }
    return null;
  }

  String? validarTelefone(String? value) {
    if (value == null || value.isEmpty) return 'Informe o telefone';
    if (!telefoneFormatter.isFill()) return 'Telefone incompleto';
    return null;
  }

  String? validarSenha(String? value) {
    return FormValidator.validarSenha(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
        centerTitle: true,
        title: const Text(
          'Cadastro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Título
                const SizedBox(height: 32),
                const Text(
                  'Criar Conta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Preencha os dados para se cadastrar',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Formulário
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Nome
                        CustomTextField(
                          controller: nomeController,
                          hintText: 'Nome completo',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => validarTexto(v, 'Nome'),
                        ),

                        const SizedBox(height: 16),

                        // Email
                        CustomTextField(
                          controller: emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: validarEmail,
                        ),

                        const SizedBox(height: 16),

                        // Telefone
                        CustomTextField(
                          controller: telefoneController,
                          hintText: 'Telefone',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.phone_outlined,
                          inputFormatters: [telefoneFormatter],
                          validator: validarTelefone,
                        ),

                        const SizedBox(height: 16),

                        // Endereço
                        CustomTextField(
                          controller: enderecoController,
                          hintText: 'Endereço',
                          prefixIcon: Icons.location_on_outlined,
                          validator: (v) => validarTexto(v, 'Endereço', min: 4),
                        ),

                        const SizedBox(height: 16),

                        // Senha
                        CustomTextField(
                          controller: senhaController,
                          hintText: 'Senha',
                          obscureText: true,
                          prefixIcon: Icons.lock_outlined,
                          validator: validarSenha,
                        ),

                        const SizedBox(height: 32),

                        // Botão de cadastro
                        CustomButton(
                          text: 'Cadastrar',
                          onPressed: cadastrar,
                          isLoading: carregando,
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

                        const SizedBox(height: 32),
                      ],
                    ),
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
