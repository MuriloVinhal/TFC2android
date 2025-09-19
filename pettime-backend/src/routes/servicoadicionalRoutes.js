const express = require('express');
const router = express.Router();
const servicoAdicionalController = require('../controllers/servicoadicionalController');

router.get('/', servicoAdicionalController.listarServicosAdicionais);

module.exports = router; 