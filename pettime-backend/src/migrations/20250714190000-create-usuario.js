'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('usuarios', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            nome: {
                type: Sequelize.STRING
            },
            email: {
                type: Sequelize.STRING,
                allowNull: false,
                unique: true
            },
            telefone: {
                type: Sequelize.STRING
            },
            endereco: {
                type: Sequelize.STRING
            },
            senha: {
                type: Sequelize.STRING,
                allowNull: false
            },
            tipo: {
                type: Sequelize.STRING,
                allowNull: false,
                defaultValue: 'cliente'
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
        await queryInterface.dropTable('usuarios');
    }
};
