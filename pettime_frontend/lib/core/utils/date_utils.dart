class DateUtils {
  
  /// Formata uma data para o padrão brasileiro dd/MM/yyyy
  static String formatarDataBR(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
           '${data.month.toString().padLeft(2, '0')}/'
           '${data.year}';
  }

  /// Formata uma data e hora para o padrão brasileiro dd/MM/yyyy HH:mm
  static String formatarDataHoraBR(DateTime dataHora) {
    return '${formatarDataBR(dataHora)} '
           '${dataHora.hour.toString().padLeft(2, '0')}:'
           '${dataHora.minute.toString().padLeft(2, '0')}';
  }

  /// Calcula a idade em anos a partir da data de nascimento
  static int calcularIdade(DateTime dataNascimento) {
    final hoje = DateTime.now();
    int idade = hoje.year - dataNascimento.year;
    
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      idade--;
    }
    
    return idade < 0 ? 0 : idade;
  }

  /// Calcula a diferença em dias entre duas datas
  static int diferencaEmDias(DateTime dataInicial, DateTime dataFinal) {
    return dataFinal.difference(dataInicial).inDays;
  }

  /// Calcula a diferença em horas entre duas datas
  static int diferencaEmHoras(DateTime dataInicial, DateTime dataFinal) {
    return dataFinal.difference(dataInicial).inHours;
  }

  /// Verifica se uma data é hoje
  static bool isHoje(DateTime data) {
    final hoje = DateTime.now();
    return data.year == hoje.year &&
           data.month == hoje.month &&
           data.day == hoje.day;
  }

  /// Verifica se uma data é amanhã
  static bool isAmanha(DateTime data) {
    final amanha = DateTime.now().add(Duration(days: 1));
    return data.year == amanha.year &&
           data.month == amanha.month &&
           data.day == amanha.day;
  }

  /// Verifica se uma data é ontem
  static bool isOntem(DateTime data) {
    final ontem = DateTime.now().subtract(Duration(days: 1));
    return data.year == ontem.year &&
           data.month == ontem.month &&
           data.day == ontem.day;
  }

  /// Verifica se uma data está nesta semana
  static bool isNestaSemana(DateTime data) {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
    final fimSemana = inicioSemana.add(Duration(days: 6));
    
    return data.isAfter(inicioSemana.subtract(Duration(days: 1))) &&
           data.isBefore(fimSemana.add(Duration(days: 1)));
  }

  /// Verifica se uma data está neste mês
  static bool isNesteMes(DateTime data) {
    final agora = DateTime.now();
    return data.year == agora.year && data.month == agora.month;
  }

  /// Verifica se uma data está neste ano
  static bool isNesteAno(DateTime data) {
    final agora = DateTime.now();
    return data.year == agora.year;
  }

  /// Retorna o nome do mês em português
  static String getNomeMes(int mes) {
    const meses = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    
    return mes >= 1 && mes <= 12 ? meses[mes] : '';
  }

  /// Retorna o nome do dia da semana em português
  static String getNomeDiaSemana(int diaSemana) {
    const dias = [
      '', 'Segunda-feira', 'Terça-feira', 'Quarta-feira',
      'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'
    ];
    
    return diaSemana >= 1 && diaSemana <= 7 ? dias[diaSemana] : '';
  }

  /// Retorna o primeiro dia do mês
  static DateTime getPrimeiroDiaDoMes(DateTime data) {
    return DateTime(data.year, data.month, 1);
  }

  /// Retorna o último dia do mês
  static DateTime getUltimoDiaDoMes(DateTime data) {
    return DateTime(data.year, data.month + 1, 0);
  }

  /// Verifica se um ano é bissexto
  static bool isAnoBissexto(int ano) {
    return (ano % 4 == 0 && ano % 100 != 0) || (ano % 400 == 0);
  }

  /// Retorna o número de dias no mês
  static int getDiasNoMes(int ano, int mes) {
    if (mes == 2) {
      return isAnoBissexto(ano) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(mes)) {
      return 30;
    } else {
      return 31;
    }
  }

  /// Adiciona dias úteis (excluindo fins de semana)
  static DateTime adicionarDiasUteis(DateTime data, int dias) {
    DateTime resultado = data;
    int diasAdicionados = 0;
    
    while (diasAdicionados < dias) {
      resultado = resultado.add(Duration(days: 1));
      
      // Verifica se não é fim de semana (sábado = 6, domingo = 7)
      if (resultado.weekday < 6) {
        diasAdicionados++;
      }
    }
    
    return resultado;
  }

  /// Conta quantos dias úteis há entre duas datas
  static int contarDiasUteis(DateTime dataInicial, DateTime dataFinal) {
    int diasUteis = 0;
    DateTime data = dataInicial;
    
    while (data.isBefore(dataFinal) || data.isAtSameMomentAs(dataFinal)) {
      if (data.weekday < 6) { // Segunda a sexta
        diasUteis++;
      }
      data = data.add(Duration(days: 1));
    }
    
    return diasUteis;
  }

  /// Verifica se uma data é dia útil
  static bool isDiaUtil(DateTime data) {
    return data.weekday < 6; // Segunda a sexta (1-5)
  }

  /// Verifica se uma data é fim de semana
  static bool isFimDeSemana(DateTime data) {
    return data.weekday >= 6; // Sábado e domingo (6-7)
  }

  /// Retorna uma descrição relativa da data (ex: "há 2 dias", "em 3 dias")
  static String getDescricaoRelativa(DateTime data) {
    final agora = DateTime.now();
    final diferenca = data.difference(agora);
    
    if (isHoje(data)) return 'Hoje';
    if (isOntem(data)) return 'Ontem';
    if (isAmanha(data)) return 'Amanhã';
    
    final dias = diferenca.inDays;
    
    if (dias > 0) {
      if (dias == 1) return 'Amanhã';
      if (dias < 7) return 'Em $dias dias';
      if (dias < 30) {
        final semanas = (dias / 7).floor();
        return semanas == 1 ? 'Em 1 semana' : 'Em $semanas semanas';
      }
      if (dias < 365) {
        final meses = (dias / 30).floor();
        return meses == 1 ? 'Em 1 mês' : 'Em $meses meses';
      }
      final anos = (dias / 365).floor();
      return anos == 1 ? 'Em 1 ano' : 'Em $anos anos';
    } else {
      final diasAbs = dias.abs();
      if (diasAbs == 1) return 'Ontem';
      if (diasAbs < 7) return 'Há $diasAbs dias';
      if (diasAbs < 30) {
        final semanas = (diasAbs / 7).floor();
        return semanas == 1 ? 'Há 1 semana' : 'Há $semanas semanas';
      }
      if (diasAbs < 365) {
        final meses = (diasAbs / 30).floor();
        return meses == 1 ? 'Há 1 mês' : 'Há $meses meses';
      }
      final anos = (diasAbs / 365).floor();
      return anos == 1 ? 'Há 1 ano' : 'Há $anos anos';
    }
  }

  /// Converte string no formato dd/MM/yyyy para DateTime
  static DateTime? parseDataBR(String dataStr) {
    try {
      final parts = dataStr.split('/');
      if (parts.length != 3) return null;
      
      final dia = int.parse(parts[0]);
      final mes = int.parse(parts[1]);
      final ano = int.parse(parts[2]);
      
      return DateTime(ano, mes, dia);
    } catch (e) {
      return null;
    }
  }
}