class Pet {
  final int? id;
  final String nome;
  final String especie;
  final String raca;
  final DateTime? dataNascimento;
  final String? cor;
  final double? peso;
  final String? observacoes;
  final int? usuarioId;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;
  final bool ativo;

  Pet({
    this.id,
    required this.nome,
    required this.especie,
    required this.raca,
    this.dataNascimento,
    this.cor,
    this.peso,
    this.observacoes,
    this.usuarioId,
    this.dataCriacao,
    this.dataAtualizacao,
    this.ativo = true,
  });

  /// Valida se o pet tem dados válidos
  bool isValid() {
    return nome.isNotEmpty &&
        especie.isNotEmpty &&
        raca.isNotEmpty &&
        nome.length >= 2 &&
        (peso == null || peso! > 0);
  }

  /// Calcula a idade do pet em anos
  int getIdadeEmAnos() {
    if (dataNascimento == null) return 0;

    final agora = DateTime.now();
    
    // Verifica se a data é no futuro
    if (dataNascimento!.isAfter(agora)) return 0;
    
    int idade = agora.year - dataNascimento!.year;

    if (agora.month < dataNascimento!.month ||
        (agora.month == dataNascimento!.month &&
            agora.day < dataNascimento!.day)) {
      idade--;
    }

    return idade < 0 ? 0 : idade;
  }

  /// Calcula a idade do pet em meses
  int getIdadeEmMeses() {
    if (dataNascimento == null) return 0;

    final agora = DateTime.now();
    
    // Verifica se a data é no futuro
    if (dataNascimento!.isAfter(agora)) return 0;
    
    int meses =
        (agora.year - dataNascimento!.year) * 12 +
        agora.month -
        dataNascimento!.month;

    if (agora.day < dataNascimento!.day) {
      meses--;
    }

    return meses < 0 ? 0 : meses;
  }

  /// Retorna descrição da idade formatada
  String getIdadeFormatada() {
    final anos = getIdadeEmAnos();
    final meses = getIdadeEmMeses();

    if (anos == 0) {
      if (meses == 0) return 'Recém-nascido';
      if (meses == 1) return '1 mês';
      return '$meses meses';
    }

    if (anos == 1) {
      final mesesRestantes = meses - 12;
      if (mesesRestantes <= 0) return '1 ano';
      if (mesesRestantes == 1) return '1 ano e 1 mês';
      return '1 ano e $mesesRestantes meses';
    }

    return '$anos anos';
  }

  /// Classifica o pet por faixa etária
  String getFaixaEtaria() {
    final meses = getIdadeEmMeses();

    if (meses < 6) return 'Filhote';
    if (meses < 12) return 'Jovem';
    if (meses < 84) return 'Adulto'; // 7 anos
    return 'Idoso';
  }

  /// Verifica se é um filhote
  bool isFilhote() => getIdadeEmMeses() < 12;

  /// Verifica se é idoso
  bool isIdoso() => getIdadeEmMeses() >= 84;

  /// Calcula IMC do pet (se tiver peso)
  String? getClassificacaoPeso() {
    if (peso == null) return null;

    // Classificação baseada em peso para diferentes espécies
    if (especie.toLowerCase() == 'gato') {
      if (peso! < 2.5) return 'Abaixo do peso';
      if (peso! <= 5.0) return 'Peso ideal';
      if (peso! <= 7.0) return 'Sobrepeso';
      return 'Obeso';
    }

    if (especie.toLowerCase() == 'cão' || especie.toLowerCase() == 'cachorro') {
      // Classificação genérica para cães (varia muito por raça)
      if (peso! < 5.0) return 'Pequeno porte';
      if (peso! <= 25.0) return 'Médio porte';
      return 'Grande porte';
    }

    return 'Peso registrado: ${peso!.toStringAsFixed(1)}kg';
  }

  /// Gera iniciais do nome para avatar
  String getIniciais() {
    final palavras = nome.trim().split(' ');

    if (palavras.isEmpty) return 'P';
    if (palavras.length == 1) {
      return palavras[0].isNotEmpty ? palavras[0][0].toUpperCase() : 'P';
    }

    return '${palavras[0][0]}${palavras[palavras.length - 1][0]}'.toUpperCase();
  }

  /// Verifica se precisa de vacinação (com base na idade)
  bool precisaVacinacao() {
    final meses = getIdadeEmMeses();

    // Filhotes precisam de mais vacinas
    if (meses < 6) return true;

    // Animais adultos precisam de reforço anual
    return true; // Simplificado - na prática verificaria histórico de vacinas
  }

  /// Cria cópia com campos alterados
  Pet copyWith({
    int? id,
    String? nome,
    String? especie,
    String? raca,
    DateTime? dataNascimento,
    String? cor,
    double? peso,
    String? observacoes,
    int? usuarioId,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    bool? ativo,
    bool clearDataNascimento = false,
    bool clearPeso = false,
  }) {
    return Pet(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      especie: especie ?? this.especie,
      raca: raca ?? this.raca,
      dataNascimento: clearDataNascimento ? null : (dataNascimento ?? this.dataNascimento),
      cor: cor ?? this.cor,
      peso: clearPeso ? null : (peso ?? this.peso),
      observacoes: observacoes ?? this.observacoes,
      usuarioId: usuarioId ?? this.usuarioId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      ativo: ativo ?? this.ativo,
    );
  }

  /// Converte para Map para API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'especie': especie,
      'raca': raca,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'cor': cor,
      'peso': peso,
      'observacoes': observacoes,
      'usuarioId': usuarioId,
      'dataCriacao': dataCriacao?.toIso8601String(),
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
      'ativo': ativo,
    };
  }

  /// Cria instância a partir de Map da API
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      nome: json['nome'] ?? '',
      especie: json['especie'] ?? '',
      raca: json['raca'] ?? '',
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.parse(json['dataNascimento'])
          : null,
      cor: json['cor'],
      peso: json['peso']?.toDouble(),
      observacoes: json['observacoes'],
      usuarioId: json['usuarioId'],
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'])
          : null,
      dataAtualizacao: json['dataAtualizacao'] != null
          ? DateTime.parse(json['dataAtualizacao'])
          : null,
      ativo: json['ativo'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pet &&
        other.id == id &&
        other.nome == nome &&
        other.especie == especie &&
        other.raca == raca &&
        other.dataNascimento == dataNascimento &&
        other.cor == cor &&
        other.peso == peso &&
        other.usuarioId == usuarioId &&
        other.ativo == ativo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        especie.hashCode ^
        raca.hashCode ^
        dataNascimento.hashCode ^
        cor.hashCode ^
        peso.hashCode ^
        usuarioId.hashCode ^
        ativo.hashCode;
  }

  @override
  String toString() {
    return 'Pet(id: $id, nome: $nome, especie: $especie, raca: $raca, idade: ${getIdadeFormatada()})';
  }
}
