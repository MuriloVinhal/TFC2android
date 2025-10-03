const bcrypt = require('bcryptjs');
const { Usuario } = require('./src/models');

async function atualizarSenhaUsuario() {
    try {
        // Conecta ao banco
        const usuario = await Usuario.findOne({ where: { email: 'admin' } });
        
        if (!usuario) {
            console.log('Usuário não encontrado');
            return;
        }
        
        console.log('Usuário encontrado:', usuario.nome);
        console.log('Senha atual no banco:', usuario.senha);
        
        // Gera hash da senha "12345678"
        const senhaHash = await bcrypt.hash('12345678', 10);
        console.log('Novo hash gerado:', senhaHash);
        
        // Atualiza a senha
        await usuario.update({ senha: senhaHash });
        
        console.log('Senha atualizada com sucesso!');
        console.log('Agora você pode fazer login com:');
        console.log('Email: admin');
        console.log('Senha: 12345678');
        
        process.exit(0);
    } catch (error) {
        console.error('Erro ao atualizar senha:', error);
        process.exit(1);
    }
}

atualizarSenhaUsuario();