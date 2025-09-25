const express = require('express');
const router = express.Router();
const pushService = require('../services/pushNotificationService');

// Armazenamento temporário de tokens FCM (em produção, usar banco de dados)
const userTokens = new Map();

/**
 * Armazena o token FCM do usuário
 * POST /api/notifications/token
 */
router.post('/token', async (req, res) => {
  try {
    const { token, userId } = req.body;

    if (!token || !userId) {
      return res.status(400).json({
        error: 'Token FCM e ID do usuário são obrigatórios'
      });
    }

    // Armazenar token no Map temporário (em produção, salvar no banco)
    if (!userTokens.has(userId)) {
      userTokens.set(userId, []);
    }
    
    const tokens = userTokens.get(userId);
    if (!tokens.includes(token)) {
      tokens.push(token);
    }
    
    console.log(`📱 Token FCM salvo para usuário ${userId}: ${token.substring(0, 20)}...`);
    console.log(`📱 Total de tokens para usuário ${userId}: ${tokens.length}`);

    res.json({
      success: true,
      message: 'Token FCM salvo com sucesso'
    });
  } catch (error) {
    console.error('Erro ao salvar token FCM:', error);
    res.status(500).json({
      error: 'Erro interno do servidor'
    });
  }
});

/**
 * Envia notificação para um usuário específico
 * POST /api/notifications/send-to-user
 */
router.post('/send-to-user', async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;

    if (!userId || !title || !body) {
      return res.status(400).json({
        error: 'ID do usuário, título e corpo são obrigatórios'
      });
    }

    // Buscar tokens FCM do usuário (do Map temporário)
    const tokens = userTokens.get(userId) || [];

    if (tokens.length === 0) {
      return res.status(404).json({
        error: 'Nenhum token FCM encontrado para o usuário'
      });
    }

    console.log(`📱 Enviando notificação para usuário ${userId} com ${tokens.length} tokens`);

    const result = await pushService.sendToMultipleDevices(
      tokens,
      title,
      body,
      data || {}
    );

    res.json({
      success: result.success,
      message: `Notificação enviada para ${result.successCount}/${tokens.length} dispositivos`,
      details: result
    });
  } catch (error) {
    console.error('Erro ao enviar notificação:', error);
    res.status(500).json({
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

/**
 * Envia notificação para múltiplos usuários
 * POST /api/notifications/send-to-users
 */
router.post('/send-to-users', async (req, res) => {
  try {
    const { userIds, title, body, data } = req.body;

    if (!userIds || !Array.isArray(userIds) || !title || !body) {
      return res.status(400).json({
        error: 'Array de IDs de usuários, título e corpo são obrigatórios'
      });
    }

    // TODO: Buscar todos os tokens FCM dos usuários
    const allTokens = userIds.map(id => `demo-token-${id}`); // Simular busca

    const result = await pushService.sendToMultipleDevices(
      allTokens,
      title,
      body,
      data || {}
    );

    res.json({
      success: result.success,
      message: `Notificação enviada para ${result.successCount}/${allTokens.length} dispositivos`,
      targetUsers: userIds.length,
      details: result
    });
  } catch (error) {
    console.error('Erro ao enviar notificações:', error);
    res.status(500).json({
      error: 'Erro interno do servidor'
    });
  }
});

/**
 * Envia notificação por tópico
 * POST /api/notifications/send-to-topic
 */
router.post('/send-to-topic', async (req, res) => {
  try {
    const { topic, title, body, data } = req.body;

    if (!topic || !title || !body) {
      return res.status(400).json({
        error: 'Tópico, título e corpo são obrigatórios'
      });
    }

    const result = await pushService.sendToTopic(
      topic,
      title,
      body,
      data || {}
    );

    res.json({
      success: result.success,
      message: `Notificação enviada ao tópico: ${topic}`,
      details: result
    });
  } catch (error) {
    console.error('Erro ao enviar notificação ao tópico:', error);
    res.status(500).json({
      error: 'Erro interno do servidor'
    });
  }
});

/**
 * Notificações específicas para agendamentos
 */

/**
 * Confirma agendamento e envia notificação
 * POST /api/notifications/agendamento-confirmado
 */
router.post('/agendamento-confirmado', async (req, res) => {
  try {
    const { agendamentoId, userId, petNome, data, horario } = req.body;

    if (!agendamentoId || !userId || !petNome || !data || !horario) {
      return res.status(400).json({
        error: 'Dados do agendamento incompletos'
      });
    }

    const title = '✅ Agendamento Confirmado';
    const body = `Consulta do ${petNome} confirmada para ${data} às ${horario}`;
    const notificationData = {
      tipo: 'agendamento_confirmado',
      agendamentoId: agendamentoId.toString(),
      petNome,
      data,
      horario
    };

    // TODO: Buscar token do usuário
    const userTokens = [`demo-token-${userId}`];

    const result = await pushService.sendToMultipleDevices(
      userTokens,
      title,
      body,
      notificationData
    );

    res.json({
      success: result.success,
      message: 'Notificação de confirmação enviada',
      details: result
    });
  } catch (error) {
    console.error('Erro ao enviar notificação de confirmação:', error);
    res.status(500).json({
      error: 'Erro interno do servidor'
    });
  }
});

/**
 * Cancela agendamento e envia notificação
 * POST /api/notifications/agendamento-cancelado
 */
router.post('/agendamento-cancelado', async (req, res) => {
  try {
    const { agendamentoId, userId, petNome, data, horario, motivo } = req.body;

    const title = '❌ Agendamento Cancelado';
    const body = `Consulta do ${petNome} de ${data} às ${horario} foi cancelada${motivo ? `: ${motivo}` : ''}`;
    const notificationData = {
      tipo: 'agendamento_cancelado',
      agendamentoId: agendamentoId.toString(),
      petNome,
      data,
      horario,
      motivo
    };

    // TODO: Buscar token do usuário
    const userTokens = [`demo-token-${userId}`];

    const result = await pushService.sendToMultipleDevices(
      userTokens,
      title,
      body,
      notificationData
    );

    res.json({
      success: result.success,
      message: 'Notificação de cancelamento enviada',
      details: result
    });
  } catch (error) {
    console.error('Erro ao enviar notificação de cancelamento:', error);
    res.status(500).json({
      error: 'Erro interno do servidor'
    });
  }
});

/**
 * Envia lembrete de consulta
 * POST /api/notifications/lembrete-consulta
 */
router.post('/lembrete-consulta', async (req, res) => {
  try {
    const { agendamentoId, userId, petNome, data, horario, tempoAntecedencia } = req.body;

    const title = '🔔 Lembrete de Consulta';
    const body = `Lembrete: Consulta do ${petNome} ${tempoAntecedencia || 'amanhã'} às ${horario}`;
    const notificationData = {
      tipo: 'lembrete_consulta',
      agendamentoId: agendamentoId.toString(),
      petNome,
      data,
      horario
    };

    // TODO: Buscar token do usuário
    const userTokens = [`demo-token-${userId}`];

    const result = await pushService.sendToMultipleDevices(
      userTokens,
      title,
      body,
      notificationData
    );

    res.json({
      success: result.success,
      message: 'Lembrete enviado',
      details: result
    });
  } catch (error) {
    console.error('Erro ao enviar lembrete:', error);
    res.status(500).json({
      error: 'Erro interno do servidor'
    });
  }
});

module.exports = router;