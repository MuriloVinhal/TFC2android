const db = require('../models');
const Produto = db.Produto;

const produtoController = {
    // Listar produtos (pode filtrar por tipo)
    async listar(req, res) {
        try {
            const { tipo } = req.query;
            const where = tipo ? { tipo } : {};
            const produtos = await Produto.findAll({ where });
            res.status(200).json(produtos);
        } catch (error) {
            res.status(500).json({ message: 'Erro ao listar produtos', error: error.message });
        }
    },

    // Criar produto
    async criar(req, res) {
        try {
            const { descricao, observacao, tipo } = req.body;
            let imagem = null;
            if (req.file) {
                imagem = `/uploads/produtos/${req.file.filename}`;
            }
            // Garantir que tipo seja inteiro
            const tipoInt = parseInt(tipo, 10);
            console.log('Criando produto:', { descricao, observacao, tipo: tipoInt, imagem });
            const novoProduto = await Produto.create({ descricao, observacao, tipo: tipoInt, imagem });
            res.status(201).json(novoProduto);
        } catch (error) {
            console.error('Erro ao criar produto:', error);
            res.status(500).json({ message: 'Erro ao criar produto', error: error.message });
        }
    },

    // Atualizar produto
    async atualizar(req, res) {
        try {
            const { id } = req.params;
            const { descricao, observacao, tipo } = req.body;
            let imagem = undefined;
            if (req.file) {
                imagem = `/uploads/produtos/${req.file.filename}`;
            }
            const [updated] = await Produto.update(
                { descricao, observacao, tipo, ...(imagem && { imagem }) },
                { where: { id } }
            );
            if (updated) {
                const produtoAtualizado = await Produto.findByPk(id);
                res.status(200).json(produtoAtualizado);
            } else {
                res.status(404).json({ message: 'Produto não encontrado' });
            }
        } catch (error) {
            res.status(500).json({ message: 'Erro ao atualizar produto', error: error.message });
        }
    },

    // Deletar produto
    async deletar(req, res) {
        try {
            const { id } = req.params;
            const deleted = await Produto.destroy({ where: { id } });
            if (deleted) {
                res.status(204).send();
            } else {
                res.status(404).json({ message: 'Produto não encontrado' });
            }
        } catch (error) {
            res.status(500).json({ message: 'Erro ao deletar produto', error: error.message });
        }
    },
};

module.exports = produtoController; 