class Agendamento {
  final int? id;
  final int petId;
  final String tipoServico;
  final DateTime dataHora;
  final String? observacoes;
  final StatusAgendamento status;
  final double? preco;
  final int? veterinarioId;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  Agendamento({
    this.id,
    required this.petId,
    required this.tipoServico,
    required this.dataHora,
    this.observacoes,
    this.status = StatusAgendamento.agendado,
    this.preco,
    this.veterinarioId,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  /// Valida se o agendamento tem dados válidos
  bool isValid() {
    return petId > 0 &&
        tipoServico.isNotEmpty &&
        dataHora.isAfter(DateTime.now()) &&
        (preco == null || preco! >= 0);
  }

  /// Verifica se o agendamento está no futuro
  bool isFuturo() => dataHora.isAfter(DateTime.now());

  /// Verifica se o agendamento é hoje
  bool isHoje() {
    final hoje = DateTime.now();
    final dataAgendamento = dataHora;

    return hoje.year == dataAgendamento.year &&
        hoje.month == dataAgendamento.month &&
        hoje.day == dataAgendamento.day;
  }

  /// Verifica se o agendamento é esta semana
  bool isEstaSemana() {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
    final fimSemana = inicioSemana.add(Duration(days: 6));

    return dataHora.isAfter(inicioSemana) && dataHora.isBefore(fimSemana);
  }

  /// Calcula quantos dias faltam para o agendamento
  int diasParaAgendamento() {
    if (!isFuturo()) return 0;

    final agora = DateTime.now();
    final diferenca = dataHora.difference(agora);

    return diferenca.inDays;
  }

  /// Calcula quantas horas faltam para o agendamento
  int horasParaAgendamento() {
    if (!isFuturo()) return 0;

    final agora = DateTime.now();
    final diferenca = dataHora.difference(agora);

    return diferenca.inHours;
  }

  /// Retorna descrição do tempo restante
  String getTempoRestante() {
    if (!isFuturo()) return 'Vencido';

    final dias = diasParaAgendamento();
    final horas = horasParaAgendamento();

    if (dias > 0) {
      if (dias == 1) return 'Amanhã';
      return 'Em $dias dias';
    }

    if (horas > 1) {
      return 'Em $horas horas';
    }

    final minutos = dataHora.difference(DateTime.now()).inMinutes;
    if (minutos > 0) {
      return 'Em $minutos minutos';
    }

    return 'Agora';
  }

  /// Verifica se pode ser cancelado (até 24h antes)
  bool podeCancelar() {
    if (!isFuturo()) return false;
    if (status == StatusAgendamento.cancelado) return false;
    if (status == StatusAgendamento.concluido) return false;

    final horasRestantes = horasParaAgendamento();
    return horasRestantes >= 24;
  }

  /// Verifica se pode ser reagendado
  bool podeReagendar() {
    return status == StatusAgendamento.agendado && isFuturo();
  }

  /// Verifica se está em horário comercial (8h às 18h)
  bool isHorarioComercial() {
    final hora = dataHora.hour;
    return hora >= 8 && hora < 18;
  }

  /// Verifica se é em dia útil (segunda a sexta)
  bool isDiaUtil() {
    final diaSemana = dataHora.weekday;
    return diaSemana >= 1 && diaSemana <= 5; // 1 = segunda, 5 = sexta
  }

  /// Calcula valor com desconto (se aplicável)
  double? getValorComDesconto({double percentualDesconto = 0}) {
    if (preco == null) return null;
    if (percentualDesconto <= 0) return preco;

    final desconto = preco! * (percentualDesconto / 100);
    return preco! - desconto;
  }

  /// Formata data e hora para exibição
  String getDataHoraFormatada() {
    final meses = [
      '',
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = meses[dataHora.month];
    final ano = dataHora.year;
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano às ${hora}:${minuto}';
  }

  /// Cria cópia com campos alterados
  Agendamento copyWith({
    int? id,
    int? petId,
    String? tipoServico,
    DateTime? dataHora,
    String? observacoes,
    StatusAgendamento? status,
    double? preco,
    int? veterinarioId,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return Agendamento(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      tipoServico: tipoServico ?? this.tipoServico,
      dataHora: dataHora ?? this.dataHora,
      observacoes: observacoes ?? this.observacoes,
      status: status ?? this.status,
      preco: preco ?? this.preco,
      veterinarioId: veterinarioId ?? this.veterinarioId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  /// Converte para Map para API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'tipoServico': tipoServico,
      'dataHora': dataHora.toIso8601String(),
      'observacoes': observacoes,
      'status': status.toString().split('.').last,
      'preco': preco,
      'veterinarioId': veterinarioId,
      'dataCriacao': dataCriacao?.toIso8601String(),
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
    };
  }

  /// Cria instância a partir de Map da API
  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      petId: json['petId'] ?? 0,
      tipoServico: json['tipoServico'] ?? '',
      dataHora: DateTime.parse(json['dataHora']),
      observacoes: json['observacoes'],
      status: _statusFromString(json['status']),
      preco: json['preco']?.toDouble(),
      veterinarioId: json['veterinarioId'],
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : null,
      dataAtualizacao: json['dataAtualizacao'] != null
          ? DateTime.parse(json['dataAtualizacao'])
          : null,
    );
  }

  static StatusAgendamento _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'agendado':
        return StatusAgendamento.agendado;
      case 'confirmado':
        return StatusAgendamento.confirmado;
      case 'em_andamento':
        return StatusAgendamento.emAndamento;
      case 'concluido':
        return StatusAgendamento.concluido;
      case 'cancelado':
        return StatusAgendamento.cancelado;
      default:
        return StatusAgendamento.agendado;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Agendamento &&
        other.id == id &&
        other.petId == petId &&
        other.tipoServico == tipoServico &&
        other.dataHora == dataHora &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        petId.hashCode ^
        tipoServico.hashCode ^
        dataHora.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'Agendamento(id: $id, petId: $petId, tipoServico: $tipoServico, dataHora: $dataHora, status: $status)';
  }
}

enum StatusAgendamento {
  agendado,
  confirmado,
  emAndamento,
  concluido,
  cancelado,
}
