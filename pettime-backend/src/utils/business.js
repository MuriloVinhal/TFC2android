// Lógica de negócio do sistema PetTime
function calcularPrecoServico(servico, pet) {
  let precoTotal = 0;
  
  // Se for array de serviços
  if (Array.isArray(servico)) {
    servico.forEach(s => {
      precoTotal += calcularPrecoIndividual(s, pet);
    });
    
    // Desconto para múltiplos serviços
    if (servico.length >= 3) {
      precoTotal *= 0.9; // 10% de desconto
    } else if (servico.length === 2) {
      precoTotal *= 0.95; // 5% de desconto
    }
  } else {
    precoTotal = calcularPrecoIndividual(servico, pet);
  }
  
  return Math.round(precoTotal * 100) / 100; // Arredonda para 2 casas decimais
}

function calcularPrecoIndividual(servico, pet) {
  let preco = servico.precoBase;
  
  // Ajuste por porte do pet
  switch (pet.porte) {
    case 'pequeno':
      // Sem acréscimo
      break;
    case 'medio':
      preco *= 1.2; // 20% acréscimo
      break;
    case 'grande':
      preco *= 1.5; // 50% acréscimo
      break;
    case 'gigante':
      preco *= 2.0; // 100% acréscimo
      break;
  }
  
  // Ajuste por peso extremo
  if (pet.peso > 50) {
    preco *= 1.3; // Acréscimo adicional para pets muito pesados
  }
  
  return preco;
}

function validarAgendamento(agendamento) {
  const erros = [];
  
  // Validar data
  const dataAgendamento = new Date(agendamento.data + 'T00:00:00');
  const hoje = new Date();
  hoje.setHours(0, 0, 0, 0);
  
  // Validar dia da semana primeiro (não funciona domingo)
  const diaSemana = dataAgendamento.getDay();
  if (diaSemana === 0) { // Domingo
    erros.push('Não funcionamos aos domingos');
  }
  
  // Só valida data passada se não for domingo
  if (dataAgendamento < hoje) {
    erros.push('Data não pode ser no passado');
  }
  
  // Validar horário comercial (8h às 18h)
  const [hora, minuto] = agendamento.horario.split(':').map(Number);
  const horarioMinutos = hora * 60 + minuto;
  
  if (horarioMinutos < 8 * 60 || horarioMinutos >= 18 * 60) {
    erros.push('Horário fora do funcionamento');
  }
  
  // Validar campos obrigatórios
  if (!agendamento.servicoId) {
    erros.push('Serviço é obrigatório');
  }
  
  if (!agendamento.petId) {
    erros.push('Pet é obrigatório');
  }
  
  return {
    valido: erros.length === 0,
    erros
  };
}

function calcularTempoServico(servico, pet) {
  let tempoTotal = 0;
  
  // Se for array de serviços
  if (Array.isArray(servico)) {
    servico.forEach(s => {
      tempoTotal += calcularTempoIndividual(s, pet);
    });
  } else {
    tempoTotal = calcularTempoIndividual(servico, pet);
  }
  
  return tempoTotal;
}

function calcularTempoIndividual(servico, pet) {
  let tempoBase = 0;
  
  // Tempo base por tipo de serviço (em minutos)
  switch (servico.tipo) {
    case 'banho':
      tempoBase = 60; // 1 hora
      break;
    case 'tosa':
      tempoBase = 90; // 1.5 horas
      break;
    case 'unha':
      tempoBase = 15; // 15 minutos
      break;
    case 'completo':
      tempoBase = 120; // 2 horas
      break;
    default:
      tempoBase = 60;
  }
  
  // Ajuste por porte
  switch (pet.porte) {
    case 'pequeno':
      tempoBase *= 0.8; // 20% menos tempo
      break;
    case 'medio':
      // Tempo padrão
      break;
    case 'grande':
      tempoBase *= 1.3; // 30% mais tempo
      break;
    case 'gigante':
      tempoBase *= 1.7; // 70% mais tempo
      break;
  }
  
  return Math.round(tempoBase);
}

function calcularProximoHorarioDisponivel(data, duracao) {
  const horarios = [];
  const inicio = 8 * 60; // 8:00 em minutos
  const fim = 18 * 60; // 18:00 em minutos
  const intervalo = 30; // Intervalos de 30 minutos
  
  for (let horario = inicio; horario + duracao <= fim; horario += intervalo) {
    const horas = Math.floor(horario / 60);
    const minutos = horario % 60;
    
    horarios.push(`${horas.toString().padStart(2, '0')}:${minutos.toString().padStart(2, '0')}`);
  }
  
  return horarios;
}

function validarCapacidadeDiaria(data, novoAgendamento) {
  // Simula validação de capacidade (em sistema real consultaria banco)
  const capacidadeMaxima = 20; // Agendamentos por dia
  const agendamentosExistentes = 5; // Simulação
  
  return agendamentosExistentes < capacidadeMaxima;
}

function calcularIdadeAnimal(dataNascimento) {
  if (!dataNascimento) {
    return { anos: 0, meses: 0 };
  }
  
  const hoje = new Date();
  const nascimento = new Date(dataNascimento);
  
  if (nascimento > hoje) {
    return { anos: 0, meses: 0 };
  }
  
  let anos = hoje.getFullYear() - nascimento.getFullYear();
  let meses = hoje.getMonth() - nascimento.getMonth();
  
  if (meses < 0) {
    anos--;
    meses += 12;
  }
  
  if (hoje.getDate() < nascimento.getDate()) {
    meses--;
    if (meses < 0) {
      anos--;
      meses += 12;
    }
  }
  
  return { anos: Math.max(0, anos), meses: Math.max(0, meses) };
}

module.exports = {
  calcularPrecoServico,
  validarAgendamento,
  calcularTempoServico,
  calcularProximoHorarioDisponivel,
  validarCapacidadeDiaria,
  calcularIdadeAnimal
};