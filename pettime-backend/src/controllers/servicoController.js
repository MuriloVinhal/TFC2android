const db = require('../models');
const Servico = db.Servico;

const createServico = async (req, res) => {
    try {
        const { tipo } = req.body;
        const novoServico = await Servico.create({ tipo });
        res.status(201).json(novoServico);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao criar serviço', error });
    }
};
const getServicos = async (req, res) => {
    try {
        const servicos = await Servico.findAll();
        res.status(200).json(servicos);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao listar serviços', error });
    }
};
const updateServico = async (req, res) => {
    try {
        const { id } = req.params;
        const { tipo } = req.body;
        const [updated] = await Servico.update({ tipo }, { where: { id } });
        if (updated) {
            const updatedServico = await Servico.findOne({ where: { id } });
            res.status(200).json(updatedServico);
        } else {
            res.status(404).json({ message: 'Serviço não encontrado' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Erro ao atualizar serviço', error });
    }
};

const deleteServico = async (req, res) => {
    try {
        const { id } = req.params;
        const deleted = await Servico.destroy({ where: { id } });
        if (deleted) {
            res.status(204).send();
        } else {
            res.status(404).json({ message: 'Serviço não encontrado' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Erro ao deletar serviço', error });
    }
};

module.exports = {
  createServico,
  getServicos,
  updateServico,
  deleteServico
};