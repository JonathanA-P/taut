enum AppPermission { location, camera, microphone }

enum PermissionStatus { granted, denied, permanentlyDenied }

abstract class PermissionService {
  Future<PermissionStatus> check(AppPermission permission);
  Future<PermissionStatus> request(AppPermission permission);
}

class StubPermissionService implements PermissionService {
  @override
  Future<PermissionStatus> check(AppPermission permission) async =>
      PermissionStatus.denied;

  @override
  Future<PermissionStatus> request(AppPermission permission) async =>
      PermissionStatus.denied;
}

