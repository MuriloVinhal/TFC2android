import 'dart:convert';

class LocalNotificationService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    print('Sistema de notificações locais inicializado');
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    await init();

    // Por enquanto, apenas logamos a notificação
    // Em um sistema real, você pode mostrar um dialog ou snackbar
    print('NOTIFICAÇÃO LOCAL: $title - $body');
    if (data != null) {
      print('Dados: ${jsonEncode(data)}');
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, String>? data,
  }) async {
    await init();

    final now = DateTime.now();
    final difference = scheduledDate.difference(now);

    if (difference.isNegative) {
      print('Data de agendamento já passou: $scheduledDate');
      return;
    }

    print(
      'NOTIFICAÇÃO AGENDADA para ${scheduledDate.toString()}: $title - $body',
    );
    if (data != null) {
      print('Dados: ${jsonEncode(data)}');
    }
  }

  static Future<void> cancelNotification(int id) async {
    print('Cancelando notificação ID: $id');
  }

  static Future<void> cancelAllNotifications() async {
    print('Cancelando todas as notificações');
  }

  static void handleNotificationTap(String? payload) {
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final agendamentoId = data['agendamentoId'];
        final status = data['status'];

        print('Navegando para agendamento: $agendamentoId com status: $status');
        // TODO: Implementar navegação
      } catch (e) {
        print('Erro ao processar payload da notificação: $e');
      }
    }
  }
}

// Manter compatibilidade com código existente
class PushService {
  static Future<void> init() async {
    await LocalNotificationService.init();
  }

  static Future<void> sendDeviceTokenToBackend() async {
    // Não é mais necessário com notificações locais
    // Mas mantemos para compatibilidade
    print('Notificações locais ativadas - não é necessário device token');
  }
}
