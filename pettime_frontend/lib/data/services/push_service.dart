import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../../core/utils/api_config.dart';

// Função para lidar com mensagens em background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Mensagem recebida em background: ${message.messageId}");
  
  // Mostrar notificação local se não há payload de notificação
  if (message.notification == null) {
    await PushService._showLocalNotification(message);
  }
}

class PushService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static String? _fcmToken;

  /// Inicializa o serviço de notificações push
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // Configurar handler para mensagens em background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Solicitar permissões
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Permissões de notificação concedidas');
      } else {
        print('Permissões de notificação negadas');
        return;
      }

      // Inicializar notificações locais
      await _initializeLocalNotifications();

      // Obter token FCM
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // Configurar listeners para mensagens
      _setupMessageHandlers();

      _initialized = true;
      print('Serviço de notificações push inicializado com sucesso');

    } catch (e) {
      print('Erro ao inicializar notificações push: $e');
    }
  }

  /// Inicializa as notificações locais
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsiOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsiOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Configurar canal de notificação para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pettime_channel',
      'PetTime Notificações',
      description: 'Canal para notificações do PetTime',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Configura os handlers para diferentes tipos de mensagens
  static void _setupMessageHandlers() {
    // Mensagens quando o app está em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida em foreground: ${message.messageId}');
      _showLocalNotification(message);
    });

    // Mensagens quando o app foi aberto por uma notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App aberto via notificação: ${message.messageId}');
      _handleNotificationTap(message.data);
    });

    // Verificar se o app foi iniciado por uma notificação
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App iniciado via notificação: ${message.messageId}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// Mostra uma notificação local
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pettime_channel',
      'PetTime Notificações',
      channelDescription: 'Canal para notificações do PetTime',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'PetTime',
      message.notification?.body ?? 'Nova notificação',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  /// Callback quando uma notificação é tocada
  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationTap(data);
      } catch (e) {
        print('Erro ao processar payload da notificação: $e');
      }
    }
  }

  /// Lida com o toque em uma notificação
  static void _handleNotificationTap(Map<String, dynamic> data) {
    print('Notificação tocada com dados: $data');
    
    // TODO: Implementar navegação específica baseada no tipo de notificação
    final tipo = data['tipo'];
    final agendamentoId = data['agendamentoId'];
    
    switch (tipo) {
      case 'agendamento_confirmado':
      case 'agendamento_cancelado':
      case 'lembrete_consulta':
        print('Navegando para agendamento: $agendamentoId');
        // Implementar navegação para a tela de agendamentos
        break;
      default:
        print('Tipo de notificação desconhecido: $tipo');
    }
  }

  /// Obtém o token FCM atual
  static Future<String?> getToken() async {
    if (!_initialized) await init();
    return _fcmToken;
  }

  /// Envia o token FCM para o backend
  static Future<bool> sendTokenToBackend(String userId) async {
    if (_fcmToken == null) return false;

    try {
      // Usar a configuração de API do projeto
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': _fcmToken,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        print('Token FCM enviado com sucesso para o backend');
        return true;
      } else {
        print('Erro ao enviar token para o backend: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erro ao enviar token para o backend: $e');
      return false;
    }
  }

  /// Subscreve a um tópico específico
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscrito ao tópico: $topic');
    } catch (e) {
      print('Erro ao subscrever ao tópico $topic: $e');
    }
  }

  /// Remove subscrição de um tópico específico
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Removida subscrição do tópico: $topic');
    } catch (e) {
      print('Erro ao remover subscrição do tópico $topic: $e');
    }
  }
}

// Manter compatibilidade com código existente
class LocalNotificationService {
  static Future<void> init() async {
    await PushService.init();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // Usar o serviço de notificações locais do PushService
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pettime_channel',
      'PetTime Notificações',
      channelDescription: 'Canal para notificações do PetTime',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await PushService._localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, String>? data,
  }) async {
    // Para notificações agendadas, você pode usar o flutter_local_notifications
    // ou implementar um sistema no backend que envia a notificação no momento certo
    print('Agendamento de notificação para $scheduledDate: $title - $body');
    
    // TODO: Implementar agendamento real ou enviar para o backend
  }

  static Future<void> cancelNotification(int id) async {
    await PushService._localNotifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await PushService._localNotifications.cancelAll();
  }
}