const express = require('express');
const petController = require('../controllers/petController');
const multer = require('multer');
const path = require('path');

const router = express.Router();

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const fs = require('fs');
        const dir = path.join(__dirname, '../../uploads/pets');
        try {
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
        } catch (e) {
            console.error('Erro ao criar diretório de upload de pets:', e);
        }
        cb(null, dir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});
const upload = multer({ storage });

// Rota para criar um novo pet
router.post('/', upload.single('foto'), petController.createPet);

// Rota para listar todos os pets
router.get('/', petController.getAllPets);

router.put('/:id', upload.single('foto'), petController.updatePet);
router.delete('/:id', petController.deletePet);

module.exports = router;