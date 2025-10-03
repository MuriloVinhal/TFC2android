const Servico = require('../models/servico');

const servicoService = {
    async createServico(data) {
        try {
            const servico = await Servico.create(data);
            return servico;
        } catch (error) {
            throw new Error('Erro ao criar serviço: ' + error.message);
        }
    },

    async getAllServicos() {
        try {
            const servicos = await Servico.findAll();
            return servicos;
        } catch (error) {
            throw new Error('Erro ao listar serviços: ' + error.message);
        }
    },

    async getServicoById(id) {
        try {
            const servico = await Servico.findByPk(id);
            if (!servico) {
                throw new Error('Serviço não encontrado');
            }
            return servico;
        } catch (error) {
            throw new Error('Erro ao buscar serviço: ' + error.message);
        }
    },

    async updateServico(id, data) {
        try {
            const [updated] = await Servico.update(data, {
                where: { id }
            });
            if (!updated) {
                throw new Error('Serviço não encontrado');
            }
            return await this.getServicoById(id);
        } catch (error) {
            throw new Error('Erro ao atualizar serviço: ' + error.message);
        }
    },

    async deleteServico(id) {
        try {
            const deleted = await Servico.destroy({
                where: { id }
            });
            if (!deleted) {
                throw new Error('Serviço não encontrado');
            }
            return true;
        } catch (error) {
            throw new Error('Erro ao deletar serviço: ' + error.message);
        }
    }
};

module.exports = servicoService;