'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('servicos', {
            id: { allowNull: false, autoIncrement: true, primaryKey: true, type: Sequelize.INTEGER },
            nome: { type: Sequelize.STRING, allowNull: false },
            descricao: { type: Sequelize.STRING },
            preco: { type: Sequelize.DECIMAL(10, 2) },
            createdAt: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') },
            updatedAt: { allowNull: false, type: Sequelize.DATE, defaultValue: Sequelize.fn('NOW') }
        });
    },
    async down(queryInterface) {
        await queryInterface.dropTable('servicos');
    }
};
