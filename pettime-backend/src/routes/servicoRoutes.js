const express = require('express');
const servicoController = require('../controllers/servicoController');

const router = express.Router();

// Rota para listar todos os serviços
router.get('/', servicoController.getServicos);

// Rota para criar um novo serviço
router.post('/', servicoController.createServico);

// Rota para atualizar um serviço existente
router.put('/:id', servicoController.updateServico);

// Rota para deletar um serviço
router.delete('/:id', servicoController.deleteServico);

module.exports = router;