'use strict';
module.exports = (sequelize, DataTypes) => {
  const Servico = sequelize.define('Servico', {
    tipo: {
      type: DataTypes.STRING,
      allowNull: false,
    }
  }, {
    tableName: 'servicos',
    timestamps: true,
  });

  Servico.associate = function (models) {
    Servico.hasMany(models.Agendamento, {
      foreignKey: 'servicoId',
      as: 'agendamentos'
    });
  };

  return Servico;
};