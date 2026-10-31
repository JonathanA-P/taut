/// Abstraksi izin perangkat untuk fitur TAUT.
///
/// STAGE 01 — STUB: file ini hanya mendefinisikan kontraknya.
/// Implementasi aslinya (pakai package `permission_handler` + dialog
/// penjelasan sebelum meminta izin, sesuai spesifikasi TAUT) dibuat
/// saat fitur yang membutuhkannya dibangun, dan di sini hanya perlu
/// mengganti isi [PermissionService] — pemanggilnya tidak berubah.
///
/// Prinsip yang TIDAK BOLEH dilanggar saat implementasi:
/// - Jangan pernah meminta izin tanpa penjelasan dulu
///   (pakai [PermissionExplanationCard]).
/// - Kalau izin ditolak, tampilkan apa yang tidak bisa dilakukan
///   dan cara mengaktifkannya, jangan diam-diam gagal.
enum AppPermission { location, camera, microphone }

enum PermissionStatus { granted, denied, permanentlyDenied }

abstract class PermissionService {
  Future<PermissionStatus> check(AppPermission permission);
  Future<PermissionStatus> request(AppPermission permission);
}

/// Implementasi skeleton: selalu melaporkan belum diizinkan.
///
/// Sengaja begini supaya tidak ada fitur yang mengklaim sudah punya
/// izin padahal belum pernah memintanya. Begitu package izin
/// ditambahkan, ganti kelas ini dengan implementasi aslinya.
class StubPermissionService implements PermissionService {
  @override
  Future<PermissionStatus> check(AppPermission permission) async =>
      PermissionStatus.denied;

  @override
  Future<PermissionStatus> request(AppPermission permission) async =>
      PermissionStatus.denied;
}
