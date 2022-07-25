class StoreCameraException implements Exception {
  final String message;

  const StoreCameraException(this.message);

  @override
  String toString() {
    return '$runtimeType{message: $message}';
  }
}

class StatusCodeException extends StoreCameraException {
  final int? statusCode;

  StatusCodeException(this.statusCode) : super('State Code : $statusCode');
}