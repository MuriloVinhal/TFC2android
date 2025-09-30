import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_config.dart';

class PresilhasListPage extends StatefulWidget {
  const PresilhasListPage({Key? key}) : super(key: key);

  @override
  State<PresilhasListPage> createState() => _PresilhasListPageState();
}

class _PresilhasListPageState extends State<PresilhasListPage> {
  List<Map<String, dynamic>> presilhas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPresilhas();
  }

  Future<void> _carregarPresilhas() async {
    setState(() => carregando = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/produtos?tipo=1'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          presilhas = data.cast<Map<String, dynamic>>();
          carregando = false;
        });
      } else {
        setState(() => carregando = false);
      }
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  Future<void> _excluirPresilha(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Presilha'),
        content: const Text('Tem certeza que deseja excluir esta presilha?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/produtos/$id'),
      );
      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presilha excluída com sucesso!')),
        );
        _carregarPresilhas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir presilha: ${response.body}')),
        );
      }
    }
  }

  void _editarPresilha(Map<String, dynamic> presilha) async {
    final atualizado = await Navigator.pushNamed(
      context,
      '/presilhas/cadastro',
      arguments: presilha,
    );
    if (atualizado == true) {
      _carregarPresilhas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Presilhas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final cadastrado = await Navigator.pushNamed(
                    context,
                    '/presilhas/cadastro',
                  );
                  if (cadastrado == true) {
                    _carregarPresilhas();
                  }
                },
                child: const Text('Adicionar'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : presilhas.isEmpty
                  ? const Center(child: Text('Nenhuma presilha cadastrada.'))
                  : ListView.separated(
                      itemCount: presilhas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final presilha = presilhas[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      presilha['imagem'] != null &&
                                          presilha['imagem']
                                              .toString()
                                              .isNotEmpty
                                      ? Image.network(
                                          '${ApiConfig.baseUrl}${presilha['imagem']}',
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.emoji_emotions,
                                          size: 48,
                                          color: Colors.pink,
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    presilha['descricao'] ?? '',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _excluirPresilha(presilha['id']),
                                        child: const Text('Excluir'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Colors.blue,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _editarPresilha(presilha),
                                        child: const Text(
                                          'Editar',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
