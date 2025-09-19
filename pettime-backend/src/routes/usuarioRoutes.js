const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const authMiddleware = require('../middlewares/authMiddleware');
const db = require('../models');
const Usuario = db.Usuario;

router.post('/login', usuarioController.login);

router.post('/register', usuarioController.register);

router.get('/me', authMiddleware, async (req, res) => {
    try {
        console.log('ID do usuário extraído do token:', req.userId);
        console.log('Model Usuario:', Usuario); // Adicione este log
        const usuario = await Usuario.findByPk(req.userId);
        console.log('Usuário encontrado:', usuario);
        if (!usuario) return res.status(404).json({ erro: 'Usuário não encontrado' });
        res.json({
            nome: usuario.nome,
            email: usuario.email,
            telefone: usuario.telefone,
            endereco: usuario.endereco
        });
    } catch (err) {
        console.error('Erro detalhado ao buscar usuário:', err); // Log detalhado
        res.status(500).json({ erro: 'Erro ao buscar usuário' });
    }
});

router.put('/me', authMiddleware, async (req, res) => {
    try {
        const usuario = await Usuario.findByPk(req.userId);
        if (!usuario) return res.status(404).json({ erro: 'Usuário não encontrado' });

        const { nome, email, telefone, endereco, senha } = req.body;
        usuario.nome = nome ?? usuario.nome;
        usuario.email = email ?? usuario.email;
        usuario.telefone = telefone ?? usuario.telefone;
        usuario.endereco = endereco ?? usuario.endereco;
        if (senha) {
            const bcrypt = require('bcryptjs');
            usuario.senha = await bcrypt.hash(senha, 10);
        }
        await usuario.save();

        res.json({
            nome: usuario.nome,
            email: usuario.email,
            telefone: usuario.telefone,
            endereco: usuario.endereco
        });
    } catch (err) {
        console.error('Erro ao atualizar usuário:', err);
        res.status(500).json({ erro: 'Erro ao atualizar usuário' });
    }
});

router.delete('/me', authMiddleware, usuarioController.deleteMe);

module.exports = router;
