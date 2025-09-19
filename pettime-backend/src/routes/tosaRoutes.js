const express = require('express');
const router = express.Router();
const tosaController = require('../controllers/tosaController');

router.get('/', tosaController.listarTosas);

module.exports = router; 