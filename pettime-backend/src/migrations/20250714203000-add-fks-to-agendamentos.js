'use strict';
module.exports = {
    async up(queryInterface, Sequelize) {
        await queryInterface.addColumn('agendamentos', 'servicoId', {
            type: Sequelize.INTEGER,
            references: { model: 'servicos', key: 'id' },
            onDelete: 'SET NULL'
        });

        await queryInterface.addColumn('agendamentos', 'servicoAdicionalId', {
            type: Sequelize.INTEGER,
            references: { model: 'servicos_adicionais', key: 'id' },
            onDelete: 'SET NULL'
        });

        await queryInterface.addColumn('agendamentos', 'tosaId', {
            type: Sequelize.INTEGER,
            references: { model: 'tosa', key: 'id' },
            onDelete: 'SET NULL'
        });
    },

    async down(queryInterface) {
        await queryInterface.removeColumn('agendamentos', 'servicoId');
        await queryInterface.removeColumn('agendamentos', 'servicoAdicionalId');
        await queryInterface.removeColumn('agendamentos', 'tosaId');
    }
};
