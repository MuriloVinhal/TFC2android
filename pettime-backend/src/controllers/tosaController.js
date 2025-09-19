const db = require('../models');
const Tosa = db.Tosa;

const listarTosas = async (req, res) => {
    try {
        const tosas = await Tosa.findAll();
        res.status(200).json(tosas);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao listar tosas', error: error.message });
    }
};

module.exports = { listarTosas }; 