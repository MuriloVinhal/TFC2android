import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/data/models/usuario_model.dart';

void main() {
  group('Usuario Model - Testes Unitários', () {
    late Usuario usuarioValido;
    late DateTime dataFixa;

    setUp(() {
      dataFixa = DateTime(2023, 6, 15);
      usuarioValido = Usuario(
        id: 1,
        nome: 'João Silva',
        email: 'joao@email.com',
        telefone: '11987654321',
        endereco: 'Rua das Flores, 123',
        dataCriacao: dataFixa,
        ativo: true,
      );
    });

    group('Validações', () {
      test('deve validar usuário com dados corretos', () {
        expect(usuarioValido.isValid(), true);
      });

      test('deve invalidar usuário com nome vazio', () {
        final usuario = usuarioValido.copyWith(nome: '');
        expect(usuario.isValid(), false);
      });

      test('deve invalidar usuário com nome muito curto', () {
        final usuario = usuarioValido.copyWith(nome: 'A');
        expect(usuario.isValid(), false);
      });

      test('deve invalidar usuário com email inválido', () {
        final usuario = usuarioValido.copyWith(email: 'email-invalido');
        expect(usuario.isValid(), false);
      });

      test('deve invalidar usuário com telefone inválido', () {
        final usuario = usuarioValido.copyWith(telefone: '123');
        expect(usuario.isValid(), false);
      });
    });

    group('Validação de Email', () {
      test('deve validar email correto', () {
        expect(usuarioValido.isEmailValid(), true);
      });

      test('deve invalidar email sem @', () {
        final usuario = usuarioValido.copyWith(email: 'joaoemail.com');
        expect(usuario.isEmailValid(), false);
      });

      test('deve invalidar email sem domínio', () {
        final usuario = usuarioValido.copyWith(email: 'joao@');
        expect(usuario.isEmailValid(), false);
      });

      test('deve invalidar email sem extensão', () {
        final usuario = usuarioValido.copyWith(email: 'joao@email');
        expect(usuario.isEmailValid(), false);
      });

      test('deve validar email com subdomínio', () {
        final usuario = usuarioValido.copyWith(email: 'joao@mail.empresa.com.br');
        expect(usuario.isEmailValid(), true);
      });
    });

    group('Validação de Telefone', () {
      test('deve validar telefone celular (11 dígitos)', () {
        expect(usuarioValido.isTelefoneValid(), true);
      });

      test('deve validar telefone fixo (10 dígitos)', () {
        final usuario = usuarioValido.copyWith(telefone: '1133334444');
        expect(usuario.isTelefoneValid(), true);
      });

      test('deve invalidar telefone com poucos dígitos', () {
        final usuario = usuarioValido.copyWith(telefone: '119876');
        expect(usuario.isTelefoneValid(), false);
      });

      test('deve invalidar telefone com muitos dígitos', () {
        final usuario = usuarioValido.copyWith(telefone: '119876543210');
        expect(usuario.isTelefoneValid(), false);
      });

      test('deve validar telefone com formatação', () {
        final usuario = usuarioValido.copyWith(telefone: '(11) 98765-4321');
        expect(usuario.isTelefoneValid(), true);
      });
    });

    group('Formatação de Telefone', () {
      test('deve formatar telefone celular corretamente', () {
        expect(usuarioValido.getTelefoneFormatado(), '(11) 98765-4321');
      });

      test('deve formatar telefone fixo corretamente', () {
        final usuario = usuarioValido.copyWith(telefone: '1133334444');
        expect(usuario.getTelefoneFormatado(), '(11) 3333-4444');
      });

      test('deve retornar telefone original se inválido', () {
        final usuario = usuarioValido.copyWith(telefone: '123');
        expect(usuario.getTelefoneFormatado(), '123');
      });

      test('deve formatar telefone já formatado', () {
        final usuario = usuarioValido.copyWith(telefone: '(11) 98765-4321');
        expect(usuario.getTelefoneFormatado(), '(11) 98765-4321');
      });
    });

    group('Status do Usuário', () {
      test('deve identificar usuário novo (sem ID)', () {
        final usuario = usuarioValido.copyWith(id: null);
        expect(usuario.isNovo(), true);
      });

      test('deve identificar usuário existente (com ID)', () {
        expect(usuarioValido.isNovo(), false);
      });

      test('deve identificar usuário criado recentemente', () {
        final agora = DateTime.now();
        final usuario = usuarioValido.copyWith(dataCriacao: agora.subtract(Duration(hours: 12)));
        expect(usuario.isCriadoRecentemente(), true);
      });

      test('deve identificar usuário não criado recentemente', () {
        final usuario = usuarioValido.copyWith(dataCriacao: DateTime.now().subtract(Duration(days: 2)));
        expect(usuario.isCriadoRecentemente(), false);
      });

      test('deve retornar false para usuário sem data de criação', () {
        final usuario = usuarioValido.copyWith(dataCriacao: null);
        expect(usuario.isCriadoRecentemente(), false);
      });
    });

    group('Idade da Conta', () {
      test('deve calcular idade da conta em dias', () {
        final trintaDiasAtras = DateTime.now().subtract(Duration(days: 30));
        final usuario = usuarioValido.copyWith(dataCriacao: trintaDiasAtras);
        expect(usuario.getIdadeContaEmDias(), 30);
      });

      test('deve retornar 0 para usuário sem data de criação', () {
        final usuario = usuarioValido.copyWith(dataCriacao: null);
        expect(usuario.getIdadeContaEmDias(), 0);
      });

      test('deve calcular idade correta para usuário criado hoje', () {
        final usuario = usuarioValido.copyWith(dataCriacao: DateTime.now());
        expect(usuario.getIdadeContaEmDias(), 0);
      });
    });

    group('Iniciais', () {
      test('deve gerar iniciais corretamente para nome completo', () {
        expect(usuarioValido.getIniciais(), 'JS');
      });

      test('deve gerar inicial única para nome simples', () {
        final usuario = usuarioValido.copyWith(nome: 'João');
        expect(usuario.getIniciais(), 'J');
      });

      test('deve retornar U para nome vazio', () {
        final usuario = usuarioValido.copyWith(nome: '');
        expect(usuario.getIniciais(), 'U');
      });

      test('deve gerar iniciais para nome com múltiplas palavras', () {
        final usuario = usuarioValido.copyWith(nome: 'Ana Maria Santos Silva');
        expect(usuario.getIniciais(), 'AS');
      });

      test('deve tratar espaços extras', () {
        final usuario = usuarioValido.copyWith(nome: '  João   Silva  ');
        expect(usuario.getIniciais(), 'JS');
      });
    });

    group('Serialização JSON', () {
      test('deve converter para JSON corretamente', () {
        final json = usuarioValido.toJson();
        
        expect(json['id'], 1);
        expect(json['nome'], 'João Silva');
        expect(json['email'], 'joao@email.com');
        expect(json['telefone'], '11987654321');
        expect(json['endereco'], 'Rua das Flores, 123');
        expect(json['ativo'], true);
        expect(json['dataCriacao'], isNotNull);
      });

      test('deve criar instância a partir de JSON', () {
        final json = {
          'id': 2,
          'nome': 'Maria Santos',
          'email': 'maria@email.com',
          'telefone': '11987654322',
          'endereco': 'Av. Principal, 456',
          'ativo': true,
          'dataCriacao': '2023-06-15T10:00:00.000Z',
        };

        final usuario = Usuario.fromJson(json);

        expect(usuario.id, 2);
        expect(usuario.nome, 'Maria Santos');
        expect(usuario.email, 'maria@email.com');
        expect(usuario.telefone, '11987654322');
        expect(usuario.endereco, 'Av. Principal, 456');
        expect(usuario.ativo, true);
        expect(usuario.dataCriacao, isNotNull);
      });

      test('deve tratar campos opcionais no JSON', () {
        final json = {
          'nome': 'Pedro',
          'email': 'pedro@email.com',
          'telefone': '11987654323',
        };

        final usuario = Usuario.fromJson(json);

        expect(usuario.id, null);
        expect(usuario.nome, 'Pedro');
        expect(usuario.endereco, null);
        expect(usuario.ativo, true); // valor padrão
      });
    });

    group('CopyWith', () {
      test('deve criar cópia com campos alterados', () {
        final copia = usuarioValido.copyWith(
          nome: 'João Santos',
          email: 'joao.santos@email.com',
        );

        expect(copia.id, usuarioValido.id);
        expect(copia.nome, 'João Santos');
        expect(copia.email, 'joao.santos@email.com');
        expect(copia.telefone, usuarioValido.telefone);
        expect(copia.endereco, usuarioValido.endereco);
      });

      test('deve manter valores originais quando não especificado', () {
        final copia = usuarioValido.copyWith(nome: 'Novo Nome');

        expect(copia.email, usuarioValido.email);
        expect(copia.telefone, usuarioValido.telefone);
        expect(copia.endereco, usuarioValido.endereco);
        expect(copia.ativo, usuarioValido.ativo);
      });
    });

    group('Igualdade e HashCode', () {
      test('deve ser igual a outro usuário com mesmos dados', () {
        final outroUsuario = Usuario(
          id: 1,
          nome: 'João Silva',
          email: 'joao@email.com',
          telefone: '11987654321',
          endereco: 'Rua das Flores, 123',
          ativo: true,
        );

        expect(usuarioValido, equals(outroUsuario));
        expect(usuarioValido.hashCode, outroUsuario.hashCode);
      });

      test('deve ser diferente de usuário com dados diferentes', () {
        final outroUsuario = usuarioValido.copyWith(nome: 'Maria Silva');

        expect(usuarioValido, isNot(equals(outroUsuario)));
      });
    });

    group('ToString', () {
      test('deve retornar representação em string', () {
        final string = usuarioValido.toString();
        
        expect(string, contains('Usuario'));
        expect(string, contains('id: 1'));
        expect(string, contains('nome: João Silva'));
        expect(string, contains('email: joao@email.com'));
        expect(string, contains('telefone: 11987654321'));
        expect(string, contains('ativo: true'));
      });
    });
  });
}