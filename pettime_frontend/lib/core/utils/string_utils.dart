class StringUtils {
  
  /// Capitaliza a primeira letra de cada palavra
  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    
    return texto.split(' ')
        .map((palavra) => palavra.isEmpty 
            ? palavra 
            : palavra[0].toUpperCase() + palavra.substring(1).toLowerCase())
        .join(' ');
  }

  /// Remove acentos de uma string
  static String removerAcentos(String texto) {
    const acentos = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
      'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A',
      'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E',
      'Ì': 'I', 'Í': 'I', 'Î': 'I', 'Ï': 'I',
      'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö': 'O',
      'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U',
      'Ç': 'C', 'Ñ': 'N',
    };
    
    String resultado = texto;
    acentos.forEach((key, value) {
      resultado = resultado.replaceAll(key, value);
    });
    
    return resultado;
  }

  /// Formata um CPF para exibição (xxx.xxx.xxx-xx)
  static String formatarCPF(String cpf) {
    if (cpf.length != 11) return cpf;
    
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  /// Formata um telefone para exibição
  static String formatarTelefone(String telefone) {
    final numeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numeros.length == 11) {
      // Celular: (11) 99999-9999
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    } else if (numeros.length == 10) {
      // Fixo: (11) 9999-9999
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    }
    
    return telefone;
  }

  /// Formata um CEP para exibição (xxxxx-xxx)
  static String formatarCEP(String cep) {
    final numeros = cep.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numeros.length == 8) {
      return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
    }
    
    return cep;
  }

  /// Remove todos os caracteres não numéricos
  static String apenasNumeros(String texto) {
    return texto.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Remove todos os caracteres numéricos
  static String apenasLetras(String texto) {
    return texto.replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '');
  }

  /// Verifica se uma string contém apenas números
  static bool isApenasNumeros(String texto) {
    return RegExp(r'^\d+$').hasMatch(texto);
  }

  /// Verifica se uma string contém apenas letras
  static bool isApenasLetras(String texto) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(texto);
  }

  /// Trunca uma string adicionando reticências se necessário
  static String truncar(String texto, int tamanhoMaximo, {String sufixo = '...'}) {
    if (texto.length <= tamanhoMaximo) return texto;
    
    return texto.substring(0, tamanhoMaximo - sufixo.length) + sufixo;
  }

  /// Conta o número de palavras em uma string
  static int contarPalavras(String texto) {
    if (texto.trim().isEmpty) return 0;
    
    return texto.trim().split(RegExp(r'\s+')).length;
  }

  /// Gera iniciais a partir de um nome completo
  static String gerarIniciais(String nome, {int maximo = 2}) {
    if (nome.trim().isEmpty) return '';
    
    final palavras = nome.trim().split(' ');
    final iniciais = <String>[];
    
    for (int i = 0; i < palavras.length && iniciais.length < maximo; i++) {
      if (palavras[i].isNotEmpty) {
        iniciais.add(palavras[i][0].toUpperCase());
      }
    }
    
    return iniciais.join();
  }

  /// Verifica se uma string é um email válido
  static bool isEmailValido(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Converte uma string para formato slug (url-friendly)
  static String paraSlug(String texto) {
    String slug = removerAcentos(texto.toLowerCase());
    slug = slug.replaceAll(RegExp(r'[^\w\s-]'), '');
    slug = slug.replaceAll(RegExp(r'\s+'), '-');
    slug = slug.replaceAll(RegExp(r'-+'), '-');
    slug = slug.replaceAll(RegExp(r'^-|-$'), '');
    
    return slug;
  }

  /// Mascara uma string parcialmente (ex: email, cpf)
  static String mascarar(String texto, {int inicioVisivel = 3, int fimVisivel = 3, String mascara = '*'}) {
    if (texto.length <= inicioVisivel + fimVisivel) {
      return texto;
    }
    
    final inicio = texto.substring(0, inicioVisivel);
    final fim = texto.substring(texto.length - fimVisivel);
    final meio = mascara * (texto.length - inicioVisivel - fimVisivel);
    
    return inicio + meio + fim;
  }

  /// Calcula a distância de Levenshtein entre duas strings
  static int distanciaLevenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matriz = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matriz[i][0] = i;
    }

    for (int j = 0; j <= s2.length; j++) {
      matriz[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final custo = s1[i - 1] == s2[j - 1] ? 0 : 1;
        
        matriz[i][j] = [
          matriz[i - 1][j] + 1,      // deleção
          matriz[i][j - 1] + 1,      // inserção
          matriz[i - 1][j - 1] + custo, // substituição
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matriz[s1.length][s2.length];
  }

  /// Calcula a similaridade entre duas strings (0.0 a 1.0)
  static double calcularSimilaridade(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    
    final distancia = distanciaLevenshtein(s1, s2);
    final tamanhoMaximo = s1.length > s2.length ? s1.length : s2.length;
    
    return (tamanhoMaximo - distancia) / tamanhoMaximo;
  }

  /// Converte bytes para formato legível (KB, MB, GB)
  static String formatarTamanhoBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Gera uma string aleatória
  static String gerarStringAleatoria(int tamanho, {bool incluirNumeros = true, bool incluirMaiusculas = true}) {
    String caracteres = 'abcdefghijklmnopqrstuvwxyz';
    
    if (incluirMaiusculas) {
      caracteres += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    
    if (incluirNumeros) {
      caracteres += '0123456789';
    }
    
    final random = DateTime.now().millisecondsSinceEpoch;
    String resultado = '';
    
    for (int i = 0; i < tamanho; i++) {
      final indice = (random + i) % caracteres.length;
      resultado += caracteres[indice];
    }
    
    return resultado;
  }
}