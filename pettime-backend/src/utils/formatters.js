// Formatadores de dados do sistema
function formatarTelefone(telefone) {
  if (!telefone || typeof telefone !== 'string') {
    return telefone;
  }
  
  // Remove caracteres não numéricos
  const numeroLimpo = telefone.replace(/\D/g, '');
  
  // Se já está formatado, retorna como está
  if (telefone.includes('(') && telefone.includes(')') && telefone.includes('-')) {
    return telefone;
  }
  
  // Formata celular (11 dígitos)
  if (numeroLimpo.length === 11) {
    return `(${numeroLimpo.substring(0, 2)}) ${numeroLimpo.substring(2, 7)}-${numeroLimpo.substring(7)}`;
  }
  
  // Formata fixo (10 dígitos)
  if (numeroLimpo.length === 10) {
    return `(${numeroLimpo.substring(0, 2)}) ${numeroLimpo.substring(2, 6)}-${numeroLimpo.substring(6)}`;
  }
  
  // Se não tem o tamanho esperado, retorna original
  return telefone;
}

function formatarCPF(cpf) {
  if (!cpf || typeof cpf !== 'string') {
    return cpf;
  }
  
  // Remove caracteres não numéricos
  const cpfLimpo = cpf.replace(/\D/g, '');
  
  // Se já está formatado, retorna como está
  if (cpf.includes('.') && cpf.includes('-')) {
    return cpf;
  }
  
  // Formata se tem 11 dígitos
  if (cpfLimpo.length === 11) {
    return `${cpfLimpo.substring(0, 3)}.${cpfLimpo.substring(3, 6)}.${cpfLimpo.substring(6, 9)}-${cpfLimpo.substring(9)}`;
  }
  
  // Se não tem o tamanho esperado, retorna original
  return cpf;
}

function formatarCEP(cep) {
  if (!cep || typeof cep !== 'string') {
    return cep;
  }
  
  // Remove caracteres não numéricos
  const cepLimpo = cep.replace(/\D/g, '');
  
  // Se já está formatado, retorna como está
  if (cep.includes('-')) {
    return cep;
  }
  
  // Formata se tem 8 dígitos
  if (cepLimpo.length === 8) {
    return `${cepLimpo.substring(0, 5)}-${cepLimpo.substring(5)}`;
  }
  
  // Se não tem o tamanho esperado, retorna original
  return cep;
}

function calcularIdade(dataNascimento) {
  if (!dataNascimento) {
    return 0;
  }
  
  const hoje = new Date();
  const nascimento = new Date(dataNascimento);
  
  // Se a data é no futuro, retorna 0
  if (nascimento > hoje) {
    return 0;
  }
  
  let idade = hoje.getFullYear() - nascimento.getFullYear();
  const mesAtual = hoje.getMonth();
  const mesNascimento = nascimento.getMonth();
  
  // Ajusta se o aniversário ainda não chegou este ano
  if (mesAtual < mesNascimento || 
      (mesAtual === mesNascimento && hoje.getDate() < nascimento.getDate())) {
    idade--;
  }
  
  return Math.max(0, idade);
}

function formatarDataBR(data) {
  if (!data) {
    return '';
  }
  
  const date = new Date(data);
  
  if (isNaN(date.getTime())) {
    return '';
  }
  
  const dia = date.getDate().toString().padStart(2, '0');
  const mes = (date.getMonth() + 1).toString().padStart(2, '0');
  const ano = date.getFullYear();
  
  return `${dia}/${mes}/${ano}`;
}

function formatarDataHoraBR(data) {
  if (!data) {
    return '';
  }
  
  const date = new Date(data);
  
  if (isNaN(date.getTime())) {
    return '';
  }
  
  const dataFormatada = formatarDataBR(data);
  const hora = date.getHours().toString().padStart(2, '0');
  const minuto = date.getMinutes().toString().padStart(2, '0');
  
  return `${dataFormatada} ${hora}:${minuto}`;
}

function formatarMoeda(valor) {
  if (typeof valor !== 'number') {
    return 'R$ 0,00';
  }
  
  return valor.toLocaleString('pt-BR', {
    style: 'currency',
    currency: 'BRL'
  });
}

function removerAcentos(texto) {
  if (!texto || typeof texto !== 'string') {
    return texto;
  }
  
  return texto
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

function capitalizarPalavras(texto) {
  if (!texto || typeof texto !== 'string') {
    return texto;
  }
  
  return texto
    .toLowerCase()
    .split(/(\s+|-)/) // Separa por espaços e hífens
    .map(parte => {
      if (parte.match(/\s+|-/)) {
        return parte; // Mantém espaços e hífens como estão
      }
      return parte.charAt(0).toUpperCase() + parte.slice(1);
    })
    .join('');
}

module.exports = {
  formatarTelefone,
  formatarCPF,
  formatarCEP,
  calcularIdade,
  formatarDataBR,
  formatarDataHoraBR,
  formatarMoeda,
  removerAcentos,
  capitalizarPalavras
};