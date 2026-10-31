/// Base exception class for all TAUT application domain exceptions.
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

/// Authentication & Authorization Exceptions
class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.details});
}

/// Healthcare Facility & OpenStreetMap Exceptions
class HealthcareException extends AppException {
  const HealthcareException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Location & Sensor Exceptions
class LocationException extends AppException {
  const LocationException({required super.message, super.code, super.details});
}

class LocationUnavailableException extends AppException {
  const LocationUnavailableException(String message, {String? code})
      : super(message: message, code: code ?? 'location_unavailable');
}

/// Permission Denied Exceptions
class PermissionDeniedException extends AppException {
  final String? permissionType;

  const PermissionDeniedException({
    this.permissionType,
    required super.message,
    super.code = 'PERMISSION_DENIED',
  });
}

/// Speech Recognition Exceptions
class SpeechRecognitionException extends AppException {
  const SpeechRecognitionException({
    required super.message,
    super.code,
    super.details,
  });
}

/// BISINDO Gesture Model Inference Exceptions
class BisindoInferenceException extends AppException {
  const BisindoInferenceException({
    required super.message,
    super.code,
    super.details,
  });
}

