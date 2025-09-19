const bcrypt = require('bcryptjs');

module.exports = {
    up: async (queryInterface, Sequelize) => {
        const senhaHash = await bcrypt.hash('admin123', 10); // senha padrão, altere depois
        return queryInterface.bulkInsert('usuarios', [
            {
                nome: 'Administrador',
                email: 'admin@pettime.com',
                telefone: '00000000000',
                endereco: 'Endereço Admin',
                senha: senhaHash,
                tipo: 'admin',
                deletado: false,
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
    },

    down: async (queryInterface, Sequelize) => {
        return queryInterface.bulkDelete('usuarios', { email: 'admin@pettime.com' }, {});
    }
}; 