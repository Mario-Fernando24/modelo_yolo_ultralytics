import 'dart:io';

class ApiConstants {
  static const detectPath = '/detect';
  static const capturesPath = '/captures';
  static const envUrl = String.fromEnvironment('API_URL');

// funcion para obtener la URL base predeterminada según la plataforma y la variable de entorno
  static String defaultBaseUrl() {
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (Platform.isAndroid) {
      return 'https://modelo-yolo-ultralytics-767768515623.us-central1.run.app';
    }
    return 'https://modelo-yolo-ultralytics-767768515623.us-central1.run.app';
  }
}

// Clase para manejar la configuración de la API, incluyendo la URL base y métodos para actualizarla y resolver rutas.
class ApiConfig {
  ApiConfig(this.baseUrl);

  String baseUrl;

  void update(String url) {
    final trimmed = url.trim();
    baseUrl = trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }

  String resolve(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return '$baseUrl$path';
  }
}
