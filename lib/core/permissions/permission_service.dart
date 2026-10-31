import 'package:permission_handler/permission_handler.dart' as ph;

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

/// Production implementation using permission_handler.
class PermissionServiceImpl implements PermissionService {
  const PermissionServiceImpl();

  ph.Permission _mapType(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.location:
        return ph.Permission.location;
      case AppPermissionType.microphone:
        return ph.Permission.microphone;
      case AppPermissionType.camera:
        return ph.Permission.camera;
    }
  }

  AppPermissionStatus _mapStatus(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
      case ph.PermissionStatus.limited:
        return AppPermissionStatus.granted;
      case ph.PermissionStatus.denied:
        return AppPermissionStatus.denied;
      case ph.PermissionStatus.permanentlyDenied:
        return AppPermissionStatus.permanentlyDenied;
      case ph.PermissionStatus.restricted:
        return AppPermissionStatus.restricted;
      default:
        return AppPermissionStatus.unknown;
    }
  }

  @override
  Future<AppPermissionStatus> checkPermission(AppPermissionType type) async {
    final status = await _mapType(type).status;
    return _mapStatus(status);
  }

  @override
  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    final status = await _mapType(type).request();
    return _mapStatus(status);
  }

  @override
  Future<bool> openAppSettings() async {
    return ph.openAppSettings();
  }
}
