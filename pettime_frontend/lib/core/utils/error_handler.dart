class ErrorHandler {
  /// Extrai a mensagem de erro de uma resposta JSON do backend
  static String extractErrorMessage(Map<String, dynamic> errorResponse, [String defaultMessage = 'Erro desconhecido']) {
    // Tenta diferentes chaves de mensagem que o backend pode retornar
    if (errorResponse['message'] != null) {
      return errorResponse['message'];
    } else if (errorResponse['erro'] != null) {
      return errorResponse['erro'];
    } else if (errorResponse['mensagem'] != null) {
      return errorResponse['mensagem'];
    } else if (errorResponse['error'] != null) {
      return errorResponse['error'];
    }
    
    return defaultMessage;
  }
  
  /// Trata erros de conexão e HTTP de forma padronizada
  static String handleConnectionError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Tempo esgotado. Tente novamente.';
    } else {
      return 'Erro de conexão: ${error.toString()}';
    }
  }
}