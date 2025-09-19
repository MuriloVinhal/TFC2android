import { Agendamento } from '../models/Agendamento';

export const criarAgendamento = async (dadosAgendamento) => {
    try {
        const novoAgendamento = await Agendamento.create(dadosAgendamento);
        return novoAgendamento;
    } catch (error) {
        throw new Error('Erro ao criar agendamento: ' + error.message);
    }
};

export const listarAgendamentos = async () => {
    try {
        const agendamentos = await Agendamento.findAll();
        return agendamentos;
    } catch (error) {
        throw new Error('Erro ao listar agendamentos: ' + error.message);
    }
};

export const aprovarAgendamento = async (id) => {
    try {
        const agendamento = await Agendamento.findByPk(id);
        if (!agendamento) {
            throw new Error('Agendamento não encontrado');
        }
        agendamento.status = 'aprovado';
        await agendamento.save();
        return agendamento;
    } catch (error) {
        throw new Error('Erro ao aprovar agendamento: ' + error.message);
    }
};