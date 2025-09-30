import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/api_config.dart';
import 'package:intl/intl.dart';

class AdminHistoricoPage extends StatefulWidget {
  @override
  _AdminHistoricoPageState createState() => _AdminHistoricoPageState();
}

class _AdminHistoricoPageState extends State<AdminHistoricoPage> {
  List<Map<String, dynamic>> todosAgendamentos = [];
  List<Map<String, dynamic>> agendamentosFiltrados = [];
  bool isLoading = true;
  String filtroStatus = 'todos';

  Map<int, String> servicos = {};
  Map<int, String> tosas = {};
  Map<int, String> servicosAdicionais = {};

  final List<String> opcoesFiltro = [
    'todos',
    'pendente',
    'aprovado',
    'em espera',
    'em andamento',
    'a caminho',
    'concluido',
    'reprovado',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.wait([
        _carregarServicos(),
        _carregarTosas(),
        _carregarServicosAdicionais(),
      ]);
      await _carregarHistorico();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _carregarServicos() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/servico'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        servicos = {for (var s in data) s['id'] as int: s['tipo'] as String};
      });
    }
  }

  Future<void> _carregarTosas() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/tosas'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        tosas = {for (var t in data) t['id'] as int: t['tipo'] as String};
      });
    }
  }

  Future<void> _carregarServicosAdicionais() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/servicos-adicionais'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        servicosAdicionais = {
          for (var s in data) s['id'] as int: s['descricao'] as String,
        };
      });
    }
  }

  Future<void> _carregarHistorico() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/agendamentos/all'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> agendamentos = jsonDecode(response.body);

        setState(() {
          todosAgendamentos = agendamentos
              .map<Map<String, dynamic>>((a) => Map<String, dynamic>.from(a))
              .toList();
          _aplicarFiltro();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar histórico: $e')),
        );
      }
    }
  }

  void _aplicarFiltro() {
    if (filtroStatus == 'todos') {
      agendamentosFiltrados = List.from(todosAgendamentos);
    } else {
      agendamentosFiltrados = todosAgendamentos
          .where((a) => a['status'] == filtroStatus)
          .toList();
    }
    // Ordenar por data (mais recente primeiro)
    agendamentosFiltrados.sort((a, b) {
      final dataA = DateTime.parse(a['data']);
      final dataB = DateTime.parse(b['data']);
      return dataB.compareTo(dataA);
    });
  }

  String _nomeServico(dynamic ag) {
    if (ag == null) return '';
    if (ag is Map && ag['servico'] != null && ag['servico']['tipo'] != null)
      return ag['servico']['tipo'] ?? '';
    if (ag is Map &&
        ag['servicoId'] != null &&
        servicos[ag['servicoId']] != null)
      return servicos[ag['servicoId']] ?? '';
    return ag['servicoId']?.toString() ?? '';
  }

  String _nomeTosa(dynamic ag) {
    if (ag == null) return '';
    if (ag is Map && ag['tosa'] != null && ag['tosa']['tipo'] != null)
      return ag['tosa']['tipo'] ?? '';
    if (ag is Map && ag['tosaId'] != null && tosas[ag['tosaId']] != null)
      return tosas[ag['tosaId']] ?? '';
    return ag['tosaId']?.toString() ?? '';
  }

  String _nomesPresilhas(dynamic ag) {
    if (ag == null || ag['produtos'] == null) return 'Nenhuma';
    final produtos = ag['produtos'];
    final presilhas = produtos
        .where((p) => p is Map && p['tipo'] == 1)
        .toList();
    if (presilhas.isEmpty) return 'Nenhuma';
    return presilhas
        .map((p) => p['descricao'] ?? '')
        .where((d) => d != null && d.isNotEmpty)
        .join(', ');
  }

  String _nomesPerfumes(dynamic ag) {
    if (ag == null || ag['produtos'] == null) return 'Nenhum';
    final produtos = ag['produtos'];
    final perfumes = produtos.where((p) => p is Map && p['tipo'] == 2).toList();
    if (perfumes.isEmpty) return 'Nenhum';
    return perfumes
        .map((p) => p['descricao'] ?? '')
        .where((d) => d != null && d.isNotEmpty)
        .join(', ');
  }

  String _nomesServicosAdicionais(dynamic ag) {
    if (ag == null || ag['servicosAdicionais'] == null) return 'Nenhum';
    final servicos = ag['servicosAdicionais'];
    if (servicos is List && servicos.isNotEmpty) {
      final nomes = servicos
          .map(
            (s) => s is Map && s['descricao'] != null
                ? s['descricao'].toString()
                : '',
          )
          .where((d) => d.isNotEmpty)
          .toSet()
          .toList();
      return nomes.isEmpty ? 'Nenhum' : nomes.join(', ');
    }
    return 'Nenhum';
  }

  String _formatarData(dynamic data) {
    if (data == null) return '';
    try {
      final date = DateTime.tryParse(data.toString());
      if (date == null) return data.toString();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return data.toString();
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pendente':
        return 'Aguardando aprovação';
      case 'aprovado':
        return 'Aprovado';
      case 'em espera':
        return 'Em espera';
      case 'em andamento':
        return 'Em andamento';
      case 'a caminho':
        return 'A caminho';
      case 'concluido':
        return 'Concluído';
      case 'reprovado':
        return 'Reprovado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.orange;
      case 'aprovado':
        return Colors.blue;
      case 'em espera':
        return Colors.yellow.shade700;
      case 'em andamento':
        return Colors.green;
      case 'a caminho':
        return Colors.teal;
      case 'concluido':
        return Colors.grey;
      case 'reprovado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _mostrarDetalhesAgendamento(
    BuildContext context,
    Map<String, dynamic> agendamento,
  ) {
    final pet = agendamento['pet'];

    showDialog(
      context: context,
      builder: (context) {
        final status = (agendamento['status'] ?? '').toString();
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(16),
          title: Row(
            children: [
              Icon(Icons.event_note),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detalhes do Agendamento',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _getStatusDisplay(status).toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agendamento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _DetailRow(label: 'ID', value: '${agendamento['id']}'),
                _DetailRow(
                  label: 'Pet',
                  value: pet?['nome'] ?? 'Pet não encontrado',
                ),
                _DetailRow(
                  label: 'Data',
                  value: _formatarData(agendamento['data']),
                ),
                _DetailRow(
                  label: 'Horário',
                  value: agendamento['horario'] ?? '',
                ),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                Text('Serviços', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _DetailRow(label: 'Serviço', value: _nomeServico(agendamento)),
                _DetailRow(label: 'Tosa', value: _nomeTosa(agendamento)),
                _DetailRow(
                  label: 'Serviços Adicionais',
                  value: _nomesServicosAdicionais(agendamento),
                ),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                Text('Extras', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _DetailRow(
                  label: 'Presilhas',
                  value: _nomesPresilhas(agendamento),
                ),
                _DetailRow(
                  label: 'Perfumes',
                  value: _nomesPerfumes(agendamento),
                ),
                _DetailRow(
                  label: 'Taxi Dog',
                  value: agendamento['taxiDog'] == true ? 'Sim' : 'Não',
                ),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                Text(
                  'Observações',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  (agendamento['observacao'] ?? '').toString().isEmpty
                      ? 'Sem observações'
                      : agendamento['observacao'].toString(),
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
              label: Text('Fechar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: StadiumBorder(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgendamentoCard(Map<String, dynamic> agendamento) {
    final pet = agendamento['pet'];
    final status = agendamento['status'];
    final data = DateTime.parse(agendamento['data']);
    final horario = agendamento['horario'];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, size: 24, color: Colors.black),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet?['nome'] ?? 'Pet não encontrado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às $horario',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    _getStatusDisplay(status).toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _mostrarDetalhesAgendamento(context, agendamento);
                  },
                  child: Text('Detalhes', style: TextStyle(color: Colors.blue)),
                ),
                Text(
                  'ID: ${agendamento['id']}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Histórico - Admin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Filtrar por status: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filtroStatus,
                    dropdownColor: Colors.white,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: opcoesFiltro.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status == 'todos'
                              ? 'Todos'
                              : _getStatusDisplay(status),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        filtroStatus = value!;
                        _aplicarFiltro();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Contador
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Total: ${agendamentosFiltrados.length} agendamento(s)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // Lista
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _carregarDados,
                    child: agendamentosFiltrados.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhum agendamento encontrado',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (filtroStatus != 'todos')
                                  Text(
                                    'para o status "${_getStatusDisplay(filtroStatus)}"',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: agendamentosFiltrados.length,
                            itemBuilder: (context, index) {
                              return _buildAgendamentoCard(
                                agendamentosFiltrados[index],
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
