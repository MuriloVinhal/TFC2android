import express from 'express';
import servicoController from '../controllers/servicoController.js';

const router = express.Router();

// Rota para listar todos os serviços
router.get('/', servicoController.listarServicos);

// Rota para criar um novo serviço
router.post('/', servicoController.criarServico);

// Rota para atualizar um serviço existente
router.put('/:id', servicoController.atualizarServico);

// Rota para deletar um serviço
router.delete('/:id', servicoController.deletarServico);

export default router;