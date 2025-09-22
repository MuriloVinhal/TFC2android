const request = require('supertest');
const app = require('../../src/app');

describe('PetTime E2E Integration Tests', () => {
  let authToken;
  let userId;
  let petId;

  beforeAll(async () => {
    // Setup: Create a test user and authenticate
    const userData = {
      nome: 'E2E Test User',
      email: 'e2e@test.com',
      telefone: '11999888777',
      endereco: 'E2E Test Address',
      senha: 'password123'
    };

    // Register user
    const registerResponse = await request(app)
      .post('/usuarios/register')
      .send(userData);

    expect(registerResponse.status).toBe(200);

    // Login to get token
    const loginResponse = await request(app)
      .post('/usuarios/login')
      .send({
        email: userData.email,
        senha: userData.senha
      });

    expect(loginResponse.status).toBe(200);
    authToken = loginResponse.body.token;
    userId = loginResponse.body.usuario.id;
  });

  describe('Complete Pet Management Flow', () => {
    test('should create, read, update, and delete a pet', async () => {
      // CREATE PET
      const petData = {
        nome: 'Rex E2E',
        raca: 'Labrador',
        idade: 3,
        peso: 25.5,
        usuarioId: userId,
        observacoes: 'Pet muito dócil para teste E2E'
      };

      const createResponse = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .send(petData)
        .expect(201);

      expect(createResponse.body).toHaveProperty('message', 'Pet cadastrado com sucesso!');
      expect(createResponse.body.pet).toHaveProperty('nome', petData.nome);
      petId = createResponse.body.pet.id;

      // READ PET
      const readResponse = await request(app)
        .get(`/pets?usuarioId=${userId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(readResponse.body)).toBe(true);
      const createdPet = readResponse.body.find(pet => pet.id === petId);
      expect(createdPet).toBeDefined();
      expect(createdPet.nome).toBe(petData.nome);

      // UPDATE PET
      const updateData = {
        nome: 'Rex Updated E2E',
        peso: 30.0,
        observacoes: 'Observações atualizadas'
      };

      const updateResponse = await request(app)
        .put(`/pets/${petId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(updateResponse.body).toHaveProperty('nome', updateData.nome);
      expect(updateResponse.body).toHaveProperty('peso', updateData.peso);

      // DELETE PET
      const deleteResponse = await request(app)
        .delete(`/pets/${petId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(deleteResponse.body).toHaveProperty('message');

      // VERIFY DELETION
      const verifyResponse = await request(app)
        .get(`/pets?usuarioId=${userId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      const deletedPet = verifyResponse.body.find(pet => pet.id === petId);
      expect(deletedPet).toBeUndefined(); // Should not find deleted pet
    });
  });

  describe('Complete Agendamento Flow', () => {
    let servicoId;
    let agendamentoId;

    beforeAll(async () => {
      // Create a pet for agendamento
      const petData = {
        nome: 'Pet para Agendamento',
        raca: 'Golden',
        idade: 2,
        peso: 20.0,
        usuarioId: userId
      };

      const petResponse = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .send(petData);

      petId = petResponse.body.pet.id;

      // Create a service for agendamento
      const servicoData = {
        tipo: 'Banho Completo',
        descricao: 'Banho com shampoo especial',
        preco: 50.00
      };

      const servicoResponse = await request(app)
        .post('/servicos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(servicoData);

      if (servicoResponse.status === 201) {
        servicoId = servicoResponse.body.id;
      } else {
        servicoId = 1; // Use default if creation fails
      }
    });

    test('should create and manage agendamento', async () => {
      // CREATE AGENDAMENTO
      const agendamentoData = {
        petId: petId,
        servicoId: servicoId,
        data: '2025-12-25',
        horario: '10:00',
        taxiDog: false,
        observacao: 'Agendamento de teste E2E'
      };

      const createResponse = await request(app)
        .post('/agendamentos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(agendamentoData)
        .expect(201);

      expect(createResponse.body).toHaveProperty('id');
      expect(createResponse.body).toHaveProperty('data', agendamentoData.data);
      agendamentoId = createResponse.body.id;

      // READ AGENDAMENTOS
      const readResponse = await request(app)
        .get('/agendamentos')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(readResponse.body)).toBe(true);
      const createdAgendamento = readResponse.body.find(ag => ag.id === agendamentoId);
      expect(createdAgendamento).toBeDefined();

      // UPDATE AGENDAMENTO STATUS
      const updateResponse = await request(app)
        .put(`/agendamentos/${agendamentoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ status: 'confirmado' })
        .expect(200);

      expect(updateResponse.body).toHaveProperty('status', 'confirmado');
    });
  });

  describe('Product Management Flow', () => {
    test('should manage products (admin flow)', async () => {
      // CREATE PRODUCT
      const produtoData = {
        descricao: 'Shampoo E2E Test',
        observacao: 'Para testes de integração',
        tipo: 1
      };

      const createResponse = await request(app)
        .post('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(produtoData)
        .expect(201);

      expect(createResponse.body).toHaveProperty('descricao', produtoData.descricao);
      const produtoId = createResponse.body.id;

      // READ PRODUCTS
      const readResponse = await request(app)
        .get('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(readResponse.body)).toBe(true);
      const createdProduto = readResponse.body.find(p => p.id === produtoId);
      expect(createdProduto).toBeDefined();

      // UPDATE PRODUCT
      const updateData = {
        descricao: 'Shampoo E2E Updated',
        observacao: 'Observação atualizada'
      };

      const updateResponse = await request(app)
        .put(`/produtos/${produtoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(updateResponse.body).toHaveProperty('descricao', updateData.descricao);

      // DELETE PRODUCT
      await request(app)
        .delete(`/produtos/${produtoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
    });
  });

  describe('Authentication and Authorization Flow', () => {
    test('should handle authentication correctly', async () => {
      // Test unauthenticated request
      const unauthorizedResponse = await request(app)
        .get('/pets')
        .expect(401);

      expect(unauthorizedResponse.body).toHaveProperty('message');

      // Test with valid token
      const authorizedResponse = await request(app)
        .get('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(authorizedResponse.body)).toBe(true);

      // Test with invalid token
      const invalidTokenResponse = await request(app)
        .get('/pets')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);

      expect(invalidTokenResponse.body).toHaveProperty('message');
    });

    test('should handle user profile operations', async () => {
      // Get user profile
      const profileResponse = await request(app)
        .get('/usuarios/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(profileResponse.body).toHaveProperty('nome', 'E2E Test User');

      // Update user profile
      const updateData = {
        nome: 'E2E Updated User',
        telefone: '11888777666'
      };

      const updateResponse = await request(app)
        .put('/usuarios/profile')
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(updateResponse.body).toHaveProperty('nome', updateData.nome);
    });
  });

  describe('Error Handling and Edge Cases', () => {
    test('should handle invalid data gracefully', async () => {
      // Try to create pet with invalid data
      const invalidPetData = {
        nome: '', // Empty name
        idade: -1, // Negative age
        peso: 'invalid' // Non-numeric weight
      };

      const response = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .send(invalidPetData)
        .expect(500);

      expect(response.body).toHaveProperty('message');
    });

    test('should handle non-existent resource requests', async () => {
      // Try to get non-existent pet
      const response = await request(app)
        .get('/pets/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(404);

      expect(response.body).toHaveProperty('message');
    });

    test('should validate required fields', async () => {
      // Try to create agendamento without required fields
      const incompleteData = {
        observacao: 'Missing required fields'
      };

      const response = await request(app)
        .post('/agendamentos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(incompleteData)
        .expect(400);

      expect(response.body).toHaveProperty('message');
    });
  });
});