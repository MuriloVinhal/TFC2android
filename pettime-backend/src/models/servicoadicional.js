'use strict';
module.exports = (sequelize, DataTypes) => {
    const ServicoAdicional = sequelize.define('ServicoAdicional', {
        descricao: DataTypes.STRING
    }, {
        tableName: 'servicos_adicionais'
    });

    ServicoAdicional.associate = function (models) {
        this.belongsToMany(models.Agendamento, {
            through: 'agendamento_servicos_adicionais',
            foreignKey: 'servico_adicional_id',
            otherKey: 'agendamento_id',
            as: 'agendamentos'
        });
    };

    return ServicoAdicional;
};
