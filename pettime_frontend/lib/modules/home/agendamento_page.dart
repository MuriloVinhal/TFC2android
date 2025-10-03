import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/utils/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgendamentoPage extends StatefulWidget {
  @override
  State<AgendamentoPage> createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  // Dropdowns
  String? servico;
  String? tosa;
  List<String> servicosAdicionais = ['Nenhum serviço adicional'];
  String? taxiDog;
  String? petSelecionado;
  String observacoes = '';
  int? presilhaSelecionada;
  int? perfumeSelecionado;
  DateTime? dataSelecionada;
  String? horarioSelecionado;
  List<String> horariosOcupados = [];

  // Mock data
  List<String> pets = [];
  final List<String> horarios = [
    '9:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];
  final List<String> diasSemana = [
    'Seg',
    'Ter',
    'Quar',
    'Quin',
    'Sex',
    'Sab',
    'Dom',
  ];
  final DateTime semanaBase = DateTime(2023, 11, 12); // Exemplo
  List<Map<String, dynamic>> presilhas = [];
  List<Map<String, dynamic>> perfumes = [];
  List<Map<String, dynamic>> servicosDisponiveis = [];
  List<Map<String, dynamic>> tosasDisponiveis = [];
  DateTime semanaAtual =
      DateTime.now(); // Nova variável para controlar a semana exibida

  @override
  void initState() {
    super.initState();
    _carregarPetsUsuario();
    _carregarPresilhasPerfumes();
    _carregarServicosETosas();
    _ajustarSemanaParaSegunda();
  }

  void _ajustarSemanaParaSegunda() {
    // Ajusta semanaAtual para a segunda-feira da semana atual
    setState(() {
      semanaAtual = semanaAtual.subtract(
        Duration(days: semanaAtual.weekday - 1),
      );
    });
  }

  void _mudarSemana(int direcao) {
    final novaSemana = semanaAtual.add(Duration(days: 7 * direcao));
    final hoje = DateTime.now();
    final inicioSemanaAtual = _inicioDaSemana(hoje);
    final proximaSemana = inicioSemanaAtual.add(const Duration(days: 7));
    // Só permite voltar até a semana atual e avançar até uma semana à frente
    if (direcao == -1 && semanaAtual.isAtSameMomentAs(inicioSemanaAtual))
      return;
    if (direcao == 1 && novaSemana.isAfter(proximaSemana)) return;
    setState(() {
      semanaAtual = novaSemana;
      dataSelecionada = null;
      horarioSelecionado = null;
      horariosOcupados = [];
    });
  }

  DateTime _inicioDaSemana(DateTime data) {
    return data.subtract(Duration(days: data.weekday - 1));
  }

  Future<void> _carregarPetsUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('user_id'); // Corrigido para user_id
    if (usuarioId == null) {
      print('❌ usuarioId não encontrado no SharedPreferences');
      return;
    }

    print('📱 Carregando pets para agendamento, usuário: $usuarioId');
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets?usuarioId=$usuarioId'),
    );

    print('📱 Status response pets: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        pets = data
            .where((pet) => pet['deletado'] != true)
            .map<String>((pet) => pet['nome'] as String)
            .toList();
      });
      print('✅ ${pets.length} pets carregados para agendamento: $pets');
    } else {
      print('❌ Erro ao carregar pets: ${response.statusCode}');
    }
  }

  Future<void> _carregarPresilhasPerfumes() async {
    try {
      final respPresilhas = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/produtos?tipo=1'),
      );
      final respPerfumes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/produtos?tipo=2'),
      );
      if (respPresilhas.statusCode == 200 && respPerfumes.statusCode == 200) {
        setState(() {
          presilhas = List<Map<String, dynamic>>.from(
            jsonDecode(respPresilhas.body),
          );
          perfumes = List<Map<String, dynamic>>.from(
            jsonDecode(respPerfumes.body),
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _carregarServicosETosas() async {
    try {
      final respServicos = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/servico'),
      );
      final respTosas = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tosas'),
      );
      
      if (respServicos.statusCode == 200) {
        setState(() {
          servicosDisponiveis = List<Map<String, dynamic>>.from(
            jsonDecode(respServicos.body),
          );
        });
        print('✅ Serviços carregados: $servicosDisponiveis');
      }
      
      if (respTosas.statusCode == 200) {
        setState(() {
          tosasDisponiveis = List<Map<String, dynamic>>.from(
            jsonDecode(respTosas.body),
          );
        });
        print('✅ Tosas carregadas: $tosasDisponiveis');
      }
    } catch (e) {
      print('❌ Erro ao carregar serviços/tosas: $e');
    }
  }

  void _onSelecionarData(DateTime date) async {
    setState(() {
      dataSelecionada = date;
      horarioSelecionado = null;
      horariosOcupados = [];
    });
    final dataStr =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    print('📅 Buscando horários ocupados para: $dataStr');
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/agendamentos?data=$dataStr'),
    );
    print('📅 Status da resposta: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> ags = jsonDecode(response.body);
      print('📅 Agendamentos encontrados: ${ags.length}');
      print('📅 Dados dos agendamentos: $ags');
      setState(() {
        horariosOcupados = ags
            .map<String>((a) => a['horario'] as String)
            .toList();
      });
      print('📅 Horários ocupados: $horariosOcupados');
    } else {
      print('❌ Erro ao buscar agendamentos: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Banho e tosa',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Serviços
            const Text(
              'Serviços',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              value: servico,
              hint: 'Selecione o serviço',
              items: ['Banho', 'Banho e tosa'],
              onChanged: (v) => setState(() {
                servico = v;
                if (servico != 'Banho e tosa') {
                  tosa = null;
                }
              }),
            ),
            const SizedBox(height: 20),
            // Tosas
            const Text('Tosas', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            AbsorbPointer(
              absorbing: servico != 'Banho e tosa',
              child: Opacity(
                opacity: servico == 'Banho e tosa' ? 1.0 : 0.5,
                child: _buildDropdown(
                  value: tosa,
                  hint: 'Selecione o tipo de tosa',
                  items: ['Tosa completa', 'Tosa bebê', 'Tosa higiênica'],
                  onChanged: (v) => setState(() => tosa = v),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Serviços adicionais
            const Text(
              'Serviços adicionais:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildMultiSelect(
              values: servicosAdicionais,
              items: ['Nenhum serviço adicional', 'Corte de unha', 'Escovação'],
              hint: 'Selecione os serviços',
              onChanged: (v) => setState(() => servicosAdicionais = v),
            ),
            const SizedBox(height: 20),
            // Taxi dog
            const Text(
              'Deseja utilizar o taxi dog?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              value: taxiDog,
              hint: 'Busca em sua residencial',
              items: ['Sim', 'Não'],
              onChanged: (v) => setState(() => taxiDog = v),
            ),
            const SizedBox(height: 20),
            // Pet
            const Text(
              'Selecione o pet:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              value: petSelecionado,
              hint: 'Selecione o pet para o serviço',
              items: pets,
              onChanged: (v) => setState(() => petSelecionado = v),
            ),
            const SizedBox(height: 20),
            // Observações
            const Text(
              'Observações:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Informe alguma deficiência, alergia ou intolerância do seu pet:',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => observacoes = v,
            ),
            const SizedBox(height: 24),
            // Presilhas
            const Text(
              'Selecione a presilha, laço ou gravata:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildProdutoSelector(
              label: 'Presilhas:',
              produtos: presilhas,
              selecionado: presilhaSelecionada,
              onSelect: (i) => setState(() => presilhaSelecionada = i),
            ),
            const SizedBox(height: 24),
            // Perfumes
            const Text(
              'Selecione o perfume que será utilizado',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildProdutoSelector(
              label: 'Perfumes:',
              produtos: perfumes,
              selecionado: perfumeSelecionado,
              onSelect: (i) => setState(() => perfumeSelecionado = i),
            ),
            const SizedBox(height: 24),
            // Data
            const Text('Data', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildDateSelector(),
            const SizedBox(height: 24),
            // Horário
            const Text(
              'Horário',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildHorarioSelector(),
            const SizedBox(height: 32),
            // Botão
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final precisaTosa = servico == 'Banho e tosa';
                  if (dataSelecionada == null ||
                      horarioSelecionado == null ||
                      petSelecionado == null ||
                      servico == null ||
                      (precisaTosa && tosa == null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preencha todos os campos obrigatórios!'),
                      ),
                    );
                    return;
                  }
                  
                  // Validar se o horário não está ocupado
                  if (horariosOcupados.contains(horarioSelecionado)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Este horário não está mais disponível. Por favor, escolha outro horário.'),
                      ),
                    );
                    return;
                  }
                  
                  final prefs = await SharedPreferences.getInstance();
                  final usuarioId = prefs.getInt(
                    'user_id',
                  ); // Corrigido para user_id
                  if (usuarioId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usuário não identificado.'),
                      ),
                    );
                    return;
                  }
                  // Buscar o id do pet selecionado
                  final responsePets = await http.get(
                    Uri.parse('${ApiConfig.baseUrl}/pets?usuarioId=$usuarioId'),
                  );
                  int? petId;
                  if (responsePets.statusCode == 200) {
                    final List<dynamic> petsData = jsonDecode(
                      responsePets.body,
                    );
                    final pet = petsData.firstWhere(
                      (p) => p['nome'] == petSelecionado,
                      orElse: () => null,
                    );
                    petId = pet != null ? pet['id'] : null;
                  }
                  if (petId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pet não encontrado.')),
                    );
                    return;
                  }
                  print('presilhaSelecionada: $presilhaSelecionada');
                  print('perfumeSelecionado: $perfumeSelecionado');
                  print('servicosAdicionais: $servicosAdicionais');
                  // Montar listas de IDs de produtos selecionados
                  final List<int> produtosSelecionados = [
                    if (presilhaSelecionada != null) presilhaSelecionada!,
                    if (perfumeSelecionado != null) perfumeSelecionado!,
                  ];
                  // Mapear nomes dos serviços adicionais para IDs (ajuste conforme seu backend)
                  final List<int> servicosAdicionaisSelecionados =
                      servicosAdicionais
                          .where((s) => s != 'Nenhum serviço adicional') // Filtra a opção "Nenhum"
                          .map((s) {
                            if (s == 'Corte de unha') return 1;
                            if (s == 'Escovação') return 2;
                            return 0;
                          })
                          .where((id) => id != 0)
                          .toList();

                  // Depuração: mostrar serviços disponíveis e serviço selecionado
                  print('Serviços disponíveis (completo):');
                  print(servicosDisponiveis);
                  for (var s in servicosDisponiveis) {
                    print('ID: \'${s['id']}\' Tipo: \'${s['tipo']}\'');
                  }
                  print('Serviço selecionado: $servico');

                  int? servicoIdSelecionado;
                  if (servico != null && servicosDisponiveis.isNotEmpty) {
                    // Busca por igualdade exata
                    final encontrado = servicosDisponiveis.firstWhere(
                      (s) => s['tipo'] != null &&
                        s['tipo'].toString().trim().toLowerCase() == servico!.trim().toLowerCase(),
                      orElse: () {
                        print('Serviço "$servico" não encontrado, usando o primeiro disponível.');
                        return servicosDisponiveis.first;
                      },
                    );
                    servicoIdSelecionado = encontrado['id'];
                    print('Resultado do mapeamento: servicoIdSelecionado = $servicoIdSelecionado');
                    if (encontrado['tipo'].toString().trim().toLowerCase() != servico!.trim().toLowerCase()) {
                      print('⚠️ Atenção: serviço selecionado "$servico" não bate com nenhum tipo do backend.');
                    }
                  }
                  // Se ainda não encontrou, usa o primeiro disponível
                  if (servicoIdSelecionado == null && servicosDisponiveis.isNotEmpty) {
                    servicoIdSelecionado = servicosDisponiveis.first['id'];
                    print('Serviço não reconhecido, usando o primeiro disponível: ID $servicoIdSelecionado');
                  }
                  
                  // Mapear tosa selecionada para ID
                  int? tosaIdSelecionado;
                  if (tosa != null && tosasDisponiveis.isNotEmpty) {
                    if (tosa == 'Tosa completa') {
                      tosaIdSelecionado = tosasDisponiveis
                          .firstWhere((t) => t['tipo'].toString().toLowerCase().contains('completa'), 
                              orElse: () => tosasDisponiveis.first)['id'];
                    } else if (tosa == 'Tosa bebê') {
                      tosaIdSelecionado = tosasDisponiveis
                          .firstWhere((t) => t['tipo'].toString().toLowerCase().contains('bebê'), 
                              orElse: () => tosasDisponiveis.first)['id'];
                    } else if (tosa == 'Tosa higiênica') {
                      tosaIdSelecionado = tosasDisponiveis
                          .firstWhere((t) => t['tipo'].toString().toLowerCase().contains('higiênica'), 
                              orElse: () => tosasDisponiveis.first)['id'];
                    }
                  }

                  // Montar dados do agendamento
                  final dataStr =
                      '${dataSelecionada!.year.toString().padLeft(4, '0')}-${dataSelecionada!.month.toString().padLeft(2, '0')}-${dataSelecionada!.day.toString().padLeft(2, '0')}';
                  final body = {
                    'petId': petId,
                    'servicoId': servicoIdSelecionado,
                    'data': dataStr,
                    'horario': horarioSelecionado,
                    'taxiDog': taxiDog == 'Sim',
                    'observacao': observacoes,
                    'produtos': produtosSelecionados,
                    'servicosAdicionais': servicosAdicionaisSelecionados,
                  };
                  // Só adiciona tosaId se o serviço for 'Banho e tosa' e houver seleção
                  if (servico == 'Banho e tosa' && tosaIdSelecionado != null) {
                    body['tosaId'] = tosaIdSelecionado;
                  }
                  print(
                    jsonEncode(body),
                  ); // Depuração: mostra o corpo enviado ao backend
                  
                  // Validar se temos um serviço selecionado
                  if (servicoIdSelecionado == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, selecione um serviço válido.')),
                    );
                    return;
                  }
                  
                  final response = await http.post(
                    Uri.parse('${ApiConfig.baseUrl}/agendamentos'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(body),
                  );
                  if (response.statusCode == 201) {
                    final agendamentoCriado = jsonDecode(response.body);
                    final idNovo = agendamentoCriado['id'];
                    // Remover o showDialog e o Navigator.pop duplicado
                    // Redirecionar para a home page
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Agendamento realizado com sucesso! (ID: $idNovo)',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao agendar: ${response.body}'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Solicitar agendamento',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMultiSelect({
    required List<String> values,
    required List<String> items,
    required String hint,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      children: items.map((item) {
        final selected = values.contains(item);
        return FilterChip(
          label: Text(
            item,
            style: TextStyle(color: selected ? Colors.white : Colors.blue),
          ),
          selected: selected,
          selectedColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
          checkmarkColor: Colors.white,
          onSelected: (v) {
            final newValues = List<String>.from(values);
            
            // Se "Nenhum serviço adicional" foi selecionado
            if (item == 'Nenhum serviço adicional') {
              if (v) {
                // Limpa todos os outros e seleciona apenas este
                newValues.clear();
                newValues.add(item);
              } else {
                // Remove apenas este item
                newValues.remove(item);
              }
            } else {
              // Se outro serviço foi selecionado, remove "Nenhum serviço adicional"
              if (v) {
                newValues.remove('Nenhum serviço adicional');
                newValues.add(item);
              } else {
                newValues.remove(item);
                // Se não há mais nenhum serviço selecionado, adiciona "Nenhum serviço adicional"
                if (newValues.isEmpty) {
                  newValues.add('Nenhum serviço adicional');
                }
              }
            }
            
            onChanged(newValues);
          },
        );
      }).toList(),
    );
  }


  Widget _buildProdutoSelector({
    required String label,
    required List<Map<String, dynamic>> produtos,
    required int? selecionado,
    required ValueChanged<int?> onSelect,
  }) {
    final isPresilha = label.toLowerCase().contains('presilha');
    final isPerfume = label.toLowerCase().contains('perfume');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        produtos.isEmpty
            ? Text(isPresilha ? 'Nenhuma presilha disponível.' : (isPerfume ? 'Nenhum perfume disponível.' : 'Nenhum produto disponível.'))
            : SizedBox(
                height: 90,
                child: Row(
                  children: [
                    // Botão para não selecionar nenhum
                    GestureDetector(
                      onTap: () => onSelect(null),
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selecionado == null
                              ? Colors.blue.shade50
                              : Colors.white,
                          border: Border.all(
                            color: selecionado == null
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            isPresilha ? 'Nenhuma\npresilha' : (isPerfume ? 'Nenhum\nperfume' : 'Nenhum'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selecionado == null
                                  ? Colors.blue
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: produtos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final produto = produtos[i];
                          final selecionadoId =
                              selecionado != null &&
                              selecionado == produto['id'];
                          return GestureDetector(
                            onTap: () => selecionadoId
                                ? onSelect(null)
                                : onSelect(produto['id']),
                            child: Container(
                              width: 90,
                              decoration: BoxDecoration(
                                color: selecionadoId
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                border: Border.all(
                                  color: selecionadoId
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  produto['imagem'] != null &&
                                          produto['imagem']
                                              .toString()
                                              .isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            '${ApiConfig.baseUrl}${produto['imagem']}',
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : isPresilha
                                      ? const Icon(
                                          Icons.emoji_emotions,
                                          size: 36,
                                          color: Colors.pink,
                                        )
                                      : isPerfume
                                      ? const Icon(
                                          Icons.spa,
                                          size: 36,
                                          color: Colors.purple,
                                        )
                                      : const Icon(
                                          Icons.image,
                                          size: 36,
                                          color: Colors.black26,
                                        ),
                                  const SizedBox(height: 4),
                                  Text(
                                    produto['descricao'] ?? '',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildDateSelector() {
    // Gera apenas dias úteis (segunda a sábado)
    final weekDays = List.generate(
      6,
      (i) => semanaAtual.add(Duration(days: i)),
    );
    final hoje = DateTime.now();
    final inicioSemanaAtual = _inicioDaSemana(hoje);
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: semanaAtual.isAtSameMomentAs(inicioSemanaAtual)
                ? null
                : () => _mudarSemana(-1),
            tooltip: 'Semana anterior',
          ),
        ),
        ...weekDays.map((date) {
          final selected =
              dataSelecionada != null &&
              dataSelecionada!.day == date.day &&
              dataSelecionada!.month == date.month &&
              dataSelecionada!.year == date.year;
          final isDisabled = date.isBefore(
            DateTime(hoje.year, hoje.month, hoje.day),
          );
          return Expanded(
            child: GestureDetector(
              onTap: isDisabled ? null : () => _onSelecionarData(date),
              child: Opacity(
                opacity: isDisabled ? 0.4 : 1.0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        diasSemana[date.weekday - 1],
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        SizedBox(
          width: 36,
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _mudarSemana(1),
            tooltip: 'Próxima semana',
          ),
        ),
      ],
    );
  }

  Widget _buildHorarioSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: horarios.map((hora) {
        final selected = horarioSelecionado == hora;
        final ocupado = horariosOcupados.contains(hora);
        bool horarioPassado = false;
        if (dataSelecionada != null) {
          final hoje = DateTime.now();
          if (dataSelecionada!.year == hoje.year &&
              dataSelecionada!.month == hoje.month &&
              dataSelecionada!.day == hoje.day) {
            // Considera o horário como HH:mm
            final partes = hora.split(':');
            final horaInt = int.tryParse(partes[0]) ?? 0;
            final minutoInt = int.tryParse(partes[1]) ?? 0;
            final agora = TimeOfDay.now();
            if (horaInt < agora.hour ||
                (horaInt == agora.hour && minutoInt <= agora.minute)) {
              horarioPassado = true;
            }
          }
        }
        final isDisabled = ocupado || horarioPassado;
        return GestureDetector(
          onTap: isDisabled
              ? null
              : () => setState(() => horarioSelecionado = hora),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.blue
                  : isDisabled
                  ? Colors.grey.shade300
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? Colors.blue
                    : isDisabled
                    ? Colors.grey.shade400
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Text(
              hora,
              style: TextStyle(
                color: isDisabled
                    ? Colors.grey
                    : selected
                    ? Colors.white
                    : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
