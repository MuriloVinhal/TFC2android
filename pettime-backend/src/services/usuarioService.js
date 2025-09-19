const db = require('../models');
const Usuario = db.Usuario;

export const criarUsuario = async (dadosUsuario) => {
    try {
        const usuario = await Usuario.create(dadosUsuario);
        return usuario;
    } catch (error) {
        throw new Error('Erro ao criar usuário: ' + error.message);
    }
};

export const listarUsuarios = async () => {
    try {
        const usuarios = await Usuario.findAll({ where: { deletado: false } });
        return usuarios;
    } catch (error) {
        throw new Error('Erro ao listar usuários: ' + error.message);
    }
};

export const atualizarUsuario = async (id, dadosAtualizados) => {
    try {
        const usuario = await Usuario.findByPk(id);
        if (!usuario) {
            throw new Error('Usuário não encontrado');
        }
        await usuario.update(dadosAtualizados);
        return usuario;
    } catch (error) {
        throw new Error('Erro ao atualizar usuário: ' + error.message);
    }
};

export const deletarUsuario = async (id) => {
    try {
        const usuario = await Usuario.findByPk(id);
        if (!usuario) {
            throw new Error('Usuário não encontrado');
        }
        await usuario.update({ deletado: true });
        return { message: 'Usuário excluído logicamente com sucesso' };
    } catch (error) {
        throw new Error('Erro ao deletar usuário: ' + error.message);
    }
};