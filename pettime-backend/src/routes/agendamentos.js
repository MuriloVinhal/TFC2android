const express = require('express');
const router = express.Router();

// Importe seus modelos conforme sua estrutura
const { Agendamento, Pet, Servico, Tosa, ServicoAdicional, Produto, Notificacao, Usuario } = require('../models');
const auth = require('../middlewares/authMiddleware');

// Rota para retornar todos os agendamentos (admin)
router.get('/all', async (req, res) => {
    try {
        const agendamentos = await Agendamento.findAll({
            include: [
                { model: Pet, as: 'pet', include: [{ model: Usuario, as: 'usuario' }] },
                { model: Servico, as: 'servico' },
                { model: Tosa, as: 'tosa' },
                { model: ServicoAdicional, as: 'servicosAdicionais' },
                { model: Produto, as: 'produtos' }
            ],
            order: [['data', 'DESC']]
        });
        res.json(agendamentos);
    } catch (error) {
        console.error(error);
  res.status(500).json({ error: 'Erro ao buscar agendamentos', message: 'Erro ao buscar agendamentos' });
    }
});

// Listar agendamentos com filtros (por petId e/ou data)
router.get('/', async (req, res) => {
  try {
    const { petId, data } = req.query;
    const where = {};
    if (petId) where.petId = petId;
    if (data) where.data = data; // data no formato YYYY-MM-DD

    const itens = await Agendamento.findAll({
      where,
      include: [
        { model: Pet, as: 'pet', include: [{ model: Usuario, as: 'usuario' }] },
        { model: Servico, as: 'servico' },
        { model: Tosa, as: 'tosa' },
        { model: ServicoAdicional, as: 'servicosAdicionais' },
        { model: Produto, as: 'produtos' },
      ],
      order: [['data', 'DESC']],
    });
    res.json(itens);
  } catch (e) {
    console.error(e);
  res.status(500).json({ error: 'Erro ao listar agendamentos', message: 'Erro ao listar agendamentos' });
  }
});

// Criar agendamento
router.post('/', async (req, res) => {
  const t = await Agendamento.sequelize.transaction();
  try {
    const {
      petId,
      servicoId,
      tosaId,
      data,
      horario,
      taxiDog,
      observacao,
      produtos,
      servicosAdicionais,
    } = req.body;

    if (!petId || !servicoId || !data || !horario) {
      await t.rollback();
  return res.status(400).json({ error: 'Campos obrigatórios ausentes.', message: 'Campos obrigatórios ausentes.' });
    }

    // Valida formato de horário HH:mm e janela de atendimento
    const horaMatch = /^([0-1]?\d|2[0-3]):([0-5]\d)$/.exec(String(horario));
    if (!horaMatch) {
      await t.rollback();
  return res.status(400).json({ error: 'Horário inválido. Use HH:mm.', message: 'Horário inválido. Use HH:mm.' });
    }
    const hora = parseInt(horaMatch[1], 10);
    const minuto = parseInt(horaMatch[2], 10);
    // Janela de atendimento: 09:00 às 16:00, intervalos de 60 minutos
    if (minuto !== 0 || hora < 9 || hora > 16) {
      await t.rollback();
  return res.status(400).json({ error: 'Horário fora da janela de atendimento.', message: 'Horário fora da janela de atendimento.' });
    }

    // Monta Date do agendamento no fuso do servidor
    const dataHoraStr = `${data}T${String(horario)}:00`;
    const agendamentoDate = new Date(dataHoraStr);
    const agora = new Date();
    if (isNaN(agendamentoDate.getTime())) {
      await t.rollback();
  return res.status(400).json({ error: 'Data ou horário inválidos.', message: 'Data ou horário inválidos.' });
    }
    // Bloqueia domingo
    const diaSemana = agendamentoDate.getDay(); // 0=Dom
    if (diaSemana === 0) {
      await t.rollback();
  return res.status(400).json({ error: 'Agendamentos não são permitidos aos domingos.', message: 'Agendamentos não são permitidos aos domingos.' });
    }
    // Horário no passado
    if (agendamentoDate.getTime() <= agora.getTime()) {
      await t.rollback();
  return res.status(400).json({ error: 'Não é possível agendar em horário passado.', message: 'Não é possível agendar em horário passado.' });
    }

    // Verificações de existência
    const pet = await Pet.findByPk(petId);
    if (!pet) {
      await t.rollback();
  return res.status(404).json({ error: 'Pet não encontrado.', message: 'Pet não encontrado.' });
    }
    const serv = await Servico.findByPk(servicoId);
    if (!serv) {
      await t.rollback();
  return res.status(404).json({ error: 'Serviço não encontrado.', message: 'Serviço não encontrado.' });
    }
    if (tosaId) {
      const tosaEnt = await Tosa.findByPk(tosaId);
      if (!tosaEnt) {
        await t.rollback();
  return res.status(404).json({ error: 'Tosa não encontrada.', message: 'Tosa não encontrada.' });
      }
    }

    // Conflitos: existe agendamento na mesma data/horário em status que ocupam a agenda
    const statusesQueOcupam = ['pendente', 'aprovado', 'em espera', 'em andamento', 'a caminho'];
    const conflito = await Agendamento.findOne({
      where: { data, horario },
      transaction: t,
    });
    if (conflito && statusesQueOcupam.includes(String(conflito.status))) {
      await t.rollback();
  return res.status(409).json({ error: 'Horário indisponível. Já existe agendamento neste horário.', message: 'Horário indisponível. Já existe agendamento neste horário.' });
    }

    const novo = await Agendamento.create(
      {
        petId,
        servicoId,
        tosaId: tosaId || null,
        data,
        horario,
        taxiDog: !!taxiDog,
        observacao: observacao || null,
        status: 'pendente',
      },
      { transaction: t }
    );

    if (Array.isArray(produtos) && produtos.length > 0) {
      await novo.setProdutos(produtos, { transaction: t });
    }

    if (Array.isArray(servicosAdicionais) && servicosAdicionais.length > 0) {
      await novo.setServicosAdicionais(servicosAdicionais, { transaction: t });
    }

    await t.commit();

    const criado = await Agendamento.findByPk(novo.id, {
      include: [
        { model: Pet, as: 'pet' },
        { model: Servico, as: 'servico' },
        { model: Tosa, as: 'tosa' },
        { model: ServicoAdicional, as: 'servicosAdicionais' },
        { model: Produto, as: 'produtos' },
      ],
    });

    return res.status(201).json(criado);
  } catch (e) {
    console.error(e);
    try { await t.rollback(); } catch (_) {}
  return res.status(500).json({ error: 'Erro ao criar agendamento', message: 'Erro ao criar agendamento' });
  }
});

// Aprovar agendamento (gera notificação para dono do pet)
router.put('/:id/approve', async (req, res) => {
  try {
    const { id } = req.params;
    const ag = await Agendamento.findByPk(id, { include: [{ model: Pet, as: 'pet' }] });
  if (!ag) return res.status(404).json({ error: 'Agendamento não encontrado', message: 'Agendamento não encontrado' });
    ag.status = 'aprovado';
    await ag.save();

    if (ag.pet && ag.pet.usuarioId) {
      await Notificacao.create({
        usuarioId: ag.pet.usuarioId,
        tipo: 'aprovacao',
        titulo: 'Agendamento aprovado',
        mensagem: `Seu agendamento #${ag.id} foi aprovado.`,
      });
    }

    res.json(ag);
  } catch (e) {
    console.error(e);
  res.status(500).json({ error: 'Erro ao aprovar agendamento', message: 'Erro ao aprovar agendamento' });
  }
});

// Alterar status (gera notificação)
router.put('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const ag = await Agendamento.findByPk(id, { include: [{ model: Pet, as: 'pet' }] });
  if (!ag) return res.status(404).json({ error: 'Agendamento não encontrado', message: 'Agendamento não encontrado' });
    ag.status = status;
    await ag.save();

    if (ag.pet && ag.pet.usuarioId) {
      await Notificacao.create({
        usuarioId: ag.pet.usuarioId,
        tipo: status === 'reprovado' ? 'reprovacao' : 'status',
        titulo: 'Status do agendamento atualizado',
        mensagem: `Agendamento #${ag.id} agora está: ${status}.`,
      });
    }

    res.json(ag);
  } catch (e) {
    console.error(e);
  res.status(500).json({ error: 'Erro ao alterar status', message: 'Erro ao alterar status' });
  }
});

module.exports = router;