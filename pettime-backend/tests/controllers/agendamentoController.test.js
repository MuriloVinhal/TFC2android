const request = require('supertest');
const app = require('../../src/app');

describe('Agendamento Controller Tests', () => {
  let authToken;
  let petId;

  beforeAll(async () => {
    // Setup: Create a user and login to get auth token
    const userData = {
      nome: 'Test User',
      email: 'agendamento@test.com',
      senha: 'password123'
    };

    await request(app)
      .post('/usuarios/registrar')
      .send(userData);

    const loginResponse = await request(app)
      .post('/usuarios/login')
      .send({
        email: userData.email,
        senha: userData.senha
      });

    authToken = loginResponse.body.token;
  });

  describe('POST /agendamentos', () => {
    test('should create a new agendamento successfully', async () => {
      const agendamentoData = {
        petId: 1,
        servicoId: 1,
        data: '2025-12-25',
        horario: '10:00',
        taxiDog: false,
        observacao: 'Teste de agendamento'
      };

      const response = await request(app)
        .post('/agendamentos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(agendamentoData)
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('petId', agendamentoData.petId);
      expect(response.body).toHaveProperty('data', agendamentoData.data);
      expect(response.body).toHaveProperty('horario', agendamentoData.horario);
    });

    test('should return error for missing required fields', async () => {
      const incompleteData = {
        petId: 1
        // missing servicoId, data, horario
      };

      const response = await request(app)
        .post('/agendamentos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(incompleteData)
        .expect(400);

      expect(response.body).toHaveProperty('mensagem');
    });

    test('should handle produtos and servicosAdicionais arrays', async () => {
      const agendamentoData = {
        petId: 1,
        servicoId: 1,
        data: '2025-12-26',
        horario: '14:00',
        taxiDog: true,
        produtos: [1, 2],
        servicosAdicionais: [1]
      };

      const response = await request(app)
        .post('/agendamentos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(agendamentoData)
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('produtos');
      expect(response.body).toHaveProperty('servicosAdicionais');
    });
  });

  describe('GET /agendamentos', () => {
    test('should get all agendamentos for authenticated user', async () => {
      const response = await request(app)
        .get('/agendamentos')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    test('should return 401 for unauthenticated request', async () => {
      const response = await request(app)
        .get('/agendamentos')
        .expect(401);

      expect(response.body).toHaveProperty('mensagem');
    });
  });
});