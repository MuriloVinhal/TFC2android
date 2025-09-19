'use strict';
module.exports = (sequelize, DataTypes) => {
  const Notificacao = sequelize.define('Notificacao', {
    usuarioId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    tipo: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    titulo: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    mensagem: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    lida: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
  }, {
    tableName: 'notificacoes'
  });

  Notificacao.associate = function(models) {
    Notificacao.belongsTo(models.Usuario, { foreignKey: 'usuarioId', as: 'usuario' });
  };

  return Notificacao;
};


