import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/core/utils/date_utils.dart';

void main() {
  group('DateUtils - Testes Unitários', () {
    group('Formatação de Data', () {
      test('deve formatar data brasileira corretamente', () {
        final data = DateTime(2023, 6, 15);
        final resultado = DateUtils.formatarDataBR(data);
        expect(resultado, '15/06/2023');
      });

      test('deve formatar data com zeros à esquerda', () {
        final data = DateTime(2023, 1, 5);
        final resultado = DateUtils.formatarDataBR(data);
        expect(resultado, '05/01/2023');
      });

      test('deve formatar data e hora brasileira', () {
        final dataHora = DateTime(2023, 6, 15, 14, 30);
        final resultado = DateUtils.formatarDataHoraBR(dataHora);
        expect(resultado, '15/06/2023 14:30');
      });

      test('deve formatar hora com zeros à esquerda', () {
        final dataHora = DateTime(2023, 6, 15, 9, 5);
        final resultado = DateUtils.formatarDataHoraBR(dataHora);
        expect(resultado, '15/06/2023 09:05');
      });
    });

    group('Cálculo de Idade', () {
      test('deve calcular idade corretamente', () {
        final nascimento = DateTime(1990, 6, 15);
        final idade = DateUtils.calcularIdade(nascimento);
        expect(idade, greaterThanOrEqualTo(30));
        expect(idade, lessThanOrEqualTo(35));
      });

      test('deve calcular idade para aniversário não chegado', () {
        final agora = DateTime.now();
        final nascimento = DateTime(
          agora.year - 25,
          agora.month + 1,
          agora.day,
        );
        final idade = DateUtils.calcularIdade(nascimento);
        expect(idade, 24); // Ainda não fez aniversário este ano
      });

      test('deve calcular idade para aniversário já passou', () {
        final agora = DateTime.now();
        final nascimento = DateTime(
          agora.year - 25,
          agora.month - 1,
          agora.day,
        );
        final idade = DateUtils.calcularIdade(nascimento);
        expect(idade, 25); // Já fez aniversário este ano
      });

      test('deve retornar 0 para idade negativa', () {
        final futuro = DateTime.now().add(Duration(days: 365));
        final idade = DateUtils.calcularIdade(futuro);
        expect(idade, 0);
      });

      test('deve calcular idade para recém-nascido', () {
        final hoje = DateTime.now();
        final idade = DateUtils.calcularIdade(hoje);
        expect(idade, 0);
      });
    });

    group('Diferenças de Tempo', () {
      test('deve calcular diferença em dias', () {
        final inicio = DateTime(2023, 6, 1);
        final fim = DateTime(2023, 6, 15);
        final diferenca = DateUtils.diferencaEmDias(inicio, fim);
        expect(diferenca, 14);
      });

      test('deve calcular diferença em horas', () {
        final inicio = DateTime(2023, 6, 15, 10, 0);
        final fim = DateTime(2023, 6, 15, 15, 30);
        final diferenca = DateUtils.diferencaEmHoras(inicio, fim);
        expect(diferenca, 5);
      });

      test('deve retornar diferença negativa para datas invertidas', () {
        final inicio = DateTime(2023, 6, 15);
        final fim = DateTime(2023, 6, 10);
        final diferenca = DateUtils.diferencaEmDias(inicio, fim);
        expect(diferenca, -5);
      });
    });

    group('Verificações de Data', () {
      test('deve identificar se é hoje', () {
        final hoje = DateTime.now();
        expect(DateUtils.isHoje(hoje), true);
      });

      test('deve identificar que não é hoje', () {
        final ontem = DateTime.now().subtract(Duration(days: 1));
        expect(DateUtils.isHoje(ontem), false);
      });

      test('deve identificar se é amanhã', () {
        final amanha = DateTime.now().add(Duration(days: 1));
        expect(DateUtils.isAmanha(amanha), true);
      });

      test('deve identificar se é ontem', () {
        final ontem = DateTime.now().subtract(Duration(days: 1));
        expect(DateUtils.isOntem(ontem), true);
      });

      test('deve identificar se é nesta semana', () {
        final hoje = DateTime.now();
        expect(DateUtils.isNestaSemana(hoje), true);

        final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
        expect(DateUtils.isNestaSemana(inicioSemana), true);

        final fimSemana = inicioSemana.add(Duration(days: 6));
        expect(DateUtils.isNestaSemana(fimSemana), true);
      });

      test('deve identificar se é neste mês', () {
        final hoje = DateTime.now();
        expect(DateUtils.isNesteMes(hoje), true);

        final primeiroDia = DateTime(hoje.year, hoje.month, 1);
        expect(DateUtils.isNesteMes(primeiroDia), true);
      });

      test('deve identificar se é neste ano', () {
        final hoje = DateTime.now();
        expect(DateUtils.isNesteAno(hoje), true);

        final janeiro = DateTime(hoje.year, 1, 1);
        expect(DateUtils.isNesteAno(janeiro), true);

        final anoPassado = DateTime(hoje.year - 1, 12, 31);
        expect(DateUtils.isNesteAno(anoPassado), false);
      });
    });

    group('Nomes de Período', () {
      test('deve retornar nomes dos meses corretos', () {
        expect(DateUtils.getNomeMes(1), 'Janeiro');
        expect(DateUtils.getNomeMes(6), 'Junho');
        expect(DateUtils.getNomeMes(12), 'Dezembro');
      });

      test('deve retornar string vazia para mês inválido', () {
        expect(DateUtils.getNomeMes(0), '');
        expect(DateUtils.getNomeMes(13), '');
        expect(DateUtils.getNomeMes(-1), '');
      });

      test('deve retornar nomes dos dias da semana corretos', () {
        expect(DateUtils.getNomeDiaSemana(1), 'Segunda-feira');
        expect(DateUtils.getNomeDiaSemana(4), 'Quinta-feira');
        expect(DateUtils.getNomeDiaSemana(7), 'Domingo');
      });

      test('deve retornar string vazia para dia inválido', () {
        expect(DateUtils.getNomeDiaSemana(0), '');
        expect(DateUtils.getNomeDiaSemana(8), '');
      });
    });

    group('Operações de Mês', () {
      test('deve retornar primeiro dia do mês', () {
        final data = DateTime(2023, 6, 15);
        final primeiro = DateUtils.getPrimeiroDiaDoMes(data);
        expect(primeiro.day, 1);
        expect(primeiro.month, 6);
        expect(primeiro.year, 2023);
      });

      test('deve retornar último dia do mês', () {
        final data = DateTime(2023, 6, 15);
        final ultimo = DateUtils.getUltimoDiaDoMes(data);
        expect(ultimo.day, 30); // Junho tem 30 dias
        expect(ultimo.month, 6);
      });

      test('deve retornar último dia de fevereiro em ano bissexto', () {
        final data = DateTime(2024, 2, 15); // 2024 é bissexto
        final ultimo = DateUtils.getUltimoDiaDoMes(data);
        expect(ultimo.day, 29);
      });

      test('deve retornar último dia de fevereiro em ano não bissexto', () {
        final data = DateTime(2023, 2, 15); // 2023 não é bissexto
        final ultimo = DateUtils.getUltimoDiaDoMes(data);
        expect(ultimo.day, 28);
      });
    });

    group('Anos Bissextos', () {
      test('deve identificar anos bissextos', () {
        expect(DateUtils.isAnoBissexto(2024), true);
        expect(DateUtils.isAnoBissexto(2020), true);
        expect(DateUtils.isAnoBissexto(2000), true);
      });

      test('deve identificar anos não bissextos', () {
        expect(DateUtils.isAnoBissexto(2023), false);
        expect(DateUtils.isAnoBissexto(2021), false);
        expect(
          DateUtils.isAnoBissexto(1900),
          false,
        ); // Divisível por 100 mas não por 400
      });

      test('deve calcular dias no mês corretamente', () {
        expect(DateUtils.getDiasNoMes(2023, 1), 31); // Janeiro
        expect(DateUtils.getDiasNoMes(2023, 2), 28); // Fevereiro não bissexto
        expect(DateUtils.getDiasNoMes(2024, 2), 29); // Fevereiro bissexto
        expect(DateUtils.getDiasNoMes(2023, 4), 30); // Abril
        expect(DateUtils.getDiasNoMes(2023, 12), 31); // Dezembro
      });
    });

    group('Dias Úteis', () {
      test('deve identificar dia útil', () {
        final segunda = DateTime(2023, 6, 12); // Segunda-feira
        expect(DateUtils.isDiaUtil(segunda), true);

        final sexta = DateTime(2023, 6, 16); // Sexta-feira
        expect(DateUtils.isDiaUtil(sexta), true);
      });

      test('deve identificar fim de semana', () {
        final sabado = DateTime(2023, 6, 17); // Sábado
        expect(DateUtils.isDiaUtil(sabado), false);
        expect(DateUtils.isFimDeSemana(sabado), true);

        final domingo = DateTime(2023, 6, 18); // Domingo
        expect(DateUtils.isDiaUtil(domingo), false);
        expect(DateUtils.isFimDeSemana(domingo), true);
      });

      test('deve adicionar dias úteis corretamente', () {
        final sexta = DateTime(2023, 6, 16); // Sexta-feira
        final resultado = DateUtils.adicionarDiasUteis(sexta, 1);
        expect(resultado.weekday, 1); // Segunda-feira seguinte
      });

      test('deve contar dias úteis entre datas', () {
        final segunda = DateTime(2023, 6, 12); // Segunda-feira
        final sexta = DateTime(2023, 6, 16); // Sexta-feira da mesma semana
        final diasUteis = DateUtils.contarDiasUteis(segunda, sexta);
        expect(diasUteis, 5); // Segunda a sexta = 5 dias úteis
      });
    });

    group('Descrição Relativa', () {
      test('deve retornar "Hoje" para data atual', () {
        final hoje = DateTime.now();
        expect(DateUtils.getDescricaoRelativa(hoje), 'Hoje');
      });

      test('deve retornar "Ontem" para data anterior', () {
        final ontem = DateTime.now().subtract(Duration(days: 1));
        expect(DateUtils.getDescricaoRelativa(ontem), 'Ontem');
      });

      test('deve retornar "Amanhã" para próximo dia', () {
        final amanha = DateTime.now().add(Duration(days: 1));
        expect(DateUtils.getDescricaoRelativa(amanha), 'Amanhã');
      });

      test('deve retornar descrição em dias para futuro próximo', () {
        final futuro = DateTime.now().add(Duration(days: 3));
        final descricao = DateUtils.getDescricaoRelativa(futuro);
        expect(descricao, 'Em 3 dias');
      });

      test('deve retornar descrição em dias para passado próximo', () {
        final passado = DateTime.now().subtract(Duration(days: 3));
        final descricao = DateUtils.getDescricaoRelativa(passado);
        expect(descricao, 'Há 3 dias');
      });

      test('deve retornar descrição em semanas', () {
        final futuro = DateTime.now().add(Duration(days: 14));
        final descricao = DateUtils.getDescricaoRelativa(futuro);
        expect(descricao, 'Em 2 semanas');
      });

      test('deve retornar descrição em meses', () {
        final futuro = DateTime.now().add(Duration(days: 60));
        final descricao = DateUtils.getDescricaoRelativa(futuro);
        expect(descricao, 'Em 2 meses');
      });
    });

    group('Parse de Data Brasileira', () {
      test('deve parsear data brasileira válida', () {
        final data = DateUtils.parseDataBR('15/06/2023');
        expect(data, isNotNull);
        expect(data!.day, 15);
        expect(data.month, 6);
        expect(data.year, 2023);
      });

      test('deve retornar null para formato inválido', () {
        expect(DateUtils.parseDataBR('2023-06-15'), null);
        expect(DateUtils.parseDataBR('15-06-2023'), null);
        expect(DateUtils.parseDataBR('invalid'), null);
      });

      test('deve retornar null para data inválida', () {
        expect(DateUtils.parseDataBR('32/06/2023'), null);
        expect(DateUtils.parseDataBR('15/13/2023'), null);
      });

      test('deve tratar zeros à esquerda', () {
        final data = DateUtils.parseDataBR('05/01/2023');
        expect(data, isNotNull);
        expect(data!.day, 5);
        expect(data.month, 1);
      });
    });
  });
}
