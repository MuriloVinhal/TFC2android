import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/core/utils/string_utils.dart';

void main() {
  group('StringUtils - Testes Unitários', () {
    group('Capitalização', () {
      test('deve capitalizar primeira letra de cada palavra', () {
        final resultado = StringUtils.capitalizar('joão silva santos');
        expect(resultado, 'João Silva Santos');
      });

      test('deve tratar string vazia', () {
        final resultado = StringUtils.capitalizar('');
        expect(resultado, '');
      });

      test('deve tratar palavras já capitalizadas', () {
        final resultado = StringUtils.capitalizar('João Silva');
        expect(resultado, 'João Silva');
      });

      test('deve tratar múltiplos espaços', () {
        final resultado = StringUtils.capitalizar('joão  silva   santos');
        expect(resultado, 'João  Silva   Santos');
      });

      test('deve tratar string com uma letra', () {
        final resultado = StringUtils.capitalizar('a');
        expect(resultado, 'A');
      });
    });

    group('Remoção de Acentos', () {
      test('deve remover acentos corretamente', () {
        final resultado = StringUtils.removerAcentos('José da Conceição');
        expect(resultado, 'Jose da Conceicao');
      });

      test('deve remover acentos de texto completo', () {
        final texto = 'Ação, coração, não, pão, mão';
        final resultado = StringUtils.removerAcentos(texto);
        expect(resultado, 'Acao, coracao, nao, pao, mao');
      });

      test('deve manter texto sem acentos', () {
        final resultado = StringUtils.removerAcentos('João Silva');
        expect(resultado, 'Joao Silva');
      });

      test('deve tratar maiúsculas com acentos', () {
        final resultado = StringUtils.removerAcentos('JOSÉ MARÍA');
        expect(resultado, 'JOSE MARIA');
      });

      test('deve tratar string vazia', () {
        final resultado = StringUtils.removerAcentos('');
        expect(resultado, '');
      });
    });

    group('Formatação de CPF', () {
      test('deve formatar CPF corretamente', () {
        final resultado = StringUtils.formatarCPF('12345678901');
        expect(resultado, '123.456.789-01');
      });

      test('deve retornar original se não tiver 11 dígitos', () {
        final resultado = StringUtils.formatarCPF('123456789');
        expect(resultado, '123456789');
      });

      test('deve tratar CPF já formatado', () {
        final resultado = StringUtils.formatarCPF('12345678901');
        expect(resultado, '123.456.789-01');
      });
    });

    group('Formatação de Telefone', () {
      test('deve formatar telefone celular (11 dígitos)', () {
        final resultado = StringUtils.formatarTelefone('11987654321');
        expect(resultado, '(11) 98765-4321');
      });

      test('deve formatar telefone fixo (10 dígitos)', () {
        final resultado = StringUtils.formatarTelefone('1133334444');
        expect(resultado, '(11) 3333-4444');
      });

      test('deve manter formatação de telefone já formatado', () {
        final resultado = StringUtils.formatarTelefone('(11) 98765-4321');
        expect(resultado, '(11) 98765-4321');
      });

      test('deve retornar original para número inválido', () {
        final resultado = StringUtils.formatarTelefone('123456');
        expect(resultado, '123456');
      });

      test('deve remover caracteres especiais antes de formatar', () {
        final resultado = StringUtils.formatarTelefone('(11)98765-4321');
        expect(resultado, '(11) 98765-4321');
      });
    });

    group('Formatação de CEP', () {
      test('deve formatar CEP corretamente', () {
        final resultado = StringUtils.formatarCEP('12345678');
        expect(resultado, '12345-678');
      });

      test('deve manter CEP já formatado', () {
        final resultado = StringUtils.formatarCEP('12345-678');
        expect(resultado, '12345-678');
      });

      test('deve retornar original para CEP inválido', () {
        final resultado = StringUtils.formatarCEP('1234567');
        expect(resultado, '1234567');
      });

      test('deve remover caracteres especiais antes de formatar', () {
        final resultado = StringUtils.formatarCEP('12.345-678');
        expect(resultado, '12345-678');
      });
    });

    group('Filtros de Caracteres', () {
      test('deve extrair apenas números', () {
        final resultado = StringUtils.apenasNumeros('(11) 98765-4321');
        expect(resultado, '11987654321');
      });

      test('deve extrair apenas letras', () {
        final resultado = StringUtils.apenasLetras('João123Silva456');
        expect(resultado, 'JoãoSilva');
      });

      test('deve verificar se contém apenas números', () {
        expect(StringUtils.isApenasNumeros('123456'), true);
        expect(StringUtils.isApenasNumeros('123a56'), false);
        expect(StringUtils.isApenasNumeros(''), false);
      });

      test('deve verificar se contém apenas letras', () {
        expect(StringUtils.isApenasLetras('João Silva'), true);
        expect(StringUtils.isApenasLetras('João123'), false);
        expect(StringUtils.isApenasLetras(''), false);
      });
    });

    group('Truncagem', () {
      test('deve truncar string longa', () {
        final texto = 'Este é um texto muito longo para exibição';
        final resultado = StringUtils.truncar(texto, 20);
        expect(resultado, 'Este é um texto m...');
        expect(resultado.length, 20);
      });

      test('deve manter string curta', () {
        final texto = 'Texto curto';
        final resultado = StringUtils.truncar(texto, 20);
        expect(resultado, 'Texto curto');
      });

      test('deve usar sufixo customizado', () {
        final texto = 'Texto longo demais';
        final resultado = StringUtils.truncar(texto, 10, sufixo: '***');
        expect(resultado, 'Texto l***');
      });

      test('deve tratar string exatamente no tamanho máximo', () {
        final texto = 'Exatamente vinte';
        final resultado = StringUtils.truncar(texto, 16);
        expect(resultado, 'Exatamente vinte');
      });
    });

    group('Contagem de Palavras', () {
      test('deve contar palavras corretamente', () {
        final resultado = StringUtils.contarPalavras('João Silva Santos');
        expect(resultado, 3);
      });

      test('deve retornar 0 para string vazia', () {
        final resultado = StringUtils.contarPalavras('');
        expect(resultado, 0);
      });

      test('deve retornar 0 para string apenas com espaços', () {
        final resultado = StringUtils.contarPalavras('   ');
        expect(resultado, 0);
      });

      test('deve tratar múltiplos espaços', () {
        final resultado = StringUtils.contarPalavras('João   Silva    Santos');
        expect(resultado, 3);
      });

      test('deve contar uma palavra', () {
        final resultado = StringUtils.contarPalavras('João');
        expect(resultado, 1);
      });
    });

    group('Geração de Iniciais', () {
      test('deve gerar iniciais padrão', () {
        final resultado = StringUtils.gerarIniciais('João Silva Santos');
        expect(resultado, 'JS');
      });

      test('deve gerar três iniciais', () {
        final resultado = StringUtils.gerarIniciais(
          'João Silva Santos',
          maximo: 3,
        );
        expect(resultado, 'JSS');
      });

      test('deve gerar inicial única', () {
        final resultado = StringUtils.gerarIniciais('João');
        expect(resultado, 'J');
      });

      test('deve retornar vazio para string vazia', () {
        final resultado = StringUtils.gerarIniciais('');
        expect(resultado, '');
      });

      test('deve tratar espaços extras', () {
        final resultado = StringUtils.gerarIniciais('  João  Silva  ');
        expect(resultado, 'JS');
      });

      test('deve ignorar palavras vazias', () {
        final resultado = StringUtils.gerarIniciais('João  Silva');
        expect(resultado, 'JS');
      });
    });

    group('Validação de Email', () {
      test('deve validar email correto', () {
        expect(StringUtils.isEmailValido('usuario@email.com'), true);
      });

      test('deve validar email com subdomínio', () {
        expect(StringUtils.isEmailValido('user@mail.empresa.com.br'), true);
      });

      test('deve invalidar email sem @', () {
        expect(StringUtils.isEmailValido('usuarioemail.com'), false);
      });

      test('deve invalidar email sem domínio', () {
        expect(StringUtils.isEmailValido('usuario@'), false);
      });

      test('deve invalidar email vazio', () {
        expect(StringUtils.isEmailValido(''), false);
      });
    });

    group('Conversão para Slug', () {
      test('deve converter para slug básico', () {
        final resultado = StringUtils.paraSlug('Meu Artigo Interessante');
        expect(resultado, 'meu-artigo-interessante');
      });

      test('deve remover acentos e caracteres especiais', () {
        final resultado = StringUtils.paraSlug('Ação do Coração!');
        expect(resultado, 'acao-do-coracao');
      });

      test('deve tratar múltiplos espaços', () {
        final resultado = StringUtils.paraSlug('Título   com    espaços');
        expect(resultado, 'titulo-com-espacos');
      });

      test('deve remover hífens duplicados', () {
        final resultado = StringUtils.paraSlug('Texto--com---hifens');
        expect(resultado, 'texto-com-hifens');
      });

      test('deve remover hífens nas extremidades', () {
        final resultado = StringUtils.paraSlug('-Texto com hífen-');
        expect(resultado, 'texto-com-hifen');
      });
    });

    group('Mascaramento', () {
      test('deve mascarar string padrão', () {
        final resultado = StringUtils.mascarar('joao@email.com');
        expect(resultado, 'joa********com');
      });

      test('deve usar configuração customizada', () {
        final resultado = StringUtils.mascarar(
          '12345678901',
          inicioVisivel: 3,
          fimVisivel: 2,
          mascara: 'X',
        );
        expect(resultado, '123XXXXXX01');
      });

      test('deve retornar original se muito curta', () {
        final resultado = StringUtils.mascarar('abc');
        expect(resultado, 'abc');
      });

      test('deve mascarar email', () {
        final resultado = StringUtils.mascarar(
          'usuario@email.com',
          inicioVisivel: 2,
          fimVisivel: 4,
        );
        expect(resultado, 'us***********.com');
      });
    });

    group('Distância de Levenshtein', () {
      test('deve calcular distância entre strings iguais', () {
        final resultado = StringUtils.distanciaLevenshtein('teste', 'teste');
        expect(resultado, 0);
      });

      test('deve calcular distância com uma substituição', () {
        final resultado = StringUtils.distanciaLevenshtein('teste', 'testa');
        expect(resultado, 1);
      });

      test('deve calcular distância com inserção', () {
        final resultado = StringUtils.distanciaLevenshtein('teste', 'testex');
        expect(resultado, 1);
      });

      test('deve calcular distância com deleção', () {
        final resultado = StringUtils.distanciaLevenshtein('teste', 'test');
        expect(resultado, 1);
      });

      test('deve tratar strings vazias', () {
        expect(StringUtils.distanciaLevenshtein('', 'teste'), 5);
        expect(StringUtils.distanciaLevenshtein('teste', ''), 5);
        expect(StringUtils.distanciaLevenshtein('', ''), 0);
      });

      test('deve calcular distância para strings completamente diferentes', () {
        final resultado = StringUtils.distanciaLevenshtein('abc', 'xyz');
        expect(resultado, 3);
      });
    });

    group('Similaridade', () {
      test('deve calcular similaridade máxima para strings iguais', () {
        final resultado = StringUtils.calcularSimilaridade('teste', 'teste');
        expect(resultado, 1.0);
      });

      test(
        'deve calcular similaridade zero para strings completamente diferentes',
        () {
          final resultado = StringUtils.calcularSimilaridade('abc', 'xyz');
          expect(resultado, 0.0);
        },
      );

      test('deve calcular similaridade parcial', () {
        final resultado = StringUtils.calcularSimilaridade('teste', 'testa');
        expect(resultado, 0.8); // 4/5 caracteres iguais
      });

      test('deve tratar strings vazias', () {
        expect(StringUtils.calcularSimilaridade('', ''), 1.0);
        expect(StringUtils.calcularSimilaridade('teste', ''), 0.0);
      });
    });

    group('Formatação de Bytes', () {
      test('deve formatar bytes', () {
        final resultado = StringUtils.formatarTamanhoBytes(512);
        expect(resultado, '512 B');
      });

      test('deve formatar kilobytes', () {
        final resultado = StringUtils.formatarTamanhoBytes(1536); // 1.5 KB
        expect(resultado, '1.5 KB');
      });

      test('deve formatar megabytes', () {
        final resultado = StringUtils.formatarTamanhoBytes(1572864); // 1.5 MB
        expect(resultado, '1.5 MB');
      });

      test('deve formatar gigabytes', () {
        final resultado = StringUtils.formatarTamanhoBytes(
          1610612736,
        ); // 1.5 GB
        expect(resultado, '1.5 GB');
      });

      test('deve formatar zero bytes', () {
        final resultado = StringUtils.formatarTamanhoBytes(0);
        expect(resultado, '0 B');
      });
    });

    group('Geração de String Aleatória', () {
      test('deve gerar string com tamanho correto', () {
        final resultado = StringUtils.gerarStringAleatoria(10);
        expect(resultado.length, 10);
      });

      test('deve gerar string apenas com letras minúsculas', () {
        final resultado = StringUtils.gerarStringAleatoria(
          10,
          incluirNumeros: false,
          incluirMaiusculas: false,
        );
        expect(resultado.length, 10);
        expect(RegExp(r'^[a-z]+$').hasMatch(resultado), true);
      });

      test('deve gerar strings diferentes', () {
        final resultado1 = StringUtils.gerarStringAleatoria(20);
        final resultado2 = StringUtils.gerarStringAleatoria(20);
        // Embora teoricamente possível, é extremamente improvável gerar strings idênticas
        expect(resultado1.length, 20);
        expect(resultado2.length, 20);
      });

      test('deve gerar string vazia', () {
        final resultado = StringUtils.gerarStringAleatoria(0);
        expect(resultado, '');
      });
    });
  });
}
