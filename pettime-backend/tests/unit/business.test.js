// Testes unitários para lógica de negócio específica
const { calcularPrecoServico, validarAgendamento, calcularTempoServico } = require('../../src/utils/business');
const { formatarMoeda, capitalizarPalavras, removerAcentos } = require('../../src/utils/formatters');

describe('Regras de Negócio - Testes Unitários', () => {
  
  describe('Cálculo de Preço de Serviços', () => {
    test('deve calcular preço base corretamente', () => {
      const servico = {
        tipo: 'banho',
        precoBase: 50.00
      };
      
      const pet = {
        porte: 'pequeno',
        peso: 8
      };
      
      const preco = calcularPrecoServico(servico, pet);
      expect(preco).toBe(50.00);
    });

    test('deve aplicar acréscimo para porte grande', () => {
      const servico = {
        tipo: 'banho',
        precoBase: 50.00
      };
      
      const pet = {
        porte: 'grande',
        peso: 35
      };
      
      const preco = calcularPrecoServico(servico, pet);
      expect(preco).toBe(75.00); // 50% de acréscimo
    });

    test('deve aplicar desconto para múltiplos serviços', () => {
      const servicos = [
        { tipo: 'banho', precoBase: 50.00 },
        { tipo: 'tosa', precoBase: 40.00 },
        { tipo: 'unha', precoBase: 20.00 }
      ];
      
      const pet = { porte: 'medio', peso: 20 };
      
      const precoTotal = calcularPrecoServico(servicos, pet);
      expect(precoTotal).toBe(118.8); // (50*1.2 + 40*1.2 + 20*1.2) * 0.9
    });

    test('deve tratar casos extremos de peso', () => {
      const servico = { tipo: 'banho', precoBase: 50.00 };
      
      // Pet muito pequeno
      const petPequeno = { porte: 'pequeno', peso: 1 };
      expect(calcularPrecoServico(servico, petPequeno)).toBe(50.00);
      
      // Pet muito grande
      const petGigante = { porte: 'gigante', peso: 80 };
      expect(calcularPrecoServico(servico, petGigante)).toBe(130.00); // 100% acréscimo + 30% por peso
    });
  });

  describe('Validação de Agendamento', () => {
    test('deve validar agendamento em horário comercial', () => {
      const agendamento = {
        data: '2025-09-24',
        horario: '14:00',
        servicoId: 1,
        petId: 1
      };
      
      const resultado = validarAgendamento(agendamento);
      expect(resultado.valido).toBe(true);
      expect(resultado.erros).toHaveLength(0);
    });

    test('deve invalidar agendamento fora do horário comercial', () => {
      const agendamento = {
        data: '2025-09-24',
        horario: '07:00', // Antes das 8h
        servicoId: 1,
        petId: 1
      };
      
      const resultado = validarAgendamento(agendamento);
      expect(resultado.valido).toBe(false);
      expect(resultado.erros).toContain('Horário fora do funcionamento');
    });

    test('deve invalidar agendamento no domingo', () => {
      const agendamento = {
        data: '2025-09-21', // Domingo (21/09/2025 é domingo)
        horario: '14:00',
        servicoId: 1,
        petId: 1
      };
      
      const resultado = validarAgendamento(agendamento);
      expect(resultado.valido).toBe(false);
      expect(resultado.erros).toContain('Não funcionamos aos domingos');
    });

    test('deve invalidar agendamento em data passada', () => {
      const ontem = new Date();
      ontem.setDate(ontem.getDate() - 1);
      
      const agendamento = {
        data: ontem.toISOString().split('T')[0],
        horario: '14:00',
        servicoId: 1,
        petId: 1
      };
      
      const resultado = validarAgendamento(agendamento);
      expect(resultado.valido).toBe(false);
      expect(resultado.erros).toContain('Data não pode ser no passado');
    });
  });

  describe('Cálculo de Tempo de Serviço', () => {
    test('deve calcular tempo base para banho', () => {
      const servico = { tipo: 'banho' };
      const pet = { porte: 'medio' };
      
      const tempo = calcularTempoServico(servico, pet);
      expect(tempo).toBe(60); // 60 minutos
    });

    test('deve ajustar tempo por porte do pet', () => {
      const servico = { tipo: 'tosa' };
      
      const petPequeno = { porte: 'pequeno' };
      const petGrande = { porte: 'grande' };
      
      expect(calcularTempoServico(servico, petPequeno)).toBe(72); // 90 * 0.8
      expect(calcularTempoServico(servico, petGrande)).toBe(117); // 90 * 1.3
    });

    test('deve somar tempos para múltiplos serviços', () => {
      const servicos = [
        { tipo: 'banho' },
        { tipo: 'tosa' },
        { tipo: 'unha' }
      ];
      const pet = { porte: 'medio' };
      
      const tempoTotal = calcularTempoServico(servicos, pet);
      expect(tempoTotal).toBe(165); // 60 + 90 + 15 minutos
    });
  });
});

describe('Formatadores Avançados - Testes Unitários', () => {
  
  describe('Formatação de Moeda', () => {
    test('deve formatar valores monetários corretamente', () => {
      expect(formatarMoeda(50.99)).toContain('50,99');
      expect(formatarMoeda(1250)).toContain('1.250,00');
      expect(formatarMoeda(0)).toContain('0,00');
    });

    test('deve tratar valores inválidos', () => {
      expect(formatarMoeda('abc')).toBe('R$ 0,00');
      expect(formatarMoeda(null)).toBe('R$ 0,00');
      expect(formatarMoeda(undefined)).toBe('R$ 0,00');
    });

    test('deve formatar valores decimais complexos', () => {
      expect(formatarMoeda(99.999)).toContain('100,00');
      expect(formatarMoeda(50.555)).toContain('50,56');
    });
  });

  describe('Capitalização de Palavras', () => {
    test('deve capitalizar nomes corretamente', () => {
      expect(capitalizarPalavras('joão silva')).toBe('João Silva');
      expect(capitalizarPalavras('MARIA DOS SANTOS')).toBe('Maria Dos Santos');
      expect(capitalizarPalavras('ana-clara')).toBe('Ana-Clara');
    });

    test('deve tratar casos especiais', () => {
      expect(capitalizarPalavras('')).toBe('');
      expect(capitalizarPalavras('a')).toBe('A');
      expect(capitalizarPalavras('josé da silva')).toBe('José Da Silva');
    });

    test('deve preservar acentos', () => {
      expect(capitalizarPalavras('joão josé')).toBe('João José');
      expect(capitalizarPalavras('andré luís')).toBe('André Luís');
    });
  });

  describe('Remoção de Acentos', () => {
    test('deve remover acentos corretamente', () => {
      expect(removerAcentos('João')).toBe('Joao');
      expect(removerAcentos('São Paulo')).toBe('Sao Paulo');
      expect(removerAcentos('coração')).toBe('coracao');
    });

    test('deve manter caracteres sem acentos', () => {
      expect(removerAcentos('Pedro Silva')).toBe('Pedro Silva');
      expect(removerAcentos('123 ABC')).toBe('123 ABC');
    });

    test('deve tratar strings vazias', () => {
      expect(removerAcentos('')).toBe('');
      expect(removerAcentos(null)).toBe(null);
      expect(removerAcentos(undefined)).toBe(undefined);
    });
  });
});