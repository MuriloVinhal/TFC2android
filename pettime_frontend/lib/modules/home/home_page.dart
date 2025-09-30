import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'edit_pet_page.dart';
import '../../core/utils/api_config.dart';
import 'agendamento_page.dart';
import 'historico_agendamentos_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pets = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    setState(() => carregando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('user_id'); // Corrigido para user_id

      if (usuarioId == null) {
        print('❌ usuarioId não encontrado no SharedPreferences');
        setState(() => carregando = false);
        return;
      }

      print('📱 Carregando pets para usuário: $usuarioId');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pets?usuarioId=$usuarioId'),
      );

      print('📱 Status response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          pets = data
              .cast<Map<String, dynamic>>()
              .where((pet) => pet['deletado'] != true)
              .toList();
          carregando = false;
        });
        print('✅ ${pets.length} pets carregados');
      } else {
        print('❌ Erro ao carregar pets: ${response.statusCode}');
        setState(() => carregando = false);
      }
    } catch (e) {
      print('❌ Erro de conexão ao carregar pets: $e');
      setState(() => carregando = false);
    }
  }

  void _abrirEdicaoPet(Map<String, dynamic> pet) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPetPage(pet: pet)),
    );
    if (atualizado == true) {
      _carregarPets();
    }
  }

  Future<void> _excluirPet(Map<String, dynamic> pet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Pet'),
        content: const Text('Tem certeza que deseja excluir este pet?'),
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
        Uri.parse('${ApiConfig.baseUrl}/pets/${pet['id']}'),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet excluído com sucesso!')),
        );
        _carregarPets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir pet: \n${response.body}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PetTime',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle_rounded,
              size: 30,
              color: Colors.white,
            ),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, size: 28, color: Colors.white),
            tooltip: 'Sair',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('jwt_token');
              await prefs.remove('user_id');
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade50, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.pets_rounded,
                                  color: Colors.blue,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Seus Pets',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HistoricoAgendamentosPage(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.history_rounded, size: 18),
                              label: Text('Histórico'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        pets.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.pets_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Nenhum pet cadastrado.',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: pets.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final pet = pets[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(12),
                                      leading: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.blue.shade50,
                                        backgroundImage:
                                            (pet['foto'] != null &&
                                                pet['foto']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? NetworkImage(
                                                '${ApiConfig.baseUrl}${pet['foto']}',
                                              )
                                            : null,
                                        child:
                                            (pet['foto'] == null ||
                                                pet['foto'].toString().isEmpty)
                                            ? Icon(
                                                Icons.pets_rounded,
                                                color: Colors.blue,
                                                size: 28,
                                              )
                                            : null,
                                      ),
                                      title: Text(
                                        pet['nome'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Raça: ${pet['raca'] ?? ''}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.edit_rounded,
                                                color: Colors.blue.shade600,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _abrirEdicaoPet(pet),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red.shade600,
                                                size: 20,
                                              ),
                                              onPressed: () => _excluirPet(pet),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Outras seções futuras aqui
                ],
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 26),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded, size: 24),
              label: 'Agendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets_rounded, size: 26),
              label: 'Novo Pet',
            ),
          ],
          onTap: (index) async {
            if (index == 1) {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AgendamentoPage()),
              );
            } else if (index == 2) {
              final cadastrado = await Navigator.pushNamed(
                context,
                '/register-pet',
              );
              if (cadastrado == true) {
                _carregarPets();
              }
            }
          },
        ),
      ),
    );
  }
}
