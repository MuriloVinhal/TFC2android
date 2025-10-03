class FormValidator {
  /// Valida se uma string não está vazia
  static String? validarCampoObrigatorio(String? valor, [String? nomeCampo]) {
    if (valor == null || valor.trim().isEmpty) {
      return '${nomeCampo ?? 'Este campo'} é obrigatório';
    }
    return null;
  }

  /// Valida formato de email
  static String? validarEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email é obrigatório';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Digite um email válido';
    }

    // Verifica comprimento máximo
    if (email.length > 254) {
      return 'Email muito longo';
    }

    return null;
  }

  /// Valida senha com critérios de segurança rigorosos
  static String? validarSenha(String? senha) {
    if (senha == null || senha.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (senha.length < 8) {
      return 'A senha deve ter no mínimo 8 caracteres';
    }

    if (senha.length > 50) {
      return 'Senha muito longa (máximo 50 caracteres)';
    }

    // Verifica se tem pelo menos uma letra maiúscula
    if (!RegExp(r'[A-Z]').hasMatch(senha)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }

    // Verifica se tem pelo menos uma letra minúscula
    if (!RegExp(r'[a-z]').hasMatch(senha)) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }

    // Verifica se tem pelo menos um número
    if (!RegExp(r'\d').hasMatch(senha)) {
      return 'Senha deve conter pelo menos um número';
    }

    // Verifica se tem pelo menos um símbolo
    if (!RegExp(
      r'''[!@#\$%\^&\*\(\)_\+\-=\[\]{};:'",.<>?]''',
    ).hasMatch(senha)) {
      return 'Senha deve conter pelo menos um símbolo';
    }

    return null;
  }

  /// Valida confirmação de senha
  static String? validarConfirmacaoSenha(String? senha, String? confirmacao) {
    if (confirmacao == null || confirmacao.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }

    if (senha != confirmacao) {
      return 'Senhas não coincidem';
    }

    return null;
  }

  /// Valida telefone brasileiro
  static String? validarTelefone(String? telefone) {
    if (telefone == null || telefone.isEmpty) {
      return 'Telefone é obrigatório';
    }

    // Remove caracteres especiais
    final numeros = telefone.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length < 10 || numeros.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }

    // Valida código de área (11-99)
    final codigoArea = int.tryParse(numeros.substring(0, 2));
    if (codigoArea == null || codigoArea < 11 || codigoArea > 99) {
      return 'Código de área inválido';
    }

    // Para celular (11 dígitos), o primeiro dígito após o código deve ser 9
    if (numeros.length == 11) {
      if (numeros[2] != '9') {
        return 'Número de celular inválido';
      }
    }

    return null;
  }

  /// Valida nome completo
  static String? validarNome(String? nome) {
    if (nome == null || nome.trim().isEmpty) {
      return 'Nome é obrigatório';
    }

    final nomeLimpo = nome.trim();

    if (nomeLimpo.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    if (nomeLimpo.length > 100) {
      return 'Nome muito longo (máximo 100 caracteres)';
    }

    // Verifica se contém apenas letras (incluindo acentos), espaços e hífens
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.]+$').hasMatch(nomeLimpo)) {
      return 'Nome contém caracteres inválidos';
    }

    // Verifica se tem pelo menos um espaço (nome e sobrenome)
    final palavras = nomeLimpo.split(' ').where((p) => p.isNotEmpty).toList();
    if (palavras.length < 2) {
      return 'Digite nome e sobrenome';
    }

    return null;
  }

  /// Valida data de nascimento
  static String? validarDataNascimento(DateTime? data) {
    if (data == null) {
      return 'Data de nascimento é obrigatória';
    }

    final hoje = DateTime.now();
    final idade = hoje.year - data.year;

    // Verifica se não é no futuro
    if (data.isAfter(hoje)) {
      return 'Data não pode ser no futuro';
    }

    // Verifica idade mínima (0 anos) e máxima (150 anos)
    if (idade < 0) {
      return 'Data inválida';
    }

    if (idade > 150) {
      return 'Data muito antiga';
    }

    return null;
  }

  /// Valida peso em quilos
  static String? validarPeso(String? pesoStr) {
    if (pesoStr == null || pesoStr.trim().isEmpty) {
      return null; // Peso é opcional
    }

    final peso = double.tryParse(pesoStr.replaceAll(',', '.'));

    if (peso == null) {
      return 'Digite um peso válido';
    }

    if (peso <= 0) {
      return 'Peso deve ser maior que zero';
    }

    if (peso > 1000) {
      return 'Peso muito alto (máximo 1000kg)';
    }

    return null;
  }

  /// Valida CPF brasileiro
  static String? validarCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) {
      return 'CPF é obrigatório';
    }

    // Remove caracteres especiais
    final numeros = cpf.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(numeros)) {
      return 'CPF inválido';
    }

    // Validação dos dígitos verificadores
    if (!_validarDigitosCPF(numeros)) {
      return 'CPF inválido';
    }

    return null;
  }

  static bool _validarDigitosCPF(String cpf) {
    // Calcula primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int primeiroDigito = (soma * 10) % 11;
    if (primeiroDigito == 10) primeiroDigito = 0;

    if (primeiroDigito != int.parse(cpf[9])) return false;

    // Calcula segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    int segundoDigito = (soma * 10) % 11;
    if (segundoDigito == 10) segundoDigito = 0;

    return segundoDigito == int.parse(cpf[10]);
  }

  /// Valida CEP brasileiro
  static String? validarCEP(String? cep) {
    if (cep == null || cep.isEmpty) {
      return null; // CEP é opcional
    }

    // Remove caracteres especiais
    final numeros = cep.replaceAll(RegExp(r'[^\d]'), '');

    if (numeros.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }

    // Verifica se não são todos zeros
    if (numeros == '00000000') {
      return 'CEP inválido';
    }

    return null;
  }

  /// Valida horário no formato HH:mm
  static String? validarHorario(String? horario) {
    if (horario == null || horario.isEmpty) {
      return 'Horário é obrigatório';
    }

    final horarioRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

    if (!horarioRegex.hasMatch(horario)) {
      return 'Digite um horário válido (HH:mm)';
    }

    return null;
  }
}
