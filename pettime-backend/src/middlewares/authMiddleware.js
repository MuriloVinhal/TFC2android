const jwt = require('jsonwebtoken');
const { promisify } = require('util');
const db = require('../models');

const authMiddleware = async (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'Token não fornecido.' });
    }

    try {
        console.log('JWT_SECRET usado:', process.env.JWT_SECRET); // DEBUG
        const decoded = await promisify(jwt.verify)(token, process.env.JWT_SECRET);
        req.userId = decoded.id;
        // Verifica se o usuário está deletado
        const usuario = await db.Usuario.findByPk(decoded.id);
        if (!usuario || usuario.deletado) {
            return res.status(401).json({ message: 'Usuário não autorizado.' });
        }
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Token inválido.' });
    }
};

module.exports = authMiddleware;