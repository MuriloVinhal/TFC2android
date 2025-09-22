const request = require('supertest');
const app = require('../../src/app');

describe('Testes do Controller de Produto', () => {
  let authToken;

  beforeAll(async () => {
    // Setup: Create admin user and login
    const userData = {
      nome: 'Admin User',
      email: 'admin@test.com',
      senha: 'password123',
      telefone: '11999888777',
      endereco: 'Admin Address',
      tipo: 'admin'
    };

    await request(app)
      .post('/usuarios/register')
      .send(userData);

    const loginResponse = await request(app)
      .post('/usuarios/login')
      .send({
        email: userData.email,
        senha: userData.senha
      });

    authToken = loginResponse.body.token;
  });

  describe('GET /produtos', () => {
    test('deve listar todos os produtos', async () => {
      const response = await request(app)
        .get('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
    });

    test('deve filtrar produtos por tipo', async () => {
      const response = await request(app)
        .get('/produtos?tipo=1')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(Array.isArray(response.body)).toBe(true);
      // All products should have the specified type
      response.body.forEach(produto => {
        expect(produto.tipo).toBe(1);
      });
    });

    test('deve retornar 401 para requisição não autenticada', async () => {
      const response = await request(app)
        .get('/produtos')
        .expect(401);

      expect(response.body).toHaveProperty('message');
    });
  });

  describe('POST /produtos', () => {
    test('deve criar um novo produto com sucesso', async () => {
      const produtoData = {
        descricao: 'Shampoo Premium',
        observacao: 'Para pelos sensíveis',
        tipo: 1
      };

      const response = await request(app)
        .post('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(produtoData)
        .expect(201);

      expect(response.body).toHaveProperty('descricao', produtoData.descricao);
      expect(response.body).toHaveProperty('observacao', produtoData.observacao);
      expect(response.body).toHaveProperty('tipo', produtoData.tipo);
    });

    test('deve criar produto com upload de imagem', async () => {
      const response = await request(app)
        .post('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .field('descricao', 'Condicionador com Imagem')
        .field('observacao', 'Produto com foto')
        .field('tipo', '2')
        .attach('imagem', Buffer.from('fake-image-data'), 'produto.jpg')
        .expect(201);

      expect(response.body).toHaveProperty('descricao', 'Condicionador com Imagem');
      expect(response.body).toHaveProperty('imagem');
      expect(response.body.imagem).toContain('/uploads/produtos/');
    });

    test('deve retornar erro para campos obrigatórios ausentes', async () => {
      const incompleteData = {
        descricao: 'Produto Incompleto'
        // missing tipo
      };

      const response = await request(app)
        .post('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(incompleteData)
        .expect(500);

      expect(response.body).toHaveProperty('message', 'Erro ao criar produto');
    });

    test('deve tratar conversão de tipo inválida', async () => {
      const produtoData = {
        descricao: 'Produto Teste',
        observacao: 'Teste tipo inválido',
        tipo: 'invalid-type'
      };

      const response = await request(app)
        .post('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(produtoData)
        .expect(500);

      expect(response.body).toHaveProperty('message', 'Erro ao criar produto');
    });
  });

  describe('PUT /produtos/:id', () => {
    let produtoId;

    beforeAll(async () => {
      // Create a product to update
      const produtoData = {
        descricao: 'Produto para Atualizar',
        observacao: 'Original',
        tipo: 1
      };

      const createResponse = await request(app)
        .post('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(produtoData);

      produtoId = createResponse.body.id;
    });

    test('deve atualizar produto com sucesso', async () => {
      const updateData = {
        descricao: 'Produto Atualizado',
        observacao: 'Observação atualizada',
        tipo: 2
      };

      const response = await request(app)
        .put(`/produtos/${produtoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(response.body).toHaveProperty('descricao', updateData.descricao);
      expect(response.body).toHaveProperty('observacao', updateData.observacao);
      expect(response.body).toHaveProperty('tipo', updateData.tipo);
    });

    test('deve atualizar produto com nova imagem', async () => {
      const response = await request(app)
        .put(`/produtos/${produtoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .field('descricao', 'Produto com Nova Imagem')
        .attach('imagem', Buffer.from('new-image-data'), 'novo-produto.jpg')
        .expect(200);

      expect(response.body).toHaveProperty('descricao', 'Produto com Nova Imagem');
      expect(response.body).toHaveProperty('imagem');
    });

    test('deve retornar erro para produto inexistente', async () => {
      const updateData = { descricao: 'Inexistente' };

      const response = await request(app)
        .put('/produtos/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(500);

      expect(response.body).toHaveProperty('message', 'Erro ao atualizar produto');
    });
  });

  describe('DELETE /produtos/:id', () => {
    let produtoId;

    beforeAll(async () => {
      // Create a product to delete
      const produtoData = {
        descricao: 'Produto para Deletar',
        observacao: 'Será deletado',
        tipo: 1
      };

      const createResponse = await request(app)
        .post('/produtos')
        .set('Authorization', `Bearer ${authToken}`)
        .send(produtoData);

      produtoId = createResponse.body.id;
    });

    test('deve deletar produto com sucesso', async () => {
      const response = await request(app)
        .delete(`/produtos/${produtoId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body).toHaveProperty('message');
    });

    test('deve retornar erro para produto inexistente (delete)', async () => {
      const response = await request(app)
        .delete('/produtos/99999')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(500);

      expect(response.body).toHaveProperty('message', 'Erro ao deletar produto');
    });
  });
});