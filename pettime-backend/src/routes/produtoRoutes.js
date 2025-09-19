const express = require('express');
const produtoController = require('../controllers/produtoController');
const multer = require('multer');
const path = require('path');

const router = express.Router();

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const dir = path.join(__dirname, '../../uploads/produtos');
        const fs = require('fs');
        try {
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
        } catch (e) {
            console.error('Erro ao criar diretório de upload:', e);
        }
        cb(null, dir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage });

// Listar produtos (pode filtrar por tipo)
router.get('/', produtoController.listar);
// Criar produto
router.post('/', upload.single('imagem'), produtoController.criar);
// Atualizar produto
router.put('/:id', upload.single('imagem'), produtoController.atualizar);
// Deletar produto
router.delete('/:id', produtoController.deletar);

module.exports = router; 