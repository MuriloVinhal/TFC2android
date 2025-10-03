module.exports = {
    up: async (queryInterface, Sequelize) => {
        // Inserir serviços básicos
        await queryInterface.bulkInsert('servicos', [
            {
                tipo: 'Banho',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                tipo: 'Banho e tosa',
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);

        // Inserir tosas básicas
        await queryInterface.bulkInsert('tosa', [
            {
                tipo: 'Tosa completa',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                tipo: 'Tosa bebê',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                tipo: 'Tosa higiênica',
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);

        // Inserir serviços adicionais básicos
        await queryInterface.bulkInsert('servicos_adicionais', [
            {
                descricao: 'Corte de unha',
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                descricao: 'Escovação',
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
    },

    down: async (queryInterface, Sequelize) => {
        // Remover dados inseridos
        await queryInterface.bulkDelete('servicos', { tipo: ['Banho', 'Banho e tosa'] }, {});
        await queryInterface.bulkDelete('tosa', { tipo: ['Tosa completa', 'Tosa bebê', 'Tosa higiênica'] }, {});
        await queryInterface.bulkDelete('servicos_adicionais', { descricao: ['Corte de unha', 'Escovação'] }, {});
    }
};