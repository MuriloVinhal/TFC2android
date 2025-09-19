'use strict';
module.exports = (sequelize, DataTypes) => {
  const Agendamento = sequelize.define('Agendamento', {
    petId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    servicoId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    tosaId: {
      type: DataTypes.INTEGER
    },
    data: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    horario: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    taxiDog: {
      type: DataTypes.BOOLEAN,
    },
    observacao: {
      type: DataTypes.STRING
    },
    status: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'pendente'
    }
  }, {
    tableName: 'agendamentos'
  });

  Agendamento.associate = function (models) {
    Agendamento.belongsTo(models.Pet, { foreignKey: 'petId', as: 'pet' });
    Agendamento.belongsTo(models.Servico, { foreignKey: 'servicoId', as: 'servico' });
    Agendamento.belongsTo(models.Tosa, { foreignKey: 'tosaId', as: 'tosa' });
    // Associação muitos-para-muitos com Produto
    Agendamento.belongsToMany(models.Produto, {
      through: 'agendamento_produtos',
      foreignKey: 'agendamento_id',
      otherKey: 'produto_id',
      as: 'produtos'
    });
    // Associação muitos-para-muitos com ServicoAdicional
    Agendamento.belongsToMany(models.ServicoAdicional, {
      through: 'agendamento_servicos_adicionais',
      foreignKey: 'agendamento_id',
      otherKey: 'servico_adicional_id',
      as: 'servicosAdicionais'
    });
  };

  return Agendamento;
};
