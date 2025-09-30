import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_config.dart';

class PerfumesListPage extends StatefulWidget {
  const PerfumesListPage({Key? key}) : super(key: key);

  @override
  State<PerfumesListPage> createState() => _PerfumesListPageState();
}

class _PerfumesListPageState extends State<PerfumesListPage> {
  List<Map<String, dynamic>> perfumes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfumes();
  }

  Future<void> _carregarPerfumes() async {
    setState(() => carregando = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/produtos?tipo=2'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          perfumes = data.cast<Map<String, dynamic>>();
          carregando = false;
        });
      } else {
        setState(() => carregando = false);
      }
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  Future<void> _excluirPerfume(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Perfume'),
        content: const Text('Tem certeza que deseja excluir este perfume?'),
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
          const SnackBar(content: Text('Perfume excluído com sucesso!')),
        );
        _carregarPerfumes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir perfume: ${response.body}')),
        );
      }
    }
  }

  void _editarPerfume(Map<String, dynamic> perfume) async {
    final atualizado = await Navigator.pushNamed(
      context,
      '/perfumes/cadastro',
      arguments: perfume,
    );
    if (atualizado == true) {
      _carregarPerfumes();
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
          'Perfumes',
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
                    '/perfumes/cadastro',
                  );
                  if (cadastrado == true) {
                    _carregarPerfumes();
                  }
                },
                child: const Text('Adicionar'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : perfumes.isEmpty
                  ? const Center(child: Text('Nenhum perfume cadastrado.'))
                  : ListView.separated(
                      itemCount: perfumes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final perfume = perfumes[index];
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
                                      perfume['imagem'] != null &&
                                          perfume['imagem']
                                              .toString()
                                              .isNotEmpty
                                      ? Image.network(
                                          '${ApiConfig.baseUrl}${perfume['imagem']}',
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.spa,
                                          size: 48,
                                          color: Colors.purple,
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
                                    perfume['descricao'] ?? '',
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
                                            _excluirPerfume(perfume['id']),
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
                                            _editarPerfume(perfume),
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
