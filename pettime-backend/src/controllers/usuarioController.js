const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { Usuario } = require('../models');

const JWT_SECRET = process.env.JWT_SECRET;

module.exports = {
    async register(req, res) {
        const { nome, email, telefone, endereco, senha, tipo } = req.body;

        try {
            const usuarioExistente = await Usuario.findOne({ where: { email } });
            if (usuarioExistente) {
                return res.status(400).json({ erro: 'E-mail já cadastrado.' });
            }

            const hash = await bcrypt.hash(senha, 10);

            await Usuario.create({
                nome,
                email,
                telefone,
                endereco,
                senha: hash,
                tipo: tipo || 'cliente'
            });

            return res.status(200).json({ mensagem: 'Usuário criado com sucesso!' });
        } catch (err) {
            return res.status(500).json({ erro: 'Erro ao criar usuário.' });
        }
    },

    async login(req, res) {
        const { email, senha } = req.body;

        try {
            const usuario = await Usuario.findOne({ where: { email } });
            if (!usuario) {
                return res.status(400).json({ erro: 'Usuário não encontrado.' });
            }
            if (usuario.deletado) {
                return res.status(403).json({ erro: 'Usuário excluído. Não é possível fazer login.' });
            }
            const senhaValida = await bcrypt.compare(senha, usuario.senha);
            if (!senhaValida) {
                return res.status(401).json({ erro: 'Senha inválida.' });
            }
            const token = jwt.sign({ id: usuario.id, tipo: usuario.tipo }, JWT_SECRET, { expiresIn: '8h' });
            return res.json({ token, usuario: { id: usuario.id, nome: usuario.nome, tipo: usuario.tipo } });
        } catch (err) {
            return res.status(500).json({ erro: 'Erro no login.' });
        }
    },

    async deleteMe(req, res) {
        try {
            const usuario = await Usuario.findByPk(req.userId);
            if (!usuario) {
                return res.status(404).json({ erro: 'Usuário não encontrado.' });
            }
            await usuario.update({ deletado: true });
            return res.status(200).json({ mensagem: 'Usuário excluído com sucesso!' });
        } catch (err) {
            return res.status(500).json({ erro: 'Erro ao excluir usuário.' });
        }
    },
};
