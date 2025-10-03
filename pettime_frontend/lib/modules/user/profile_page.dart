import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/api_config.dart';
import '../../core/utils/validators.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Simulação de dados vindos da API
  String originalNome = 'Murilo vinhal';
  String originalEmail = 'fulanodetal@gmail.com';
  String originalTelefone = '(64)9999-9999';
  String originalEndereco =
      'Rua 06, Quadra 38, lote 03, número 8, bairro lotus';

  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();
  final novaSenhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;
  bool editando = false;
  bool alterarSenha = false;

  @override
  void initState() {
    super.initState();
    _buscarDadosUsuario();
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')?.replaceAll('\n', '').trim();
    print('Token carregado do SharedPreferences: $token'); // DEBUG
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _buscarDadosUsuario() async {
    final headers = await _getHeaders();
    if (!headers.containsKey('Authorization')) {
      print('Token ausente, não buscar dados do usuário.'); // DEBUG
      return; // Não redireciona imediatamente, apenas não busca
    }
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/me'),
        headers: headers,
      );
      print(
        'Resposta /usuarios/me: ${response.statusCode} ${response.body}',
      ); // DEBUG
      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);
        setState(() {
          originalNome = dados['nome'] ?? '';
          originalEmail = dados['email'] ?? '';
          originalTelefone = dados['telefone'] ?? '';
          originalEndereco = dados['endereco'] ?? '';
          nomeController.text = originalNome;
          emailController.text = originalEmail;
          telefoneController.text = originalTelefone;
          enderecoController.text = originalEndereco;
        });
      } else {
        String msg = 'Erro ao buscar dados do usuário.';
        try {
          final erro = jsonDecode(response.body);
          if (erro['erro'] != null) msg += '\n${erro['erro']}';
          if (erro['message'] != null) msg += '\n${erro['message']}';
        } catch (_) {}
        _mostrarErro(msg);
      }
    } catch (e) {
      print('Erro de conexão ao buscar dados do usuário: $e'); // DEBUG
      _mostrarErro('Erro de conexão ao buscar dados do usuário.');
    }
    novaSenhaController.clear();
    confirmarSenhaController.clear();
  }

  void _mostrarErro(String mensagem) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
      // Só redireciona para login se for erro de sessão expirada
      if (mensagem.contains('Sessão expirada')) {
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  void iniciarEdicao() {
    setState(() => editando = true);
  }

  void cancelarEdicao() {
    setState(() {
      editando = false;
    });
    _buscarDadosUsuario();
  }

  void finalizarEdicao() async {
    if (_formKey.currentState!.validate()) {
      setState(() => carregando = true);
      final headers = await _getHeaders();
      final body = jsonEncode({
        'nome': nomeController.text,
        'email': emailController.text,
        'telefone': telefoneController.text,
        'endereco': enderecoController.text,
        if (alterarSenha && novaSenhaController.text.isNotEmpty)
          'senha': novaSenhaController.text,
      });
      try {
        final response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/usuarios/me'),
          headers: headers,
          body: body,
        );
        if (response.statusCode == 200) {
          setState(() {
            carregando = false;
            editando = false;
            originalNome = nomeController.text;
            originalEmail = emailController.text;
            originalTelefone = telefoneController.text;
            originalEndereco = enderecoController.text;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cadastro atualizado com sucesso!')),
          );
        } else if (response.statusCode == 401) {
          _mostrarErro('Sessão expirada ou inválida. Faça login novamente.');
        } else {
          _mostrarErro('Erro ao atualizar cadastro.');
        }
      } catch (e) {
        _mostrarErro('Erro de conexão ao atualizar cadastro.');
      }
    }
  }

  void excluirUsuario() async {
    final headers = await _getHeaders();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir cadastro'),
        content: Text(
          'Tem certeza que deseja excluir seu cadastro? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await http.delete(
                  Uri.parse('${ApiConfig.baseUrl}/usuarios/me'),
                  headers: headers,
                );
                if (response.statusCode == 200 || response.statusCode == 204) {
                  // Remover token e id do usuário (logout)
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  await prefs.remove('usuarioId');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Cadastro excluído!')));
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir cadastro.')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro de conexão ao excluir cadastro.'),
                  ),
                );
              }
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String? _validarSenha(String? value) {
    // Se os campos de senha estão sendo preenchidos, aplica validações
    if (novaSenhaController.text.isNotEmpty ||
        confirmarSenhaController.text.isNotEmpty) {
      // Valida a nova senha com os critérios rigorosos
      String? erroSenha = FormValidator.validarSenha(novaSenhaController.text);
      if (erroSenha != null) {
        return erroSenha;
      }

      // Valida confirmação de senha
      String? erroConfirmacao = FormValidator.validarConfirmacaoSenha(
        novaSenhaController.text,
        confirmarSenhaController.text,
      );
      if (erroConfirmacao != null) {
        return erroConfirmacao;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 4,
        shadowColor: Colors.blue.shade200,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                'Dados do usuário',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: editando ? null : iniciarEdicao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Editar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: excluirUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Excluir'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nomeController,
                enabled: editando,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                enabled: editando,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o e-mail' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: telefoneController,
                enabled: editando,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o telefone'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: enderecoController,
                enabled: editando,
                decoration: InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe o endereço'
                    : null,
              ),
              const SizedBox(height: 16),
              if (editando)
                CheckboxListTile(
                  title: const Text('Alterar senha'),
                  value: alterarSenha,
                  onChanged: (value) {
                    setState(() {
                      alterarSenha = value ?? false;
                      if (!alterarSenha) {
                        novaSenhaController.clear();
                        confirmarSenhaController.clear();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              if (editando && alterarSenha) ...[
                TextFormField(
                  controller: novaSenhaController,
                  enabled: editando,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validarSenha(value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmarSenhaController,
                  enabled: editando,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => _validarSenha(value),
                ),
              ],
              const SizedBox(height: 32),
              if (editando)
                carregando
                    ? Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: finalizarEdicao,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Finalizar edição'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: cancelarEdicao,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                          ),
                        ],
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
