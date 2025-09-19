'use strict';

module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.createTable('agendamento_servicos_adicionais', {
            id: {
                allowNull: false,
                autoIncrement: true,
                primaryKey: true,
                type: Sequelize.INTEGER
            },
            agendamento_id: {
                type: Sequelize.INTEGER,
                allowNull: false,
                references: {
                    model: 'agendamentos',
                    key: 'id'
                },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE'
            },
            servico_adicional_id: {
                type: Sequelize.INTEGER,
                allowNull: false,
                references: {
                    model: 'servicos_adicionais',
                    key: 'id'
                },
                onUpdate: 'CASCADE',
                onDelete: 'CASCADE'
            },
            createdAt: {
                allowNull: false,
                type: Sequelize.DATE
            },
            updatedAt: {
                allowNull: false,
                type: Sequelize.DATE
            }
        });
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('agendamento_servicos_adicionais');
    }
}; 