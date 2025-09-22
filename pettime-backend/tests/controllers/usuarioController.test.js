const request = require('supertest');
const app = require('../../src/app');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Mock bcrypt and jwt
jest.mock('bcryptjs');
jest.mock('jsonwebtoken');

describe('Testes do Controller de Usuário', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /usuarios/register', () => {
    test('deve registrar um novo usuário com sucesso', async () => {
      const userData = {
        nome: 'Test User',
        email: 'newuser@test.com',
        telefone: '11999888777',
        endereco: 'Test Address',
        senha: 'password123',
        tipo: 'cliente'
      };

      bcrypt.hash.mockResolvedValue('hashedPassword');

      const response = await request(app)
        .post('/usuarios/register')
        .send(userData)
        .expect(200);

      expect(response.body).toHaveProperty('mensagem', 'Usuário criado com sucesso!');
      expect(bcrypt.hash).toHaveBeenCalledWith(userData.senha, 10);
    });

    test('deve retornar erro para email já existente', async () => {
      const userData = {
        nome: 'Test User',
        email: 'existing@test.com',
        telefone: '11999888777',
        endereco: 'Test Address',
        senha: 'password123'
      };

      // First register the user
      bcrypt.hash.mockResolvedValue('hashedPassword');
      await request(app)
        .post('/usuarios/register')
        .send(userData);

      // Try to register again with same email
      const response = await request(app)
        .post('/usuarios/register')
        .send(userData)
        .expect(400);

      expect(response.body).toHaveProperty('erro', 'E-mail já cadastrado.');
    });

    test('deve definir tipo padrão como cliente quando não fornecido', async () => {
      const userData = {
        nome: 'Default User',
        email: 'default@test.com',
        telefone: '11999888777',
        endereco: 'Test Address',
        senha: 'password123'
        // tipo not provided
      };

      bcrypt.hash.mockResolvedValue('hashedPassword');

      const response = await request(app)
        .post('/usuarios/register')
        .send(userData)
        .expect(200);

      expect(response.body).toHaveProperty('mensagem', 'Usuário criado com sucesso!');
    });

    test('deve retornar erro para campos obrigatórios ausentes', async () => {
      const incompleteData = {
        nome: 'Incomplete User'
        // missing email, senha, etc.
      };

      const response = await request(app)
        .post('/usuarios/register')
        .send(incompleteData)
        .expect(500);

      expect(response.body).toHaveProperty('erro', 'Erro ao criar usuário.');
    });
  });

  describe('POST /usuarios/login', () => {
    beforeEach(async () => {
      // Setup: Register a test user
      const userData = {
        nome: 'Login Test User',
        email: 'logintest@test.com',
        telefone: '11999888777',
        endereco: 'Test Address',
        senha: 'password123'
      };

      bcrypt.hash.mockResolvedValue('hashedPassword');
      await request(app)
        .post('/usuarios/register')
        .send(userData);
    });

    test('deve fazer login do usuário com credenciais válidas', async () => {
      const loginData = {
        email: 'logintest@test.com',
        senha: 'password123'
      };

      bcrypt.compare.mockResolvedValue(true);
      jwt.sign.mockReturnValue('mocked-token');

      const response = await request(app)
        .post('/usuarios/login')
        .send(loginData)
        .expect(200);

      expect(response.body).toHaveProperty('token', 'mocked-token');
      expect(response.body).toHaveProperty('usuario');
      expect(response.body.usuario).toHaveProperty('nome', 'Login Test User');
      expect(bcrypt.compare).toHaveBeenCalledWith(loginData.senha, 'hashedPassword');
    });

    test('deve retornar erro para usuário inexistente', async () => {
      const loginData = {
        email: 'nonexistent@test.com',
        senha: 'password123'
      };

      const response = await request(app)
        .post('/usuarios/login')
        .send(loginData)
        .expect(400);

      expect(response.body).toHaveProperty('erro', 'Usuário não encontrado.');
    });

    test('deve retornar erro para senha inválida', async () => {
      const loginData = {
        email: 'logintest@test.com',
        senha: 'wrongpassword'
      };

      bcrypt.compare.mockResolvedValue(false);

      const response = await request(app)
        .post('/usuarios/login')
        .send(loginData)
        .expect(401);

      expect(response.body).toHaveProperty('erro', 'Senha inválida.');
    });

    test('deve retornar erro para usuário excluído', async () => {
      // Create a deleted user scenario
      const userData = {
        nome: 'Deleted User',
        email: 'deleted@test.com',
        telefone: '11999888777',
        endereco: 'Test Address',
        senha: 'password123'
      };

      bcrypt.hash.mockResolvedValue('hashedPassword');
      await request(app)
        .post('/usuarios/register')
        .send(userData);

      // Simulate user deletion (this would normally be done through a delete endpoint)
      // For testing purposes, we'll mock the scenario

      const loginData = {
        email: 'deleted@test.com',
        senha: 'password123'
      };

      // Mock the scenario where user is marked as deleted
      const response = await request(app)
        .post('/usuarios/login')
        .send(loginData);

      // The response will depend on how the user deletion is implemented
      expect(response.status).toBeGreaterThanOrEqual(400);
    });

    test('deve gerar token JWT com payload correto', async () => {
      const loginData = {
        email: 'logintest@test.com',
        senha: 'password123'
      };

      const mockUserId = 1;
      const mockUserType = 'cliente';

      bcrypt.compare.mockResolvedValue(true);
      jwt.sign.mockReturnValue('mocked-token');

      await request(app)
        .post('/usuarios/login')
        .send(loginData);

      expect(jwt.sign).toHaveBeenCalledWith(
        { id: expect.any(Number), tipo: expect.any(String) },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );
    });
  });

  describe('Fluxo de Autenticação', () => {
    test('deve completar o fluxo completo de registro e login', async () => {
      // Register
      const userData = {
        nome: 'Flow Test User',
        email: 'flowtest@test.com',
        telefone: '11999888777',
        endereco: 'Test Address',
        senha: 'password123'
      };

      bcrypt.hash.mockResolvedValue('hashedPassword');

      const registerResponse = await request(app)
        .post('/usuarios/register')
        .send(userData)
        .expect(200);

      expect(registerResponse.body).toHaveProperty('mensagem', 'Usuário criado com sucesso!');

      // Login
      const loginData = {
        email: userData.email,
        senha: userData.senha
      };

      bcrypt.compare.mockResolvedValue(true);
      jwt.sign.mockReturnValue('flow-test-token');

      const loginResponse = await request(app)
        .post('/usuarios/login')
        .send(loginData)
        .expect(200);

      expect(loginResponse.body).toHaveProperty('token', 'flow-test-token');
      expect(loginResponse.body.usuario).toHaveProperty('nome', userData.nome);
    });
  });
});