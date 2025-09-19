'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.removeColumn('servicos', 'descricao');
        await queryInterface.removeColumn('servicos', 'preco');
        await queryInterface.renameColumn('servicos', 'nome', 'tipo');
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.renameColumn('servicos', 'tipo', 'nome');
        await queryInterface.addColumn('servicos', 'descricao', { type: Sequelize.STRING });
        await queryInterface.addColumn('servicos', 'preco', { type: Sequelize.DECIMAL(10, 2) });
    }
}; 