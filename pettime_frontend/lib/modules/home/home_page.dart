import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'edit_pet_page.dart';
import '../../core/utils/api_config.dart';
import 'agendamento_page.dart';
import 'historico_agendamentos_page.dart';
import 'notificacoes_page.dart';
import '../../shared/widgets/notification_badge.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> pets = [];
  bool carregando = true;
  int _notifTick = 0;

  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    setState(() => carregando = true);
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');
    if (usuarioId == null) return;
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets?usuarioId=$usuarioId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        pets = data
            .cast<Map<String, dynamic>>()
            .where((pet) => pet['deletado'] != true)
            .toList();
        carregando = false;
      });
    } else {
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
        title: Text('PetTime', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          NotificationBadge(
            refreshTick: _notifTick,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificacoesPage()),
              );
              if (mounted) setState(() => _notifTick++);
            },
            child: IconButton(
              icon: Icon(Icons.notifications, size: 28),
              tooltip: 'Notificações',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificacoesPage()),
                );
                if (mounted) setState(() => _notifTick++);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.account_circle_rounded, size: 30),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, size: 28),
            tooltip: 'Sair',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('usuarioId');
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
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Seus Pets',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                              icon: Icon(Icons.history),
                              label: Text('Histórico'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                textStyle: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        pets.isEmpty
                            ? const Text('Nenhum pet cadastrado.')
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: pets.length,
                                separatorBuilder: (_, __) => Divider(),
                                itemBuilder: (context, index) {
                                  final pet = pets[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade50,
                                      backgroundImage:
                                          (pet['foto'] != null &&
                                              pet['foto'].toString().isNotEmpty)
                                          ? NetworkImage(
                                              '${ApiConfig.baseUrl}${pet['foto']}',
                                            )
                                          : null,
                                      child:
                                          (pet['foto'] == null ||
                                              pet['foto'].toString().isEmpty)
                                          ? Icon(
                                              Icons.pets,
                                              color: Colors.black,
                                            )
                                          : null,
                                    ),
                                    title: Text(pet['nome'] ?? ''),
                                    subtitle: Text(
                                      'Raça: ${pet['raca'] ?? ''}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => _abrirEdicaoPet(pet),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _excluirPet(pet),
                                        ),
                                      ],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: ''),
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
    );
  }
}
