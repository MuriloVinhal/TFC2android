const express = require('express');
const router = express.Router();
const auth = require('../middlewares/authMiddleware');
const controller = require('../controllers/notificacaoController');

router.use(auth);

router.get('/', controller.listar);
router.get('/nao-lidas/contar', controller.contarNaoLidas);
router.put('/:id/marcar-lida', controller.marcarComoLida);
router.put('/marcar-todas-lidas', controller.marcarTodasComoLidas);

module.exports = router;


