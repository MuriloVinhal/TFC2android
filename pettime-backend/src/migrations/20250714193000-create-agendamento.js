'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.createTable('agendamentos', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            data: Sequelize.DATE,
            horario: Sequelize.STRING,
            status: {
                type: Sequelize.STRING,
                defaultValue: 'pendente'
            },
            taxiDog: Sequelize.BOOLEAN,
            observacao: Sequelize.STRING,
            petId: {
                type: Sequelize.INTEGER,
                references: { model: 'pets', key: 'id' },
                onDelete: 'CASCADE'
            },
            produtoId: {
                type: Sequelize.INTEGER,
                references: { model: 'produtos', key: 'id' },
                onDelete: 'SET NULL'
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
        await queryInterface.dropTable('agendamentos');
    }
};
