// Testes unitários para validações e lógica de negócio
const { validarEmail, validarTelefone, validarCPF } = require('../../src/utils/validators');
const { formatarTelefone, formatarCPF, calcularIdade } = require('../../src/utils/formatters');
const { gerarToken, validarToken } = require('../../src/utils/auth');

describe('Validadores - Testes Unitários', () => {
  
  describe('Validação de Email', () => {
    test('deve validar emails corretos', () => {
      const emailsValidos = [
        'usuario@email.com',
        'teste.email@dominio.com.br',
        'user+tag@example.org',
        'nome.sobrenome@empresa.co.uk'
      ];
      
      emailsValidos.forEach(email => {
        expect(validarEmail(email)).toBe(true);
      });
    });

    test('deve invalidar emails incorretos', () => {
      const emailsInvalidos = [
        'email-sem-arroba.com',
        '@dominio.com',
        'usuario@',
        'usuario@dominio',
        'usuario..duplo@email.com',
        'usuario@dominio..com',
        ''
      ];
      
      emailsInvalidos.forEach(email => {
        expect(validarEmail(email)).toBe(false);
      });
    });

    test('deve tratar casos especiais', () => {
      expect(validarEmail(null)).toBe(false);
      expect(validarEmail(undefined)).toBe(false);
      expect(validarEmail('   ')).toBe(false);
    });
  });

  describe('Validação de Telefone', () => {
    test('deve validar telefones brasileiros corretos', () => {
      const telefonesValidos = [
        '11987654321',      // Celular SP
        '2134567890',       // Fixo RJ
        '(11) 98765-4321',  // Celular formatado
        '(21) 3456-7890',   // Fixo formatado
        '85912345678',      // Celular CE
        '4733334444'        // Fixo SC
      ];
      
      telefonesValidos.forEach(telefone => {
        expect(validarTelefone(telefone)).toBe(true);
      });
    });

    test('deve invalidar telefones incorretos', () => {
      const telefonesInvalidos = [
        '123456789',         // Muito curto
        '123456789012',      // Muito longo
        '00987654321',       // DDD inválido (00)
        '0934567890',        // DDD inválido (09 não existe)
        'abcdefghijk',       // Não numérico
        '1198765432',        // Celular sem 9 no terceiro dígito
        ''
      ];
      
      telefonesInvalidos.forEach(telefone => {
        expect(validarTelefone(telefone)).toBe(false);
      });
    });
  });

  describe('Validação de CPF', () => {
    test('deve validar CPFs corretos', () => {
      const cpfsValidos = [
        '11144477735',       // CPF válido
        '111.444.777-35',    // CPF formatado
        '52998224725',       // Outro CPF válido
        '529.982.247-25'     // Formatado
      ];
      
      cpfsValidos.forEach(cpf => {
        expect(validarCPF(cpf)).toBe(true);
      });
    });

    test('deve invalidar CPFs incorretos', () => {
      const cpfsInvalidos = [
        '11111111111',       // Todos iguais
        '12345678901',       // Dígitos incorretos
        '111.444.777-00',    // Dígito verificador errado
        '123.456.789-10',    // Sequência inválida
        '12345678',          // Muito curto
        ''
      ];
      
      cpfsInvalidos.forEach(cpf => {
        expect(validarCPF(cpf)).toBe(false);
      });
    });
  });
});

describe('Formatadores - Testes Unitários', () => {
  
  describe('Formatação de Telefone', () => {
    test('deve formatar telefones celulares corretamente', () => {
      expect(formatarTelefone('11987654321')).toBe('(11) 98765-4321');
      expect(formatarTelefone('85912345678')).toBe('(85) 91234-5678');
    });

    test('deve formatar telefones fixos corretamente', () => {
      expect(formatarTelefone('1134567890')).toBe('(11) 3456-7890');
      expect(formatarTelefone('2133334444')).toBe('(21) 3333-4444');
    });

    test('deve tratar telefones já formatados', () => {
      expect(formatarTelefone('(11) 98765-4321')).toBe('(11) 98765-4321');
    });

    test('deve retornar original para números inválidos', () => {
      expect(formatarTelefone('123456789')).toBe('123456789');
      expect(formatarTelefone('')).toBe('');
    });
  });

  describe('Formatação de CPF', () => {
    test('deve formatar CPF corretamente', () => {
      expect(formatarCPF('11144477735')).toBe('111.444.777-35');
      expect(formatarCPF('52998224725')).toBe('529.982.247-25');
    });

    test('deve tratar CPF já formatado', () => {
      expect(formatarCPF('111.444.777-35')).toBe('111.444.777-35');
    });

    test('deve retornar original para números inválidos', () => {
      expect(formatarCPF('12345678')).toBe('12345678');
      expect(formatarCPF('')).toBe('');
    });
  });

  describe('Cálculo de Idade', () => {
    test('deve calcular idade corretamente', () => {
      const hoje = new Date();
      const nascimento1 = new Date(hoje.getFullYear() - 25, hoje.getMonth(), hoje.getDate());
      const nascimento2 = new Date(hoje.getFullYear() - 30, hoje.getMonth() - 6, hoje.getDate());
      
      expect(calcularIdade(nascimento1)).toBe(25);
      expect(calcularIdade(nascimento2)).toBe(30);
    });

    test('deve tratar aniversário não chegado', () => {
      const hoje = new Date();
      const nascimento = new Date(hoje.getFullYear() - 25, hoje.getMonth() + 1, hoje.getDate());
      
      expect(calcularIdade(nascimento)).toBe(24);
    });

    test('deve tratar datas futuras', () => {
      const futuro = new Date();
      futuro.setFullYear(futuro.getFullYear() + 1);
      
      expect(calcularIdade(futuro)).toBe(0);
    });
  });
});

describe('Autenticação - Testes Unitários', () => {
  
  describe('Geração de Token', () => {
    test('deve gerar token com payload correto', () => {
      const payload = { id: 1, email: 'test@email.com', tipo: 'cliente' };
      const token = gerarToken(payload);
      
      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.')).toHaveLength(3); // JWT tem 3 partes
    });

    test('deve gerar tokens únicos para payloads iguais', () => {
      const payload = { id: 1, email: 'test@email.com' };
      const token1 = gerarToken(payload);
      const token2 = gerarToken(payload);
      
      // Tokens devem ser diferentes devido ao timestamp iat
      expect(token1).not.toBe(token2);
    });
  });

  describe('Validação de Token', () => {
    test('deve validar token válido', () => {
      const payload = { id: 1, email: 'test@email.com', tipo: 'cliente' };
      const token = gerarToken(payload);
      
      const decoded = validarToken(token);
      
      expect(decoded).toBeDefined();
      expect(decoded.id).toBe(payload.id);
      expect(decoded.email).toBe(payload.email);
      expect(decoded.tipo).toBe(payload.tipo);
    });

    test('deve rejeitar token inválido', () => {
      const tokenInvalido = 'token.invalido.aqui';
      
      expect(() => validarToken(tokenInvalido)).toThrow();
    });

    test('deve rejeitar token vazio', () => {
      expect(() => validarToken('')).toThrow();
      expect(() => validarToken(null)).toThrow();
      expect(() => validarToken(undefined)).toThrow();
    });
  });
});