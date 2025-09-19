'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.removeColumn('servicos_adicionais', 'preco');
        await queryInterface.renameColumn('servicos_adicionais', 'nome', 'descricao');
    },
    async down(queryInterface, Sequelize) {
        await queryInterface.renameColumn('servicos_adicionais', 'descricao', 'nome');
        await queryInterface.addColumn('servicos_adicionais', 'preco', { type: Sequelize.DECIMAL(10, 2) });
    }
}; 