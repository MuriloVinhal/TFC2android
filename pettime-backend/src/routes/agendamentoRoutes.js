const express = require('express');
const {
  createAgendamento,
  getAgendamentos,
  approveAgendamento,
  deleteAgendamento,
  vincularProdutosServicosTeste
} = require('../controllers/agendamentoController.js');

const router = express.Router();

router.post('/', createAgendamento);
router.get('/', getAgendamentos);
router.put('/:id/approve', approveAgendamento);
router.delete('/:id', deleteAgendamento);
router.post('/vincular-teste', vincularProdutosServicosTeste);

module.exports = router;