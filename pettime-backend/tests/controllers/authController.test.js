const request = require('supertest');
const app = require('../../src/app');

describe('Testes do Controller de Autenticação', () => {
  describe('POST /usuarios/registrar', () => {
    test('deve registrar um novo usuário com sucesso', async () => {
      const userData = {
        nome: 'Test User',
        email: 'test@example.com',
        senha: 'password123'
      };

      const response = await request(app)
        .post('/usuarios/registrar')
        .send(userData)
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('nome', userData.nome);
      expect(response.body).toHaveProperty('email', userData.email);
      expect(response.body).not.toHaveProperty('senha');
    });

    test('deve retornar erro para email inválido', async () => {
      const userData = {
        nome: 'Test User',
        email: 'invalid-email',
        senha: 'password123'
      };

      const response = await request(app)
        .post('/usuarios/registrar')
        .send(userData)
        .expect(400);

      expect(response.body).toHaveProperty('mensagem');
    });

    test('deve retornar erro para campos obrigatórios ausentes', async () => {
      const userData = {
        nome: 'Test User'
        // missing email and senha
      };

      const response = await request(app)
        .post('/usuarios/registrar')
        .send(userData)
        .expect(400);

      expect(response.body).toHaveProperty('mensagem');
    });
  });

  describe('POST /usuarios/login', () => {
    test('deve fazer login do usuário com credenciais válidas', async () => {
      // First register a user
      const userData = {
        nome: 'Login Test User',
        email: 'login@example.com',
        senha: 'password123'
      };

      await request(app)
        .post('/usuarios/registrar')
        .send(userData);

      // Then try to login
      const loginData = {
        email: 'login@example.com',
        senha: 'password123'
      };

      const response = await request(app)
        .post('/usuarios/login')
        .send(loginData)
        .expect(200);

      expect(response.body).toHaveProperty('token');
    });

    test('deve retornar erro para credenciais inválidas', async () => {
      const loginData = {
        email: 'nonexistent@example.com',
        senha: 'wrongpassword'
      };

      const response = await request(app)
        .post('/usuarios/login')
        .send(loginData)
        .expect(401);

      expect(response.body).toHaveProperty('mensagem', 'Email ou senha inválidos');
    });

    test('deve retornar erro para credenciais ausentes', async () => {
      const loginData = {
        email: 'test@example.com'
        // missing senha
      };

      const response = await request(app)
        .post('/usuarios/login')
        .send(loginData)
        .expect(400);

      expect(response.body).toHaveProperty('mensagem');
    });
  });
});