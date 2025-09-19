'use strict';
module.exports = (sequelize, DataTypes) => {
  const Pet = sequelize.define('Pet', {
    nome: DataTypes.STRING,
    raca: DataTypes.STRING,
    idade: DataTypes.INTEGER,
    porte: DataTypes.STRING,
    foto: DataTypes.STRING,
    usuarioId: DataTypes.INTEGER,
    deletado: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    }
  }, {
    tableName: 'pets'
  });

  Pet.associate = function (models) {
    Pet.belongsTo(models.Usuario, { foreignKey: 'usuarioId', as: 'usuario' });
  };

  return Pet;
};
