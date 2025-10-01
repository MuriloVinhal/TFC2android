import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/api_config.dart';

class NotificationService {
  static final String baseUrl = ApiConfig.baseUrl;

  static Future<List<Map<String, dynamic>>> getNotificacoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/notificacoes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      print('Erro ao buscar notificações: $e');
      return [];
    }
  }

  static Future<int> getNotificacoesNaoLidasCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$baseUrl/notificacoes/nao-lidas/contar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }

      return 0;
    } catch (e) {
      print('Erro ao contar notificações não lidas: $e');
      return 0;
    }
  }

  static Future<bool> marcarComoLida(int notificacaoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/notificacoes/$notificacaoId/marcar-lida'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao marcar notificação como lida: $e');
      return false;
    }
  }

  static Future<bool> marcarTodasComoLidas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/notificacoes/marcar-todas-lidas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao marcar todas as notificações como lidas: $e');
      return false;
    }
  }

  static String getTipoIcon(String tipo) {
    switch (tipo) {
      case 'aprovacao':
        return '✅';
      case 'reprovacao':
        return '❌';
      case 'conclusao':
        return '🎉';
      case 'status':
        return 'ℹ️';
      default:
        return '📢';
    }
  }

  static String getTipoColor(String tipo) {
    switch (tipo) {
      case 'aprovacao':
        return '0xFF4CAF50'; // Verde
      case 'reprovacao':
        return '0xFFF44336'; // Vermelho
      case 'conclusao':
        return '0xFF2196F3'; // Azul
      case 'status':
        return '0xFFFF9800'; // Laranja
      default:
        return '0xFF9E9E9E'; // Cinza
    }
  }

  static String formatarData(String dataString) {
    try {
      final data = DateTime.parse(dataString);
      final agora = DateTime.now();
      final diferenca = agora.difference(data);

      if (diferenca.inDays > 0) {
        return '${diferenca.inDays}d atrás';
      } else if (diferenca.inHours > 0) {
        return '${diferenca.inHours}h atrás';
      } else if (diferenca.inMinutes > 0) {
        return '${diferenca.inMinutes}min atrás';
      } else {
        return 'Agora';
      }
    } catch (e) {
      return dataString;
    }
  }
}
