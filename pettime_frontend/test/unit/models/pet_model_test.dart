import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/data/models/pet_model.dart';

void main() {
  group('Pet Model - Testes Unitários', () {
    late Pet petValido;
    late DateTime dataFixa;

    setUp(() {
      dataFixa = DateTime(2022, 1, 15); // Pet de ~2 anos
      petValido = Pet(
        id: 1,
        nome: 'Rex',
        especie: 'Cão',
        raca: 'Labrador',
        dataNascimento: dataFixa,
        cor: 'Marrom',
        peso: 25.5,
        usuarioId: 1,
        ativo: true,
      );
    });

    group('Validações', () {
      test('deve validar pet com dados corretos', () {
        expect(petValido.isValid(), true);
      });

      test('deve invalidar pet com nome vazio', () {
        final pet = petValido.copyWith(nome: '');
        expect(pet.isValid(), false);
      });

      test('deve invalidar pet com nome muito curto', () {
        final pet = petValido.copyWith(nome: 'A');
        expect(pet.isValid(), false);
      });

      test('deve invalidar pet com espécie vazia', () {
        final pet = petValido.copyWith(especie: '');
        expect(pet.isValid(), false);
      });

      test('deve invalidar pet com raça vazia', () {
        final pet = petValido.copyWith(raca: '');
        expect(pet.isValid(), false);
      });

      test('deve invalidar pet com peso zero', () {
        final pet = petValido.copyWith(peso: 0.0);
        expect(pet.isValid(), false);
      });

      test('deve invalidar pet com peso negativo', () {
        final pet = petValido.copyWith(peso: -5.0);
        expect(pet.isValid(), false);
      });

      test('deve validar pet sem peso (opcional)', () {
        final pet = petValido.copyWith(peso: null);
        expect(pet.isValid(), true);
      });
    });

    group('Cálculo de Idade', () {
      test('deve calcular idade em anos corretamente', () {
        // Pet nascido em 2022, estamos em 2023+ = aproximadamente 1-2 anos
        final idade = petValido.getIdadeEmAnos();
        expect(idade, greaterThanOrEqualTo(1));
        expect(idade, lessThanOrEqualTo(3));
      });

      test('deve calcular idade em meses corretamente', () {
        final idade = petValido.getIdadeEmMeses();
        expect(idade, greaterThanOrEqualTo(12));
      });

      test('deve retornar 0 para pet sem data de nascimento', () {
        final pet = petValido.copyWith(dataNascimento: null);
        expect(pet.getIdadeEmAnos(), 0);
        expect(pet.getIdadeEmMeses(), 0);
      });

      test('deve tratar pet nascido no futuro', () {
        final futuro = DateTime.now().add(Duration(days: 30));
        final pet = petValido.copyWith(dataNascimento: futuro);
        expect(pet.getIdadeEmAnos(), 0);
        expect(pet.getIdadeEmMeses(), 0);
      });

      test('deve calcular idade para pet recém-nascido', () {
        final hoje = DateTime.now();
        final pet = petValido.copyWith(dataNascimento: hoje);
        expect(pet.getIdadeEmAnos(), 0);
        expect(pet.getIdadeEmMeses(), 0);
      });
    });

    group('Formatação de Idade', () {
      test('deve formatar idade de filhote em meses', () {
        final filhote = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 90)),
        );
        final idade = filhote.getIdadeFormatada();
        expect(idade, contains('meses'));
      });

      test('deve formatar idade de recém-nascido', () {
        final recem = petValido.copyWith(dataNascimento: DateTime.now());
        expect(recem.getIdadeFormatada(), 'Recém-nascido');
      });

      test('deve formatar idade de 1 mês', () {
        final umMes = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 30)),
        );
        expect(umMes.getIdadeFormatada(), '1 mês');
      });

      test('deve formatar idade de 1 ano', () {
        final umAno = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 365)),
        );
        final idade = umAno.getIdadeFormatada();
        expect(idade, anyOf(contains('1 ano'), contains('12 meses')));
      });

      test('deve formatar idade de múltiplos anos', () {
        final velho = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 365 * 5)),
        );
        final idade = velho.getIdadeFormatada();
        expect(idade, contains('anos'));
      });
    });

    group('Faixa Etária', () {
      test('deve classificar como filhote', () {
        final filhote = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 90)),
        );
        expect(filhote.getFaixaEtaria(), 'Filhote');
        expect(filhote.isFilhote(), true);
        expect(filhote.isIdoso(), false);
      });

      test('deve classificar como jovem', () {
        final jovem = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 270)),
        );
        expect(jovem.getFaixaEtaria(), 'Jovem');
      });

      test('deve classificar como adulto', () {
        final adulto = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 365 * 3)),
        );
        expect(adulto.getFaixaEtaria(), 'Adulto');
        expect(adulto.isFilhote(), false);
        expect(adulto.isIdoso(), false);
      });

      test('deve classificar como idoso', () {
        final idoso = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 365 * 8)),
        );
        expect(idoso.getFaixaEtaria(), 'Idoso');
        expect(idoso.isIdoso(), true);
        expect(idoso.isFilhote(), false);
      });
    });

    group('Classificação de Peso', () {
      test('deve classificar peso de gato corretamente', () {
        final gato = petValido.copyWith(
          especie: 'Gato',
          peso: 4.0,
        );
        expect(gato.getClassificacaoPeso(), 'Peso ideal');
      });

      test('deve classificar gato abaixo do peso', () {
        final gato = petValido.copyWith(
          especie: 'Gato',
          peso: 2.0,
        );
        expect(gato.getClassificacaoPeso(), 'Abaixo do peso');
      });

      test('deve classificar gato com sobrepeso', () {
        final gato = petValido.copyWith(
          especie: 'Gato',
          peso: 6.0,
        );
        expect(gato.getClassificacaoPeso(), 'Sobrepeso');
      });

      test('deve classificar gato obeso', () {
        final gato = petValido.copyWith(
          especie: 'Gato',
          peso: 8.0,
        );
        expect(gato.getClassificacaoPeso(), 'Obeso');
      });

      test('deve classificar porte de cão', () {
        // Cão pequeno
        final pequeno = petValido.copyWith(
          especie: 'Cão',
          peso: 3.0,
        );
        expect(pequeno.getClassificacaoPeso(), 'Pequeno porte');

        // Cão médio
        final medio = petValido.copyWith(
          especie: 'Cão',
          peso: 20.0,
        );
        expect(medio.getClassificacaoPeso(), 'Médio porte');

        // Cão grande
        final grande = petValido.copyWith(
          especie: 'Cão',
          peso: 35.0,
        );
        expect(grande.getClassificacaoPeso(), 'Grande porte');
      });

      test('deve retornar null para pet sem peso', () {
        final pet = petValido.copyWith(peso: null);
        expect(pet.getClassificacaoPeso(), null);
      });

      test('deve tratar espécie não reconhecida', () {
        final exotico = petValido.copyWith(
          especie: 'Iguana',
          peso: 2.5,
        );
        expect(exotico.getClassificacaoPeso(), 'Peso registrado: 2.5kg');
      });
    });

    group('Iniciais', () {
      test('deve gerar iniciais corretamente', () {
        expect(petValido.getIniciais(), 'R');
      });

      test('deve gerar iniciais para nome composto', () {
        final pet = petValido.copyWith(nome: 'Rex Junior');
        expect(pet.getIniciais(), 'RJ');
      });

      test('deve retornar P para nome vazio', () {
        final pet = petValido.copyWith(nome: '');
        expect(pet.getIniciais(), 'P');
      });

      test('deve tratar espaços extras', () {
        final pet = petValido.copyWith(nome: '  Rex  Max  ');
        expect(pet.getIniciais(), 'RM');
      });
    });

    group('Necessidade de Vacinação', () {
      test('filhote deve precisar de vacinação', () {
        final filhote = petValido.copyWith(
          dataNascimento: DateTime.now().subtract(Duration(days: 90)),
        );
        expect(filhote.precisaVacinacao(), true);
      });

      test('adulto deve precisar de vacinação (simplificado)', () {
        expect(petValido.precisaVacinacao(), true);
      });
    });

    group('Serialização JSON', () {
      test('deve converter para JSON corretamente', () {
        final json = petValido.toJson();

        expect(json['id'], 1);
        expect(json['nome'], 'Rex');
        expect(json['especie'], 'Cão');
        expect(json['raca'], 'Labrador');
        expect(json['cor'], 'Marrom');
        expect(json['peso'], 25.5);
        expect(json['usuarioId'], 1);
        expect(json['ativo'], true);
        expect(json['dataNascimento'], isNotNull);
      });

      test('deve criar instância a partir de JSON', () {
        final json = {
          'id': 2,
          'nome': 'Mimi',
          'especie': 'Gato',
          'raca': 'Siamês',
          'dataNascimento': '2022-01-15T00:00:00.000Z',
          'cor': 'Cinza',
          'peso': 4.2,
          'usuarioId': 1,
          'ativo': true,
        };

        final pet = Pet.fromJson(json);

        expect(pet.id, 2);
        expect(pet.nome, 'Mimi');
        expect(pet.especie, 'Gato');
        expect(pet.raca, 'Siamês');
        expect(pet.cor, 'Cinza');
        expect(pet.peso, 4.2);
        expect(pet.usuarioId, 1);
        expect(pet.ativo, true);
        expect(pet.dataNascimento, isNotNull);
      });

      test('deve tratar campos opcionais no JSON', () {
        final json = {
          'nome': 'Bolinha',
          'especie': 'Hamster',
          'raca': 'Sírio',
        };

        final pet = Pet.fromJson(json);

        expect(pet.id, null);
        expect(pet.nome, 'Bolinha');
        expect(pet.cor, null);
        expect(pet.peso, null);
        expect(pet.ativo, true); // valor padrão
      });
    });

    group('CopyWith', () {
      test('deve criar cópia com campos alterados', () {
        final copia = petValido.copyWith(
          nome: 'Max',
          peso: 30.0,
        );

        expect(copia.id, petValido.id);
        expect(copia.nome, 'Max');
        expect(copia.peso, 30.0);
        expect(copia.especie, petValido.especie);
        expect(copia.raca, petValido.raca);
      });
    });

    group('Igualdade e HashCode', () {
      test('deve ser igual a outro pet com mesmos dados', () {
        final outroPet = Pet(
          id: 1,
          nome: 'Rex',
          especie: 'Cão',
          raca: 'Labrador',
          dataNascimento: dataFixa,
          cor: 'Marrom',
          peso: 25.5,
          usuarioId: 1,
          ativo: true,
        );

        expect(petValido, equals(outroPet));
        expect(petValido.hashCode, outroPet.hashCode);
      });

      test('deve ser diferente de pet com dados diferentes', () {
        final outroPet = petValido.copyWith(nome: 'Max');
        expect(petValido, isNot(equals(outroPet)));
      });
    });

    group('ToString', () {
      test('deve retornar representação em string', () {
        final string = petValido.toString();

        expect(string, contains('Pet'));
        expect(string, contains('id: 1'));
        expect(string, contains('nome: Rex'));
        expect(string, contains('especie: Cão'));
        expect(string, contains('raca: Labrador'));
      });
    });
  });
}