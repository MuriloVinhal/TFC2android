import { Usuario } from '../models/Usuario';
import { gerarToken } from '../utils/jwt';
import { hashSenha, verificarSenha } from '../utils/password';

export const registrarUsuario = async (req, res) => {
    const { nome, email, senha } = req.body;

    try {
        const senhaHash = await hashSenha(senha);
        const novoUsuario = await Usuario.create({ nome, email, senha: senhaHash });

        res.status(201).json({ id: novoUsuario.id, nome: novoUsuario.nome, email: novoUsuario.email });
    } catch (error) {
        res.status(500).json({ mensagem: 'Erro ao registrar usuário', error: error.message });
    }
};

export const loginUsuario = async (req, res) => {
    const { email, senha } = req.body;

    try {
        const usuario = await Usuario.findOne({ where: { email } });

        if (!usuario || !(await verificarSenha(senha, usuario.senha))) {
            return res.status(401).json({ mensagem: 'Email ou senha inválidos' });
        }

        const token = gerarToken(usuario.id);
        res.json({ token });
    } catch (error) {
        res.status(500).json({ mensagem: 'Erro ao realizar login', error: error.message });
    }
};