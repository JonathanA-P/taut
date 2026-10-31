enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

enum AppPermissionType { location, microphone, camera }

abstract class PermissionService {
  Future<AppPermissionStatus> checkPermission(AppPermissionType type);
  Future<AppPermissionStatus> requestPermission(AppPermissionType type);
  Future<bool> openAppSettings();
}

class PermissionServiceImpl implements PermissionService {
  const PermissionServiceImpl();

  @override
  Future<AppPermissionStatus> checkPermission(AppPermissionType type) async {
    return AppPermissionStatus.unknown;
  }

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    return AppPermissionStatus.unknown;
  }

  @override
  Future<bool> openAppSettings() async {
    return false;
  }
}

