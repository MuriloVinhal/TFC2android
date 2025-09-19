import 'package:flutter/material.dart';
import '../../data/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch().then((_) async {
      await NotificationService.marcarTodasComoLidas();
    });
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final data = await NotificationService.getNotificacoes();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _markAll() async {
    final ok = await NotificationService.marcarTodasComoLidas();
    if (ok) _fetch();
  }

  Future<void> _markOne(int id) async {
    final ok = await NotificationService.marcarComoLida(id);
    if (ok) _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          TextButton(
            onPressed: _markAll,
            child: const Text(
              'Marcar todas',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _items.isEmpty
                  ? const ListTile(title: Text('Sem notificações'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final n = _items[index];
                        final tipo = (n['tipo'] ?? '').toString();
                        final titulo = (n['titulo'] ?? '').toString();
                        final mensagem = (n['mensagem'] ?? '').toString();
                        final lida = n['lida'] == true;
                        final createdAt = (n['createdAt'] ?? '').toString();
                        final when = NotificationService.formatarData(
                          createdAt,
                        );
                        return ListTile(
                          leading: Text(
                            NotificationService.getTipoIcon(tipo),
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            titulo,
                            style: TextStyle(
                              fontWeight: lida
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mensagem),
                              const SizedBox(height: 4),
                              Text(
                                when,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: lida
                              ? const SizedBox.shrink()
                              : IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () => _markOne(n['id'] as int),
                                ),
                        );
                      },
                    ),
            ),
    );
  }
}
