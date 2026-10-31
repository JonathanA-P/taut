enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

enum AppPermissionType { location, microphone, camera }

/// Abstract contract for querying and requesting runtime permissions.
/// Decouples UI from direct native permission handlers.
abstract class PermissionService {
  Future<AppPermissionStatus> checkPermission(AppPermissionType type);
  Future<AppPermissionStatus> requestPermission(AppPermissionType type);
  Future<bool> openAppSettings();
}

/// Minimal foundation placeholder implementation for Stage 01.
/// Real implementation will link to permission_handler in feature branches.
class PermissionServiceImpl implements PermissionService {
  const PermissionServiceImpl();

  @override
  Future<AppPermissionStatus> checkPermission(AppPermissionType type) async {
    // Stage 01 placeholder status
    return AppPermissionStatus.unknown;
  }

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    // Stage 01 placeholder: returns unknown until plugin integration
    return AppPermissionStatus.unknown;
  }

  @override
  Future<bool> openAppSettings() async {
    return false;
  }
}
