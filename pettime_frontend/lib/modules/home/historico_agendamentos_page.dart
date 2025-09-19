import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../core/utils/api_config.dart';

class HistoricoAgendamentosPage extends StatefulWidget {
  @override
  State<HistoricoAgendamentosPage> createState() =>
      _HistoricoAgendamentosPageState();
}

class _HistoricoAgendamentosPageState extends State<HistoricoAgendamentosPage> {
  List<Map<String, dynamic>> agendamentos = [];
  List<Map<String, dynamic>> agendamentosFiltrados = [];
  bool carregando = true;
  Map<int, String> servicos = {};
  Map<int, String> tosas = {};
  Map<int, String> servicosAdicionais = {};

  String filtroStatus = 'todos';
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
    setState(() => carregando = true);
    await Future.wait([
      _carregarServicos(),
      _carregarTosas(),
      _carregarServicosAdicionais(),
    ]);
    await _carregarHistorico();
    setState(() => carregando = false);
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
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');
    if (usuarioId == null) return;
    final responsePets = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets?usuarioId=$usuarioId'),
    );
    if (responsePets.statusCode == 200) {
      final List<dynamic> petsData = jsonDecode(responsePets.body);
      List<Map<String, dynamic>> ags = [];
      for (final pet in petsData) {
        final petId = pet['id'];
        final responseAgs = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/agendamentos?petId=$petId'),
        );
        if (responseAgs.statusCode == 200) {
          final List<dynamic> agsPet = jsonDecode(responseAgs.body);
          for (final ag in agsPet) {
            ags.add({...ag, 'petNome': pet['nome']});
          }
        }
      }
      setState(() {
        agendamentos = ags;
        _aplicarFiltro();
      });
    }
  }

  void _aplicarFiltro() {
    if (filtroStatus == 'todos') {
      agendamentosFiltrados = List.from(agendamentos);
    } else {
      agendamentosFiltrados = agendamentos
          .where((a) => (a['status'] ?? '').toString() == filtroStatus)
          .toList();
    }
    agendamentosFiltrados.sort((a, b) {
      try {
        final dataA = DateTime.parse(a['data'].toString());
        final dataB = DateTime.parse(b['data'].toString());
        return dataB.compareTo(dataA);
      } catch (_) {
        return 0;
      }
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

  // Função para listar nomes das presilhas vinculadas (corrigida)
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

  // Função para listar nomes dos perfumes vinculados (corrigida)
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

  // Função para listar nomes dos serviços adicionais vinculados (corrigida)
  String _nomesServicosAdicionais(dynamic ag) {
    if (ag == null || ag['servicosAdicionais'] == null) return 'Nenhum';
    final servicos = ag['servicosAdicionais'];
    if (servicos is List && servicos.isNotEmpty) {
      // Remover duplicados e nulos
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
        return Colors.yellow;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Agendamentos'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filtrar por status: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filtroStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 8),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
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
                                const SizedBox(height: 16),
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
                              final ag = agendamentosFiltrados[index];
                              final status = (ag['status'] ?? '').toString();
                              final data =
                                  DateTime.tryParse(
                                    ag['data']?.toString() ?? '',
                                  ) ??
                                  DateTime.now();
                              final horario = ag['horario'];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.pets,
                                            size: 24,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ag['petNome'] ?? 'Pet',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${horario ?? ''}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                status,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getStatusColor(status),
                                              ),
                                            ),
                                            child: Text(
                                              _getStatusDisplay(
                                                status,
                                              ).toUpperCase(),
                                              style: TextStyle(
                                                color: _getStatusColor(status),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    title: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.event_note,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        const Expanded(
                                                          child: Text(
                                                            'Detalhes do Agendamento',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  _getStatusColor(
                                                                    status,
                                                                  ).withOpacity(
                                                                    0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    _getStatusColor(
                                                                      status,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                _getStatusDisplay(
                                                                  status,
                                                                ).toUpperCase(),
                                                                style: TextStyle(
                                                                  color:
                                                                      _getStatusColor(
                                                                        status,
                                                                      ),
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Agendamento',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          _DetailRow(
                                                            label: 'ID',
                                                            value:
                                                                '${ag['id']}',
                                                          ),
                                                          _DetailRow(
                                                            label: 'Pet',
                                                            value:
                                                                ag['petNome'] ??
                                                                '',
                                                          ),
                                                          _DetailRow(
                                                            label: 'Data',
                                                            value:
                                                                _formatarData(
                                                                  ag['data'],
                                                                ),
                                                          ),
                                                          _DetailRow(
                                                            label: 'Horário',
                                                            value:
                                                                ag['horario'] ??
                                                                '',
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Divider(),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Text(
                                                            'Serviços',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          _DetailRow(
                                                            label: 'Serviço',
                                                            value: _nomeServico(
                                                              ag,
                                                            ),
                                                          ),
                                                          _DetailRow(
                                                            label: 'Tosa',
                                                            value: _nomeTosa(
                                                              ag,
                                                            ),
                                                          ),
                                                          _DetailRow(
                                                            label:
                                                                'Serviços Adicionais',
                                                            value:
                                                                _nomesServicosAdicionais(
                                                                  ag,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Divider(),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Text(
                                                            'Extras',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          _DetailRow(
                                                            label: 'Presilhas',
                                                            value:
                                                                _nomesPresilhas(
                                                                  ag,
                                                                ),
                                                          ),
                                                          _DetailRow(
                                                            label: 'Perfumes',
                                                            value:
                                                                _nomesPerfumes(
                                                                  ag,
                                                                ),
                                                          ),
                                                          _DetailRow(
                                                            label: 'Taxi Dog',
                                                            value:
                                                                ag['taxiDog'] ==
                                                                    true
                                                                ? 'Sim'
                                                                : 'Não',
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Divider(),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          const Text(
                                                            'Observações',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          Text(
                                                            (ag['observacao'] ??
                                                                        '')
                                                                    .toString()
                                                                    .isEmpty
                                                                ? 'Sem observações'
                                                                : ag['observacao']
                                                                      .toString(),
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .black87,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actionsPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    actions: [
                                                      ElevatedButton.icon(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.close,
                                                        ),
                                                        label: const Text(
                                                          'Fechar',
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          foregroundColor:
                                                              Colors.white,
                                                          shape:
                                                              const StadiumBorder(),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              'Detalhes',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'ID: ${ag['id']}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
