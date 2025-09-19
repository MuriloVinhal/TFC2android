const db = require('../models');
const ServicoAdicional = db.ServicoAdicional;

const listarServicosAdicionais = async (req, res) => {
    try {
        const servicos = await ServicoAdicional.findAll();
        res.status(200).json(servicos);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao listar serviços adicionais', error: error.message });
    }
};

module.exports = { listarServicosAdicionais }; 