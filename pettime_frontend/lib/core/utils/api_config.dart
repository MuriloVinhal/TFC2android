import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiConfig {
  static const int _apiPort = 3000;

  static String get baseHost {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {
      // Platform not available; fallback below
    }
    return 'localhost';
  }

  static String get baseUrl => 'http://$baseHost:$_apiPort';
}
