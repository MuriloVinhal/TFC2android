'use strict';
module.exports = (sequelize, DataTypes) => {
    const Tosa = sequelize.define('Tosa', {
        tipo: DataTypes.STRING,
    }, {
        tableName: 'tosa'
    });

    Tosa.associate = function (models) {
        Tosa.hasMany(models.Agendamento, {
            foreignKey: 'tosaId',
            as: 'agendamentos'
        });
    };

    return Tosa;
};