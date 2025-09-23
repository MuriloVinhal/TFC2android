// Utilitários de autenticação e JWT
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'petime-secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '8h';

function gerarToken(payload) {
  if (!payload || typeof payload !== 'object') {
    throw new Error('Payload deve ser um objeto válido');
  }
  
  // Adiciona timestamp com nanossegundos para garantir unicidade
  const tokenPayload = {
    ...payload,
    iat: Math.floor(Date.now() / 1000),
    nonce: Date.now() + Math.random() // Garante unicidade
  };
  
  return jwt.sign(tokenPayload, JWT_SECRET, {
    expiresIn: JWT_EXPIRES_IN
  });
}

function validarToken(token) {
  if (!token || typeof token !== 'string') {
    throw new Error('Token deve ser uma string válida');
  }
  
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    throw new Error('Token inválido ou expirado');
  }
}

function extrairTokenDoHeader(authHeader) {
  if (!authHeader || typeof authHeader !== 'string') {
    return null;
  }
  
  const parts = authHeader.split(' ');
  
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return null;
  }
  
  return parts[1];
}

function decodificarTokenSemValidar(token) {
  if (!token || typeof token !== 'string') {
    return null;
  }
  
  try {
    return jwt.decode(token);
  } catch (error) {
    return null;
  }
}

function verificarExpiracaoToken(token) {
  const decoded = decodificarTokenSemValidar(token);
  
  if (!decoded || !decoded.exp) {
    return true; // Considera expirado se não conseguir decodificar
  }
  
  const agora = Math.floor(Date.now() / 1000);
  return decoded.exp < agora;
}

function gerarTokenRecuperacao(email) {
  if (!email || typeof email !== 'string') {
    throw new Error('Email deve ser uma string válida');
  }
  
  const payload = {
    email,
    tipo: 'recuperacao',
    timestamp: Date.now()
  };
  
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: '1h' // Token de recuperação expira em 1 hora
  });
}

function validarTokenRecuperacao(token) {
  const decoded = validarToken(token);
  
  if (!decoded || decoded.tipo !== 'recuperacao') {
    throw new Error('Token de recuperação inválido');
  }
  
  return decoded;
}

module.exports = {
  gerarToken,
  validarToken,
  extrairTokenDoHeader,
  decodificarTokenSemValidar,
  verificarExpiracaoToken,
  gerarTokenRecuperacao,
  validarTokenRecuperacao
};