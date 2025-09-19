'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('pets', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            nome: Sequelize.STRING,
            idade: Sequelize.INTEGER,
            porte: Sequelize.STRING,
            raca: Sequelize.STRING,
            foto: Sequelize.STRING,
            usuarioId: {
                type: Sequelize.INTEGER,
                allowNull: false,
                references: { model: 'usuarios', key: 'id' },
                onDelete: 'CASCADE'
            },
            createdAt: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.fn('NOW')
            },
            updatedAt: {
                allowNull: false,
                type: Sequelize.DATE,
                defaultValue: Sequelize.fn('NOW')
            }
        });
    },

    async down(queryInterface, Sequelize) {
        await queryInterface.dropTable('pets');
    }
};
