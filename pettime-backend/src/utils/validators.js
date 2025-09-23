// Validadores de dados do sistema
function validarEmail(email) {
  if (!email || typeof email !== 'string') {
    return false;
  }
  
  const emailTrimmed = email.trim();
  if (emailTrimmed === '') {
    return false;
  }
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  // Verificações adicionais
  if (emailTrimmed.includes('..') || 
      emailTrimmed.startsWith('.') || 
      emailTrimmed.endsWith('.') ||
      emailTrimmed.startsWith('@') ||
      emailTrimmed.endsWith('@')) {
    return false;
  }
  
  return emailRegex.test(emailTrimmed);
}

function validarTelefone(telefone) {
  if (!telefone || typeof telefone !== 'string') {
    return false;
  }
  
  // Remove caracteres não numéricos
  const numeroLimpo = telefone.replace(/\D/g, '');
  
  // Verifica se tem 10 ou 11 dígitos
  if (numeroLimpo.length !== 10 && numeroLimpo.length !== 11) {
    return false;
  }
  
  // Verifica DDD (códigos de área válidos do Brasil)
  const ddd = parseInt(numeroLimpo.substring(0, 2));
  const dddsValidos = [
    11, 12, 13, 14, 15, 16, 17, 18, 19, // SP
    21, 22, 24, // RJ/ES
    27, 28, // ES
    31, 32, 33, 34, 35, 37, 38, // MG
    41, 42, 43, 44, 45, 46, // PR
    47, 48, 49, // SC
    51, 53, 54, 55, // RS
    61, // DF/GO
    62, 64, // GO/TO
    63, // TO
    65, 66, // MT
    67, // MS
    68, // AC
    69, // RO
    71, 73, 74, 75, 77, // BA
    79, // SE
    81, 87, // PE
    82, // AL
    83, // PB
    84, // RN
    85, 88, // CE
    86, 89, // PI
    91, 93, 94, // PA
    92, 97, // AM
    95, // RR
    96, // AP
    98, 99 // MA
  ];
  
  if (!dddsValidos.includes(ddd)) {
    return false;
  }
  
  // Para celular (11 dígitos), o terceiro dígito deve ser 9
  if (numeroLimpo.length === 11) {
    if (numeroLimpo[2] !== '9') {
      return false;
    }
  }
  
  // Para telefone fixo (10 dígitos), verificar se não começa com 9
  if (numeroLimpo.length === 10) {
    if (numeroLimpo[2] === '9') {
      return false;
    }
  }
  
  return true;
}

function validarCPF(cpf) {
  if (!cpf || typeof cpf !== 'string') {
    return false;
  }
  
  // Remove caracteres não numéricos
  const cpfLimpo = cpf.replace(/\D/g, '');
  
  // Verifica se tem 11 dígitos
  if (cpfLimpo.length !== 11) {
    return false;
  }
  
  // Verifica se todos os dígitos são iguais
  if (/^(\d)\1{10}$/.test(cpfLimpo)) {
    return false;
  }
  
  // Calcula o primeiro dígito verificador
  let soma = 0;
  for (let i = 0; i < 9; i++) {
    soma += parseInt(cpfLimpo[i]) * (10 - i);
  }
  let resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;
  if (resto !== parseInt(cpfLimpo[9])) return false;
  
  // Calcula o segundo dígito verificador
  soma = 0;
  for (let i = 0; i < 10; i++) {
    soma += parseInt(cpfLimpo[i]) * (11 - i);
  }
  resto = (soma * 10) % 11;
  if (resto === 10 || resto === 11) resto = 0;
  if (resto !== parseInt(cpfLimpo[10])) return false;
  
  return true;
}

function validarSenha(senha) {
  if (!senha || typeof senha !== 'string') {
    return false;
  }
  
  // Mínimo 8 caracteres
  if (senha.length < 8) {
    return false;
  }
  
  // Máximo 50 caracteres
  if (senha.length > 50) {
    return false;
  }
  
  // Deve conter pelo menos uma letra
  if (!/[a-zA-Z]/.test(senha)) {
    return false;
  }
  
  // Deve conter pelo menos um número
  if (!/[0-9]/.test(senha)) {
    return false;
  }
  
  return true;
}

function validarNome(nome) {
  if (!nome || typeof nome !== 'string') {
    return false;
  }
  
  const nomeTrimmed = nome.trim();
  
  // Mínimo 2 caracteres
  if (nomeTrimmed.length < 2) {
    return false;
  }
  
  // Máximo 100 caracteres
  if (nomeTrimmed.length > 100) {
    return false;
  }
  
  // Deve conter pelo menos um sobrenome
  if (!nomeTrimmed.includes(' ')) {
    return false;
  }
  
  // Só letras, espaços e hífens
  if (!/^[a-zA-ZÀ-ÿ\s\-]+$/.test(nomeTrimmed)) {
    return false;
  }
  
  return true;
}

module.exports = {
  validarEmail,
  validarTelefone,
  validarCPF,
  validarSenha,
  validarNome
};