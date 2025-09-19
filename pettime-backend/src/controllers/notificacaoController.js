const { Notificacao } = require('../models');

module.exports = {
  async listar(req, res) {
    try {
      const usuarioId = req.userId;
      const itens = await Notificacao.findAll({
        where: { usuarioId },
        order: [['createdAt', 'DESC']],
      });
      res.json(itens);
    } catch (e) {
      res.status(500).json({ error: 'Erro ao listar notificações' });
    }
  },

  async contarNaoLidas(req, res) {
    try {
      const usuarioId = req.userId;
      const count = await Notificacao.count({ where: { usuarioId, lida: false } });
      res.json({ count });
    } catch (e) {
      res.status(500).json({ error: 'Erro ao contar notificações' });
    }
  },

  async marcarComoLida(req, res) {
    try {
      const usuarioId = req.userId;
      const { id } = req.params;
      const notif = await Notificacao.findOne({ where: { id, usuarioId } });
      if (!notif) return res.status(404).json({ error: 'Notificação não encontrada' });
      notif.lida = true;
      await notif.save();
      res.json({ ok: true });
    } catch (e) {
      res.status(500).json({ error: 'Erro ao marcar notificação' });
    }
  },

  async marcarTodasComoLidas(req, res) {
    try {
      const usuarioId = req.userId;
      await Notificacao.update({ lida: true }, { where: { usuarioId, lida: false } });
      res.json({ ok: true });
    } catch (e) {
      res.status(500).json({ error: 'Erro ao marcar notificações' });
    }
  },
};


