import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/core/utils/validators.dart';

void main() {
  group('FormValidator - Testes Unitários', () {
    
    group('Validação de Campo Obrigatório', () {
      test('deve retornar null para campo válido', () {
        final resultado = FormValidator.validarCampoObrigatorio('João', 'Nome');
        expect(resultado, null);
      });

      test('deve retornar erro para campo null', () {
        final resultado = FormValidator.validarCampoObrigatorio(null, 'Nome');
        expect(resultado, 'Nome é obrigatório');
      });

      test('deve retornar erro para campo vazio', () {
        final resultado = FormValidator.validarCampoObrigatorio('', 'Email');
        expect(resultado, 'Email é obrigatório');
      });

      test('deve retornar erro para campo com apenas espaços', () {
        final resultado = FormValidator.validarCampoObrigatorio('   ', 'Telefone');
        expect(resultado, 'Telefone é obrigatório');
      });

      test('deve usar nome padrão quando não especificado', () {
        final resultado = FormValidator.validarCampoObrigatorio('');
        expect(resultado, 'Este campo é obrigatório');
      });
    });

    group('Validação de Email', () {
      test('deve validar email correto', () {
        final resultado = FormValidator.validarEmail('usuario@email.com');
        expect(resultado, null);
      });

      test('deve validar email com subdomínio', () {
        final resultado = FormValidator.validarEmail('user@mail.empresa.com.br');
        expect(resultado, null);
      });

      test('deve invalidar email null', () {
        final resultado = FormValidator.validarEmail(null);
        expect(resultado, 'Email é obrigatório');
      });

      test('deve invalidar email vazio', () {
        final resultado = FormValidator.validarEmail('');
        expect(resultado, 'Email é obrigatório');
      });

      test('deve invalidar email sem @', () {
        final resultado = FormValidator.validarEmail('usuarioemail.com');
        expect(resultado, 'Digite um email válido');
      });

      test('deve invalidar email sem domínio', () {
        final resultado = FormValidator.validarEmail('usuario@');
        expect(resultado, 'Digite um email válido');
      });

      test('deve invalidar email sem extensão', () {
        final resultado = FormValidator.validarEmail('usuario@email');
        expect(resultado, 'Digite um email válido');
      });

      test('deve invalidar email muito longo', () {
        final emailLongo = 'a' * 250 + '@email.com';
        final resultado = FormValidator.validarEmail(emailLongo);
        expect(resultado, 'Email muito longo');
      });

      test('deve invalidar email com caracteres especiais inválidos', () {
        final resultado = FormValidator.validarEmail('usuário@email.com');
        expect(resultado, 'Digite um email válido');
      });
    });

    group('Validação de Senha', () {
      test('deve validar senha forte', () {
        final resultado = FormValidator.validarSenha('senha123');
        expect(resultado, null);
      });

      test('deve invalidar senha null', () {
        final resultado = FormValidator.validarSenha(null);
        expect(resultado, 'Senha é obrigatória');
      });

      test('deve invalidar senha vazia', () {
        final resultado = FormValidator.validarSenha('');
        expect(resultado, 'Senha é obrigatória');
      });

      test('deve invalidar senha muito curta', () {
        final resultado = FormValidator.validarSenha('123');
        expect(resultado, 'Senha deve ter pelo menos 6 caracteres');
      });

      test('deve invalidar senha muito longa', () {
        final senhaLonga = 'a' * 51;
        final resultado = FormValidator.validarSenha(senhaLonga);
        expect(resultado, 'Senha muito longa (máximo 50 caracteres)');
      });

      test('deve invalidar senha sem letras', () {
        final resultado = FormValidator.validarSenha('123456');
        expect(resultado, 'Senha deve conter pelo menos uma letra');
      });

      test('deve invalidar senha sem números', () {
        final resultado = FormValidator.validarSenha('senhaaa');
        expect(resultado, 'Senha deve conter pelo menos um número');
      });

      test('deve validar senha com maiúsculas e minúsculas', () {
        final resultado = FormValidator.validarSenha('MinhaSenh4');
        expect(resultado, null);
      });

      test('deve validar senha com caracteres especiais', () {
        final resultado = FormValidator.validarSenha('senh@123');
        expect(resultado, null);
      });
    });

    group('Validação de Confirmação de Senha', () {
      test('deve validar confirmação correta', () {
        final resultado = FormValidator.validarConfirmacaoSenha('senha123', 'senha123');
        expect(resultado, null);
      });

      test('deve invalidar confirmação null', () {
        final resultado = FormValidator.validarConfirmacaoSenha('senha123', null);
        expect(resultado, 'Confirmação de senha é obrigatória');
      });

      test('deve invalidar confirmação vazia', () {
        final resultado = FormValidator.validarConfirmacaoSenha('senha123', '');
        expect(resultado, 'Confirmação de senha é obrigatória');
      });

      test('deve invalidar senhas diferentes', () {
        final resultado = FormValidator.validarConfirmacaoSenha('senha123', 'senha456');
        expect(resultado, 'Senhas não coincidem');
      });

      test('deve validar senhas idênticas com caracteres especiais', () {
        final resultado = FormValidator.validarConfirmacaoSenha('senh@123!', 'senh@123!');
        expect(resultado, null);
      });
    });

    group('Validação de Telefone', () {
      test('deve validar telefone celular', () {
        final resultado = FormValidator.validarTelefone('11987654321');
        expect(resultado, null);
      });

      test('deve validar telefone fixo', () {
        final resultado = FormValidator.validarTelefone('1133334444');
        expect(resultado, null);
      });

      test('deve validar telefone formatado', () {
        final resultado = FormValidator.validarTelefone('(11) 98765-4321');
        expect(resultado, null);
      });

      test('deve invalidar telefone null', () {
        final resultado = FormValidator.validarTelefone(null);
        expect(resultado, 'Telefone é obrigatório');
      });

      test('deve invalidar telefone vazio', () {
        final resultado = FormValidator.validarTelefone('');
        expect(resultado, 'Telefone é obrigatório');
      });

      test('deve invalidar telefone muito curto', () {
        final resultado = FormValidator.validarTelefone('119876');
        expect(resultado, 'Telefone deve ter 10 ou 11 dígitos');
      });

      test('deve invalidar telefone muito longo', () {
        final resultado = FormValidator.validarTelefone('119876543210');
        expect(resultado, 'Telefone deve ter 10 ou 11 dígitos');
      });

      test('deve invalidar código de área inválido', () {
        final resultado = FormValidator.validarTelefone('0987654321');
        expect(resultado, 'Código de área inválido');
      });

      test('deve invalidar celular sem 9', () {
        final resultado = FormValidator.validarTelefone('11887654321');
        expect(resultado, 'Número de celular inválido');
      });

      test('deve validar diferentes códigos de área', () {
        expect(FormValidator.validarTelefone('11987654321'), null);
        expect(FormValidator.validarTelefone('21987654321'), null);
        expect(FormValidator.validarTelefone('85987654321'), null);
      });
    });

    group('Validação de Nome', () {
      test('deve validar nome completo', () {
        final resultado = FormValidator.validarNome('João Silva');
        expect(resultado, null);
      });

      test('deve validar nome com acentos', () {
        final resultado = FormValidator.validarNome('José da Silva');
        expect(resultado, null);
      });

      test('deve invalidar nome null', () {
        final resultado = FormValidator.validarNome(null);
        expect(resultado, 'Nome é obrigatório');
      });

      test('deve invalidar nome vazio', () {
        final resultado = FormValidator.validarNome('');
        expect(resultado, 'Nome é obrigatório');
      });

      test('deve invalidar nome muito curto', () {
        final resultado = FormValidator.validarNome('A');
        expect(resultado, 'Nome deve ter pelo menos 2 caracteres');
      });

      test('deve invalidar nome muito longo', () {
        final nomeLongo = 'A' * 101;
        final resultado = FormValidator.validarNome(nomeLongo);
        expect(resultado, 'Nome muito longo (máximo 100 caracteres)');
      });

      test('deve invalidar nome com números', () {
        final resultado = FormValidator.validarNome('João123');
        expect(resultado, 'Nome contém caracteres inválidos');
      });

      test('deve invalidar nome sem sobrenome', () {
        final resultado = FormValidator.validarNome('João');
        expect(resultado, 'Digite nome e sobrenome');
      });

      test('deve tratar espaços extras', () {
        final resultado = FormValidator.validarNome('  João  Silva  ');
        expect(resultado, null);
      });

      test('deve validar nome com hífen', () {
        final resultado = FormValidator.validarNome('Ana-Maria Silva');
        expect(resultado, null);
      });
    });

    group('Validação de Data de Nascimento', () {
      test('deve validar data válida', () {
        final data = DateTime(1990, 5, 15);
        final resultado = FormValidator.validarDataNascimento(data);
        expect(resultado, null);
      });

      test('deve invalidar data null', () {
        final resultado = FormValidator.validarDataNascimento(null);
        expect(resultado, 'Data de nascimento é obrigatória');
      });

      test('deve invalidar data no futuro', () {
        final futuro = DateTime.now().add(Duration(days: 1));
        final resultado = FormValidator.validarDataNascimento(futuro);
        expect(resultado, 'Data não pode ser no futuro');
      });

      test('deve invalidar data muito antiga', () {
        final antiga = DateTime(1800, 1, 1);
        final resultado = FormValidator.validarDataNascimento(antiga);
        expect(resultado, 'Data muito antiga');
      });

      test('deve validar data de hoje', () {
        final hoje = DateTime.now();
        final resultado = FormValidator.validarDataNascimento(hoje);
        expect(resultado, null);
      });

      test('deve validar pessoa idosa', () {
        final data = DateTime(1950, 1, 1);
        final resultado = FormValidator.validarDataNascimento(data);
        expect(resultado, null);
      });
    });

    group('Validação de Peso', () {
      test('deve validar peso válido', () {
        final resultado = FormValidator.validarPeso('70.5');
        expect(resultado, null);
      });

      test('deve validar peso com vírgula', () {
        final resultado = FormValidator.validarPeso('75,3');
        expect(resultado, null);
      });

      test('deve permitir peso vazio (opcional)', () {
        final resultado = FormValidator.validarPeso('');
        expect(resultado, null);
      });

      test('deve permitir peso null (opcional)', () {
        final resultado = FormValidator.validarPeso(null);
        expect(resultado, null);
      });

      test('deve invalidar peso não numérico', () {
        final resultado = FormValidator.validarPeso('abc');
        expect(resultado, 'Digite um peso válido');
      });

      test('deve invalidar peso zero', () {
        final resultado = FormValidator.validarPeso('0');
        expect(resultado, 'Peso deve ser maior que zero');
      });

      test('deve invalidar peso negativo', () {
        final resultado = FormValidator.validarPeso('-10');
        expect(resultado, 'Peso deve ser maior que zero');
      });

      test('deve invalidar peso muito alto', () {
        final resultado = FormValidator.validarPeso('1001');
        expect(resultado, 'Peso muito alto (máximo 1000kg)');
      });

      test('deve validar peso máximo', () {
        final resultado = FormValidator.validarPeso('1000');
        expect(resultado, null);
      });
    });

    group('Validação de CPF', () {
      test('deve validar CPF válido', () {
        final resultado = FormValidator.validarCPF('11144477735');
        expect(resultado, null);
      });

      test('deve validar CPF formatado', () {
        final resultado = FormValidator.validarCPF('111.444.777-35');
        expect(resultado, null);
      });

      test('deve invalidar CPF null', () {
        final resultado = FormValidator.validarCPF(null);
        expect(resultado, 'CPF é obrigatório');
      });

      test('deve invalidar CPF vazio', () {
        final resultado = FormValidator.validarCPF('');
        expect(resultado, 'CPF é obrigatório');
      });

      test('deve invalidar CPF com poucos dígitos', () {
        final resultado = FormValidator.validarCPF('1234567');
        expect(resultado, 'CPF deve ter 11 dígitos');
      });

      test('deve invalidar CPF com muitos dígitos', () {
        final resultado = FormValidator.validarCPF('123456789012');
        expect(resultado, 'CPF deve ter 11 dígitos');
      });

      test('deve invalidar CPF com todos os dígitos iguais', () {
        final resultado = FormValidator.validarCPF('11111111111');
        expect(resultado, 'CPF inválido');
      });

      test('deve invalidar CPF com dígitos verificadores incorretos', () {
        final resultado = FormValidator.validarCPF('11144477736');
        expect(resultado, 'CPF inválido');
      });
    });

    group('Validação de CEP', () {
      test('deve validar CEP válido', () {
        final resultado = FormValidator.validarCEP('01234567');
        expect(resultado, null);
      });

      test('deve validar CEP formatado', () {
        final resultado = FormValidator.validarCEP('01234-567');
        expect(resultado, null);
      });

      test('deve permitir CEP vazio (opcional)', () {
        final resultado = FormValidator.validarCEP('');
        expect(resultado, null);
      });

      test('deve permitir CEP null (opcional)', () {
        final resultado = FormValidator.validarCEP(null);
        expect(resultado, null);
      });

      test('deve invalidar CEP com poucos dígitos', () {
        final resultado = FormValidator.validarCEP('1234567');
        expect(resultado, 'CEP deve ter 8 dígitos');
      });

      test('deve invalidar CEP com muitos dígitos', () {
        final resultado = FormValidator.validarCEP('123456789');
        expect(resultado, 'CEP deve ter 8 dígitos');
      });

      test('deve invalidar CEP com todos zeros', () {
        final resultado = FormValidator.validarCEP('00000000');
        expect(resultado, 'CEP inválido');
      });
    });

    group('Validação de Horário', () {
      test('deve validar horário válido', () {
        final resultado = FormValidator.validarHorario('14:30');
        expect(resultado, null);
      });

      test('deve validar horário com zero', () {
        final resultado = FormValidator.validarHorario('09:05');
        expect(resultado, null);
      });

      test('deve validar meia-noite', () {
        final resultado = FormValidator.validarHorario('00:00');
        expect(resultado, null);
      });

      test('deve validar fim do dia', () {
        final resultado = FormValidator.validarHorario('23:59');
        expect(resultado, null);
      });

      test('deve invalidar horário null', () {
        final resultado = FormValidator.validarHorario(null);
        expect(resultado, 'Horário é obrigatório');
      });

      test('deve invalidar horário vazio', () {
        final resultado = FormValidator.validarHorario('');
        expect(resultado, 'Horário é obrigatório');
      });

      test('deve invalidar hora inválida', () {
        final resultado = FormValidator.validarHorario('25:30');
        expect(resultado, 'Digite um horário válido (HH:mm)');
      });

      test('deve invalidar minuto inválido', () {
        final resultado = FormValidator.validarHorario('14:65');
        expect(resultado, 'Digite um horário válido (HH:mm)');
      });

      test('deve invalidar formato incorreto', () {
        final resultado = FormValidator.validarHorario('14-30');
        expect(resultado, 'Digite um horário válido (HH:mm)');
      });

      test('deve invalidar horário sem dois pontos', () {
        final resultado = FormValidator.validarHorario('1430');
        expect(resultado, 'Digite um horário válido (HH:mm)');
      });
    });
  });
}