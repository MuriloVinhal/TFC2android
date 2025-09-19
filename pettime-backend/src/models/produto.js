'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Produto extends Model {
    static associate(models) {
      // Associação muitos-para-muitos com Agendamento
      this.belongsToMany(models.Agendamento, {
        through: 'agendamento_produtos',
        foreignKey: 'produto_id',
        otherKey: 'agendamento_id',
        as: 'agendamentos'
      });
    }
  }
  Produto.init({
    descricao: DataTypes.TEXT,
    observacao: DataTypes.TEXT,
    imagem: DataTypes.TEXT,
    tipo: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Produto',
    tableName: 'produtos', // Garantir nome correto da tabela
  });
  return Produto;
};