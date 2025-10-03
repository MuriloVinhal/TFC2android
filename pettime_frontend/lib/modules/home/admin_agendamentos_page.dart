import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/api_config.dart';
import 'package:intl/intl.dart';

class AdminAgendamentosPage extends StatefulWidget {
  @override
  _AdminAgendamentosPageState createState() => _AdminAgendamentosPageState();
}

class _AdminAgendamentosPageState extends State<AdminAgendamentosPage> {
  List<Map<String, dynamic>> agendamentosPendentes = [];
  List<Map<String, dynamic>> agendamentosAprovados = [];
  bool isLoading = true;
  Map<int, String> servicos = {};
  Map<int, String> tosas = {};
  Map<int, String> servicosAdicionais = {};

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
      await _carregarAgendamentos();
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

  Future<void> _carregarAgendamentos() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/agendamentos/all'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> agendamentos = jsonDecode(response.body);

        setState(() {
          agendamentosPendentes = agendamentos
              .where((a) => a['status'] == 'pendente')
              .map<Map<String, dynamic>>((a) => Map<String, dynamic>.from(a))
              .toList();

          agendamentosAprovados = agendamentos
              .where(
                (a) =>
                    a['status'] == 'aprovado' ||
                    a['status'] == 'em espera' ||
                    a['status'] == 'em andamento' ||
                    a['status'] == 'a caminho',
              )
              .map<Map<String, dynamic>>((a) => Map<String, dynamic>.from(a))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
        );
      }
    }
  }

  Future<void> _aprovarAgendamento(int id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/agendamentos/$id/approve'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agendamento aprovado com sucesso!')),
        );
        _carregarAgendamentos();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao aprovar agendamento')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aprovar agendamento: $e')),
      );
    }
  }

  Future<void> _reprovarAgendamento(int id) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/agendamentos/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'reprovado'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agendamento reprovado com sucesso!')),
        );
        _carregarAgendamentos();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao reprovar agendamento')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao reprovar agendamento: $e')),
      );
    }
  }

  Future<void> _alterarStatus(int id, String novoStatus) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/agendamentos/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': novoStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status alterado para: $novoStatus')),
        );
        _carregarAgendamentos();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao alterar status')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao alterar status: $e')));
    }
  }

  Future<void> _concluirAgendamento(int id) async {
    final bool? enviarMensagem = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Concluir Agendamento'),
          content: Text(
            'O cliente será notificado, deseja concluir o serviço?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Sim'),
            ),
          ],
        );
      },
    );

    if (enviarMensagem == null) return;

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/agendamentos/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'concluido'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Agendamento concluído com sucesso!')),
        );
        _carregarAgendamentos();

        if (enviarMensagem) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Redirecionando para envio de mensagem...')),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao concluir agendamento')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao concluir agendamento: $e')),
      );
    }
  }

  void _mostrarOpcoesStatus(BuildContext context, int agendamentoId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Alterar Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildStatusOption(
                context,
                'Em espera',
                'em espera',
                agendamentoId,
              ),
              _buildStatusOption(
                context,
                'Em andamento',
                'em andamento',
                agendamentoId,
              ),
              _buildStatusOption(
                context,
                'A caminho',
                'a caminho',
                agendamentoId,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String label,
    String status,
    int agendamentoId,
  ) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        _alterarStatus(agendamentoId, status);
      },
    );
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
        return Colors.purple;
      case 'concluido':
        return Colors.grey;
      case 'reprovado':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

  void _mostrarDetalhesAgendamento(
    BuildContext context,
    Map<String, dynamic> agendamento,
  ) {
    final pet = agendamento['pet'];
    final usuario = pet != null ? pet['usuario'] : null;

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
                  'Solicitante',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _DetailRow(
                  label: 'Nome',
                  value: (usuario != null ? (usuario['nome'] ?? '') : '')
                      .toString(),
                ),
                _DetailRow(
                  label: 'E-mail',
                  value: (usuario != null ? (usuario['email'] ?? '') : '')
                      .toString(),
                ),
                _DetailRow(
                  label: 'Telefone',
                  value: (usuario != null ? (usuario['telefone'] ?? '') : '')
                      .toString(),
                ),
                _DetailRow(
                  label: 'Endereço',
                  value: (usuario != null ? (usuario['endereco'] ?? '') : '')
                      .toString(),
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

  Widget _buildAgendamentoCard(
    Map<String, dynamic> agendamento,
    bool isPendente,
  ) {
    final pet = agendamento['pet'];
    final status = agendamento['status'];
    final data = DateTime.parse(agendamento['data']);
    final horario = agendamento['horario'];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                if (isPendente) ...[
                  ElevatedButton(
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirmar reprovação'),
                          content: Text(
                            'Deseja realmente reprovar este agendamento? O cliente será notificado.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Reprovar'),
                            ),
                          ],
                        ),
                      );
                      if (confirmar == true) {
                        await _reprovarAgendamento(agendamento['id']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Reprovar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _aprovarAgendamento(agendamento['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Aprovar'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () =>
                        _mostrarOpcoesStatus(context, agendamento['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Alterar status'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _concluirAgendamento(agendamento['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Concluir'),
                  ),
                ],
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
          'Agendamentos - Admin',
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
            onPressed: _carregarAgendamentos,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarAgendamentos,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (agendamentosPendentes.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Aguardando aprovação',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...agendamentosPendentes
                          .map(
                            (agendamento) =>
                                _buildAgendamentoCard(agendamento, true),
                          )
                          .toList(),
                    ],
                    if (agendamentosAprovados.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Aprovados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...agendamentosAprovados
                          .map(
                            (agendamento) =>
                                _buildAgendamentoCard(agendamento, false),
                          )
                          .toList(),
                    ],
                    if (agendamentosPendentes.isEmpty &&
                        agendamentosAprovados.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Nenhum agendamento encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
