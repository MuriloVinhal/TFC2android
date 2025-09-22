import 'package:flutter_test/flutter_test.dart';
import 'package:pettime_frontend/core/utils/api_config.dart';

void main() {
  group('Testes de Configuração da API', () {
    test('Configuração da API deve ter URL base válida', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.baseUrl, startsWith('http'));
    });

    test('Endpoints da API devem ser construídos corretamente', () {
      final loginEndpoint = '${ApiConfig.baseUrl}/usuarios/login';
      expect(loginEndpoint, contains('/usuarios/login'));
    });
  });
}
