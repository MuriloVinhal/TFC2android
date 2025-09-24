class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String telefone;
  final String? endereco;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;
  final bool ativo;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.endereco,
    this.dataCriacao,
    this.dataAtualizacao,
    this.ativo = true,
  });

  /// Valida se o usuário tem dados válidos
  bool isValid() {
    return nome.isNotEmpty &&
        isEmailValid() &&
        isTelefoneValid() &&
        nome.length >= 2;
  }

  /// Valida formato do email
  bool isEmailValid() {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Valida formato do telefone brasileiro
  bool isTelefoneValid() {
    // Remove caracteres especiais
    final telefoneNumeros = telefone.replaceAll(RegExp(r'[^\d]'), '');

    // Valida se tem 10 ou 11 dígitos (fixo ou celular)
    return telefoneNumeros.length == 10 || telefoneNumeros.length == 11;
  }

  /// Formata o telefone para exibição
  String getTelefoneFormatado() {
    final numeros = telefone.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length == 11) {
      // Celular: (11) 99999-9999
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    } else if (numeros.length == 10) {
      // Fixo: (11) 9999-9999
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    }

    return telefone; // Retorna original se inválido
  }

  /// Verifica se é um usuário novo (sem ID)
  bool isNovo() => id == null;

  /// Verifica se o usuário foi criado recentemente (últimas 24h)
  bool isCriadoRecentemente() {
    if (dataCriacao == null) return false;

    final agora = DateTime.now();
    final diferencaHoras = agora.difference(dataCriacao!).inHours;

    return diferencaHoras <= 24;
  }

  /// Calcula a idade da conta em dias
  int getIdadeContaEmDias() {
    if (dataCriacao == null) return 0;

    return DateTime.now().difference(dataCriacao!).inDays;
  }

  /// Gera iniciais do nome para avatar
  String getIniciais() {
    final palavras = nome.trim().split(' ');

    if (palavras.isEmpty) return 'U';
    if (palavras.length == 1) {
      return palavras[0].isNotEmpty ? palavras[0][0].toUpperCase() : 'U';
    }

    return '${palavras[0][0]}${palavras[palavras.length - 1][0]}'.toUpperCase();
  }

  /// Cria cópia com campos alterados
  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? endereco,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    bool? ativo,
    bool clearId = false,
    bool clearDataCriacao = false,
  }) {
    return Usuario(
      id: clearId ? null : (id ?? this.id),
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      dataCriacao: clearDataCriacao ? null : (dataCriacao ?? this.dataCriacao),
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      ativo: ativo ?? this.ativo,
    );
  }

  /// Converte para Map para API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'dataCriacao': dataCriacao?.toIso8601String(),
      'dataAtualizacao': dataAtualizacao?.toIso8601String(),
      'ativo': ativo,
    };
  }

  /// Cria instância a partir de Map da API
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'],
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

    return other is Usuario &&
        other.id == id &&
        other.nome == nome &&
        other.email == email &&
        other.telefone == telefone &&
        other.endereco == endereco &&
        other.ativo == ativo;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        email.hashCode ^
        telefone.hashCode ^
        endereco.hashCode ^
        ativo.hashCode;
  }

  @override
  String toString() {
    return 'Usuario(id: $id, nome: $nome, email: $email, telefone: $telefone, ativo: $ativo)';
  }
}
