class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.details});
}

class HealthcareException extends AppException {
  const HealthcareException({
    required super.message,
    super.code,
    super.details,
  });
}

class LocationException extends AppException {
  const LocationException({required super.message, super.code, super.details});
}

class LocationUnavailableException extends AppException {
  const LocationUnavailableException(String message, {String? code})
      : super(message: message, code: code ?? 'location_unavailable');
}

class PermissionDeniedException extends AppException {
  final String? permissionType;

  const PermissionDeniedException({
    this.permissionType,
    required super.message,
    super.code = 'PERMISSION_DENIED',
  });
}

class SpeechRecognitionException extends AppException {
  const SpeechRecognitionException({
    required super.message,
    super.code,
    super.details,
  });
}

class BisindoInferenceException extends AppException {
  const BisindoInferenceException({
    required super.message,
    super.code,
    super.details,
  });
}

