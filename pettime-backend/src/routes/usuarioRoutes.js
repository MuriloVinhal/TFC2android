const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const authMiddleware = require('../middlewares/authMiddleware');
const db = require('../models');
const Usuario = db.Usuario;

router.post('/login', usuarioController.login);

router.post('/register', usuarioController.register);
// Recuperação de senha
router.post('/recuperar-senha', usuarioController.recuperarSenha);

router.get('/me', authMiddleware, async (req, res) => {
    try {
        console.log('ID do usuário extraído do token:', req.userId);
        console.log('Model Usuario:', Usuario); // Adicione este log
        const usuario = await Usuario.findByPk(req.userId);
        console.log('Usuário encontrado:', usuario);
    if (!usuario) return res.status(404).json({ erro: 'Usuário não encontrado', message: 'Usuário não encontrado' });
        res.json({
            nome: usuario.nome,
            email: usuario.email,
            telefone: usuario.telefone,
            endereco: usuario.endereco
        });
    } catch (err) {
        console.error('Erro detalhado ao buscar usuário:', err); // Log detalhado
    res.status(500).json({ erro: 'Erro ao buscar usuário', message: 'Erro ao buscar usuário' });
    }
});

router.put('/me', authMiddleware, async (req, res) => {
    try {
        const usuario = await Usuario.findByPk(req.userId);
        if (!usuario) return res.status(404).json({ erro: 'Usuário não encontrado', message: 'Usuário não encontrado' });

        const { nome, email, telefone, endereco, senha } = req.body;
        usuario.nome = nome ?? usuario.nome;
        usuario.email = email ?? usuario.email;
        usuario.telefone = telefone ?? usuario.telefone;
        usuario.endereco = endereco ?? usuario.endereco;
        
        if (senha) {
            // Validar critérios de senha quando ela está sendo alterada
            if (senha.length < 8) {
                return res.status(400).json({ 
                    erro: 'A senha deve ter no mínimo 8 caracteres.', 
                    message: 'A senha deve ter no mínimo 8 caracteres.' 
                });
            }

            if (!/[A-Z]/.test(senha)) {
                return res.status(400).json({ 
                    erro: 'A senha deve conter pelo menos uma letra maiúscula.', 
                    message: 'A senha deve conter pelo menos uma letra maiúscula.' 
                });
            }

            if (!/[a-z]/.test(senha)) {
                return res.status(400).json({ 
                    erro: 'A senha deve conter pelo menos uma letra minúscula.', 
                    message: 'A senha deve conter pelo menos uma letra minúscula.' 
                });
            }

            if (!/[0-9]/.test(senha)) {
                return res.status(400).json({ 
                    erro: 'A senha deve conter pelo menos um número.', 
                    message: 'A senha deve conter pelo menos um número.' 
                });
            }

            if (!/[!@#\$%\^&\*\(\)_\+\-=\[\]{};:'",.<>?]/.test(senha)) {
                return res.status(400).json({ 
                    erro: 'A senha deve conter pelo menos um símbolo especial.', 
                    message: 'A senha deve conter pelo menos um símbolo especial.' 
                });
            }

            const bcrypt = require('bcryptjs');
            usuario.senha = await bcrypt.hash(senha, 10);
        }
        await usuario.save();

        res.json({
            nome: usuario.nome,
            email: usuario.email,
            telefone: usuario.telefone,
            endereco: usuario.endereco,
            message: 'Perfil atualizado com sucesso!'
        });
    } catch (err) {
        console.error('Erro ao atualizar usuário:', err);
        res.status(500).json({ erro: 'Erro ao atualizar usuário', message: 'Erro ao atualizar usuário' });
    }
});

router.delete('/me', authMiddleware, usuarioController.deleteMe);

module.exports = router;
