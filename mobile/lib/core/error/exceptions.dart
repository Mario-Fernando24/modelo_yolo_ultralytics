class ServerException implements Exception {
  ServerException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DeviceException implements Exception {
  DeviceException(this.message);
  final String message;

  @override
  String toString() => message;
}
