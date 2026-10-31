class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message)
      : super(code: 'permission_denied');
}

class LocationUnavailableException extends AppException {
  const LocationUnavailableException(super.message)
      : super(code: 'location_unavailable');
}
