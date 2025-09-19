import db from '../models/index.js';
const Agendamento = db.Agendamento;

export const createAgendamento = async (req, res) => {
    try {
        // Recebe todos os campos possíveis do frontend
        const {
            petId,
            servicoId,
            servicoAdicionalId, // legado, pode ser removido depois
            tosaId,
            data,
            horario,
            taxiDog,
            observacao,
            produtos = [], // array de IDs de produtos
            servicosAdicionais = [] // array de IDs de serviços adicionais
        } = req.body;
        const novoAgendamento = await Agendamento.create({
            petId,
            servicoId,
            servicoAdicionalId,
            tosaId,
            data,
            horario,
            taxiDog,
            observacao
        });
        console.log('produtos recebidos:', produtos);
        console.log('servicosAdicionais recebidos:', servicosAdicionais);
        console.log('setProdutos existe?', typeof novoAgendamento.setProdutos);
        console.log('setServicosAdicionais existe?', typeof novoAgendamento.setServicosAdicionais);
        // Vincular produtos
        if (produtos.length > 0 && novoAgendamento.setProdutos) {
            await novoAgendamento.setProdutos(produtos);
        }
        // Vincular serviços adicionais
        if (servicosAdicionais.length > 0 && novoAgendamento.setServicosAdicionais) {
            await novoAgendamento.setServicosAdicionais(servicosAdicionais);
        }
        // Buscar o agendamento já com os vínculos
        const agendamentoComVinculos = await Agendamento.findByPk(novoAgendamento.id, {
            include: [
                { model: db.Produto, as: 'produtos', attributes: ['id', 'descricao', 'tipo'] },
                { model: db.ServicoAdicional, as: 'servicosAdicionais', attributes: ['id', 'descricao'] },
                { model: db.Servico, as: 'servico', attributes: ['id', 'tipo'] },
                { model: db.Tosa, as: 'tosa', attributes: ['id', 'tipo'] },
            ]
        });
        return res.status(201).json(agendamentoComVinculos);
    } catch (error) {
        return res.status(500).json({ message: 'Erro ao criar agendamento', error });
    }
};

export const getAgendamentos = async (req, res) => {
    try {
        const { data, petId } = req.query;
        let where = {};
        if (data) {
            // Considera apenas a data (YYYY-MM-DD)
            const start = new Date(data);
            const end = new Date(data);
            end.setHours(23, 59, 59, 999);
            where.data = { $gte: start, $lte: end };
        }
        if (petId) {
            where.petId = petId;
        }
        const agendamentos = await Agendamento.findAll({
            where,
            include: [
                { model: db.Servico, as: 'servico', attributes: ['id', 'tipo'] },
                { model: db.Tosa, as: 'tosa', attributes: ['id', 'tipo'] },
                { model: db.Produto, as: 'produtos', attributes: ['id', 'descricao', 'tipo'] },
                { model: db.ServicoAdicional, as: 'servicosAdicionais', attributes: ['id', 'descricao'] },
            ]
        });
        return res.status(200).json(agendamentos);
    } catch (error) {
        return res.status(500).json({ message: 'Erro ao listar agendamentos', error });
    }
};

export const approveAgendamento = async (req, res) => {
    try {
        const { id } = req.params;
        const agendamento = await Agendamento.findByPk(id);

        if (!agendamento) {
            return res.status(404).json({ message: 'Agendamento não encontrado' });
        }

        agendamento.status = 'aprovado';
        await agendamento.save();

        return res.status(200).json(agendamento);
    } catch (error) {
        return res.status(500).json({ message: 'Erro ao aprovar agendamento', error });
    }
};

export const deleteAgendamento = async (req, res) => {
    try {
        const { id } = req.params;
        const agendamento = await Agendamento.findByPk(id);
        if (!agendamento) {
            return res.status(404).json({ message: 'Agendamento não encontrado' });
        }
        await agendamento.destroy();
        return res.status(204).send();
    } catch (error) {
        return res.status(500).json({ message: 'Erro ao deletar agendamento', error });
    }
};

export const vincularProdutosServicosTeste = async (req, res) => {
    try {
        const { agendamentoId, produtos, servicosAdicionais } = req.body;
        const agendamento = await db.Agendamento.findByPk(agendamentoId);
        if (!agendamento) return res.status(404).json({ message: 'Agendamento não encontrado' });

        if (produtos && produtos.length > 0) {
            await agendamento.setProdutos(produtos);
        }
        if (servicosAdicionais && servicosAdicionais.length > 0) {
            await agendamento.setServicosAdicionais(servicosAdicionais);
        }

        const agendamentoComVinculos = await db.Agendamento.findByPk(agendamentoId, {
            include: [
                { model: db.Produto, as: 'produtos', attributes: ['id', 'descricao'] },
                { model: db.ServicoAdicional, as: 'servicosAdicionais', attributes: ['id', 'descricao'] },
            ]
        });

        return res.status(200).json(agendamentoComVinculos);
    } catch (error) {
        return res.status(500).json({ message: 'Erro ao vincular', error });
    }
};