import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';

class NotificacoesPage extends StatefulWidget {
  @override
  _NotificacoesPageState createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  List<Map<String, dynamic>> notificacoes = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    setState(() => carregando = true);
    final notifs = await NotificationService.getNotificacoes();
    setState(() {
      notificacoes = notifs;
      carregando = false;
    });
  }

  Future<void> _marcarComoLida(int index) async {
    final notificacao = notificacoes[index];
    final sucesso = await NotificationService.marcarComoLida(notificacao['id']);
    
    if (sucesso) {
      setState(() {
        notificacoes[index]['lida'] = true;
      });
    }
  }

  Future<void> _marcarTodasComoLidas() async {
    final sucesso = await NotificationService.marcarTodasComoLidas();
    
    if (sucesso) {
      setState(() {
        for (var notif in notificacoes) {
          notif['lida'] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
        actions: [
          if (notificacoes.any((n) => !n['lida']))
            TextButton(
              onPressed: _marcarTodasComoLidas,
              child: Text(
                'Marcar todas como lidas',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : notificacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma notificação',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarNotificacoes,
                  child: ListView.builder(
                    itemCount: notificacoes.length,
                    itemBuilder: (context, index) {
                      final notif = notificacoes[index];
                      final isLida = notif['lida'] ?? false;
                      final tipo = notif['tipo'] ?? '';
                      
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        color: isLida ? null : Colors.blue.shade50,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(int.parse(NotificationService.getTipoColor(tipo))),
                            child: Text(
                              NotificationService.getTipoIcon(tipo),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          title: Text(
                            notif['titulo'] ?? '',
                            style: TextStyle(
                              fontWeight: isLida ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(notif['mensagem'] ?? ''),
                              SizedBox(height: 4),
                              Text(
                                NotificationService.formatarData(notif['createdAt'] ?? ''),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: isLida
                              ? null
                              : IconButton(
                                  icon: Icon(Icons.check_circle_outline),
                                  onPressed: () => _marcarComoLida(index),
                                  tooltip: 'Marcar como lida',
                                ),
                          onTap: !isLida ? () => _marcarComoLida(index) : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}