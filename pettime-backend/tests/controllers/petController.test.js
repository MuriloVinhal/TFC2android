const request = require('supertest');
const app = require('../../src/app');

describe('Pet Controller Tests', () => {
  let authToken;
  let userId;

  beforeAll(async () => {
    // Setup: Create a user and login to get auth token
    const userData = {
      nome: 'Pet Owner',
      email: 'petowner@test.com',
      senha: 'password123',
      telefone: '11999888777',
      endereco: 'Test Address'
    };

    const registerResponse = await request(app)
      .post('/usuarios/register')
      .send(userData);

    userId = registerResponse.body.id;

    const loginResponse = await request(app)
      .post('/usuarios/login')
      .send({
        email: userData.email,
        senha: userData.senha
      });

    authToken = loginResponse.body.token;
  });

  describe('POST /pets', () => {
    test('should create a new pet successfully', async () => {
      const petData = {
        nome: 'Rex',
        raca: 'Labrador',
        idade: 3,
        peso: 25.5,
        usuarioId: userId,
        observacoes: 'Pet muito dócil'
      };

      const response = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .send(petData)
        .expect(201);

      expect(response.body).toHaveProperty('message', 'Pet cadastrado com sucesso!');
      expect(response.body).toHaveProperty('pet');
      expect(response.body.pet).toHaveProperty('nome', petData.nome);
      expect(response.body.pet).toHaveProperty('raca', petData.raca);
    });

    test('should handle pet creation with image upload', async () => {
      const petData = {
        nome: 'Bella',
        raca: 'Golden Retriever',
        idade: 2,
        peso: 20.0,
        usuarioId: userId
      };

      const response = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .field('nome', petData.nome)
        .field('raca', petData.raca)
        .field('idade', petData.idade)
        .field('peso', petData.peso)
        .field('usuarioId', petData.usuarioId)
        .attach('foto', Buffer.from('fake-image-data'), 'pet.jpg')
        .expect(201);

      expect(response.body).toHaveProperty('message', 'Pet cadastrado com sucesso!');
      expect(response.body).toHaveProperty('foto');
      expect(response.body.foto).toContain('/uploads/pets/');
    });

    test('should return error for missing required fields', async () => {
      const incompleteData = {
        nome: 'Incomplete Pet'
        // missing required fields
      };

      const response = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .send(incompleteData)
        .expect(500);

      expect(response.body).toHaveProperty('message', 'Erro ao cadastrar pet');
    });
  });

  describe('GET /pets', () => {
    test('should get all pets for a user', async () => {
      const response = await request(app)
        .get(`/pets?usuarioId=${userId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    test('should get all pets when no userId provided', async () => {
      const response = await request(app)
        .get('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    test('should return 401 for unauthenticated request', async () => {
      const response = await request(app)
        .get('/pets')
        .expect(401);

      expect(response.body).toHaveProperty('message');
    });
  });

  describe('PUT /pets/:id', () => {
    let petId;

    beforeAll(async () => {
      // Create a pet to update
      const petData = {
        nome: 'UpdateTest',
        raca: 'Test Breed',
        idade: 1,
        peso: 10.0,
        usuarioId: userId
      };

      const createResponse = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .send(petData);

      petId = createResponse.body.pet.id;
    });

    test('should update pet successfully', async () => {
      const updateData = {
        nome: 'Updated Name',
        raca: 'Updated Breed',
        idade: 2,
        peso: 12.5
      };

      const response = await request(app)
        .put(`/pets/${petId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body).toHaveProperty('nome', updateData.nome);
      expect(response.body).toHaveProperty('raca', updateData.raca);
    });

    test('should update pet with new image', async () => {
      const response = await request(app)
        .put(`/pets/${petId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .field('nome', 'Updated with Image')
        .attach('foto', Buffer.from('new-image-data'), 'updated-pet.jpg')
        .expect(200);

      expect(response.body).toHaveProperty('nome', 'Updated with Image');
    });

    test('should return error for non-existent pet', async () => {
      const updateData = { nome: 'Non-existent' };

      const response = await request(app)
        .put('/pets/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(500);

      expect(response.body).toHaveProperty('message', 'Erro ao atualizar pet');
    });
  });

  describe('DELETE /pets/:id', () => {
    let petId;

    beforeAll(async () => {
      // Create a pet to delete
      const petData = {
        nome: 'DeleteTest',
        raca: 'Test Breed',
        idade: 1,
        peso: 10.0,
        usuarioId: userId
      };

      const createResponse = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${authToken}`)
        .send(petData);

      petId = createResponse.body.pet.id;
    });

    test('should delete pet successfully', async () => {
      const response = await request(app)
        .delete(`/pets/${petId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('message');
    });

    test('should return error for non-existent pet', async () => {
      const response = await request(app)
        .delete('/pets/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(500);

      expect(response.body).toHaveProperty('message', 'Erro ao deletar pet');
    });
  });
});