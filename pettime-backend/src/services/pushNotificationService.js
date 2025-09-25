const admin = require('firebase-admin');

// Configurar Firebase Admin SDK
const initializeFirebase = () => {
  try {
    // Para desenvolvimento local, você pode usar a chave de serviço
    // Em produção, use variáveis de ambiente
    const serviceAccount = {
      "type": "service_account",
      "project_id": "pettime-f6c68",
      "private_key_id": process.env.FIREBASE_PRIVATE_KEY_ID,
      "private_key": process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      "client_email": process.env.FIREBASE_CLIENT_EMAIL,
      "client_id": process.env.FIREBASE_CLIENT_ID,
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": process.env.FIREBASE_CLIENT_CERT_URL
    };

    // Verificar se as variáveis de ambiente estão configuradas
    if (!serviceAccount.private_key || !serviceAccount.client_email) {
      console.warn('⚠️  Variáveis de ambiente do Firebase não configuradas. Usando modo de desenvolvimento.');
      // Em desenvolvimento, você pode baixar o arquivo JSON de credenciais
      // e colocá-lo na pasta do projeto (não commitê-lo!)
      return null;
    }

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: 'pettime-f6c68',
    });

    console.log('✅ Firebase Admin SDK inicializado com sucesso');
    return admin;
  } catch (error) {
    console.error('❌ Erro ao inicializar Firebase Admin SDK:', error);
    return null;
  }
};

class PushNotificationService {
  constructor() {
    this.admin = initializeFirebase();
    this.messaging = this.admin?.messaging();
  }

  /**
   * Envia uma notificação push para um dispositivo específico
   * @param {string} token - Token FCM do dispositivo
   * @param {string} title - Título da notificação
   * @param {string} body - Corpo da notificação
   * @param {object} data - Dados adicionais
   */
  async sendToDevice(token, title, body, data = {}) {
    if (!this.messaging) {
      console.log('📱 SIMULAÇÃO DE NOTIFICAÇÃO PUSH:');
      console.log(`   Token: ${token.substring(0, 20)}...`);
      console.log(`   Título: ${title}`);
      console.log(`   Mensagem: ${body}`);
      console.log(`   Dados:`, data);
      return { success: true, messageId: 'dev-simulation' };
    }

    try {
      const message = {
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
        },
        token,
        android: {
          notification: {
            channelId: 'pettime_channel',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title,
                body,
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      console.log('✅ Notificação enviada com sucesso:', response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('❌ Erro ao enviar notificação:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Envia notificação para múltiplos dispositivos
   * @param {string[]} tokens - Array de tokens FCM
   * @param {string} title - Título da notificação
   * @param {string} body - Corpo da notificação
   * @param {object} data - Dados adicionais
   */
  async sendToMultipleDevices(tokens, title, body, data = {}) {
    if (!this.messaging) {
      console.log('📱 SIMULAÇÃO DE NOTIFICAÇÃO PUSH MÚLTIPLA:');
      console.log(`   ${tokens.length} dispositivos`);
      console.log(`   Título: ${title}`);
      console.log(`   Mensagem: ${body}`);
      return { success: true, successCount: tokens.length, failureCount: 0 };
    }

    try {
      const message = {
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
        },
        tokens,
        android: {
          notification: {
            channelId: 'pettime_channel',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title,
                body,
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      const response = await this.messaging.sendEachForMulticast(message);
      console.log(`✅ ${response.successCount}/${tokens.length} notificações enviadas`);
      
      if (response.failureCount > 0) {
        console.warn(`⚠️  ${response.failureCount} falhas:`, response.responses
          .filter(r => !r.success)
          .map(r => r.error?.message));
      }

      return {
        success: true,
        successCount: response.successCount,
        failureCount: response.failureCount,
        responses: response.responses,
      };
    } catch (error) {
      console.error('❌ Erro ao enviar notificações múltiplas:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Envia notificação por tópico
   * @param {string} topic - Nome do tópico
   * @param {string} title - Título da notificação
   * @param {string} body - Corpo da notificação
   * @param {object} data - Dados adicionais
   */
  async sendToTopic(topic, title, body, data = {}) {
    if (!this.messaging) {
      console.log('📱 SIMULAÇÃO DE NOTIFICAÇÃO POR TÓPICO:');
      console.log(`   Tópico: ${topic}`);
      console.log(`   Título: ${title}`);
      console.log(`   Mensagem: ${body}`);
      return { success: true, messageId: 'dev-topic-simulation' };
    }

    try {
      const message = {
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          timestamp: new Date().toISOString(),
        },
        topic,
        android: {
          notification: {
            channelId: 'pettime_channel',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              alert: {
                title,
                body,
              },
              badge: 1,
              sound: 'default',
            },
          },
        },
      };

      const response = await this.messaging.send(message);
      console.log('✅ Notificação enviada ao tópico:', response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error('❌ Erro ao enviar notificação ao tópico:', error);
      return { success: false, error: error.message };
    }
  }

  /**
   * Programa uma notificação (implementação futura)
   * @param {string} token - Token FCM
   * @param {string} title - Título
   * @param {string} body - Corpo
   * @param {Date} scheduledTime - Hora agendada
   * @param {object} data - Dados adicionais
   */
  async scheduleNotification(token, title, body, scheduledTime, data = {}) {
    // Firebase não suporta agendamento nativo
    // Você precisaria implementar um sistema de agendamento (cron jobs, etc.)
    
    console.log('📅 Agendamento de notificação:', {
      token: token.substring(0, 20) + '...',
      title,
      body,
      scheduledTime: scheduledTime.toISOString(),
      data,
    });

    // TODO: Implementar sistema de agendamento
    // Opções: node-cron, bull queue, agenda, etc.
    
    return {
      success: true,
      scheduled: true,
      scheduledTime: scheduledTime.toISOString(),
    };
  }
}

// Instância singleton
const pushService = new PushNotificationService();

module.exports = pushService;