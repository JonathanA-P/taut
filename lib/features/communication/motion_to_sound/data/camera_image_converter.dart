import 'dart:typed_data';

import 'package:camera/camera.dart';

/// High-performance, zero-allocation image converter for TAUT on-device AI.
/// Converts [CameraImage] (Android YUV420 & iOS BGRA8888) directly into
/// normalized RGB Float32 tensor buffer (320x320x3, [-1.0, 1.0]) with
/// center-square cropping to preserve hand sign aspect ratio.
class CameraImageConverter {
  CameraImageConverter._();

  static const int targetWidth = 320;
  static const int targetHeight = 320;
  static const int tensorSize = targetWidth * targetHeight * 3;

  /// Converts [cameraImage] to a contiguous [Float32List] buffer.
  /// Set [isFrontCamera] to true to mirror coordinates horizontally.
  static Float32List convertToRgbTensor(
    CameraImage cameraImage, {
    bool isFrontCamera = false,
  }) {
    final tensor = Float32List(tensorSize);

    if (cameraImage.format.group == ImageFormatGroup.yuv420 ||
        cameraImage.format.group == ImageFormatGroup.nv21) {
      _convertYuv420(cameraImage, tensor, isFrontCamera);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      _convertBgra8888(cameraImage, tensor, isFrontCamera);
    } else {
      // Fallback for uncommon plane formats
      _convertFallback(cameraImage, tensor, isFrontCamera);
    }

    return tensor;
  }

  /// Converts Android YUV420_8888 planes directly into normalized RGB tensor.
  static void _convertYuv420(
    CameraImage image,
    Float32List outTensor,
    bool isFrontCamera,
  ) {
    final srcWidth = image.width;
    final srcHeight = image.height;

    // Center crop dimensions to preserve aspect ratio
    final cropSize = srcWidth < srcHeight ? srcWidth : srcHeight;
    final startX = (srcWidth - cropSize) ~/ 2;
    final startY = (srcHeight - cropSize) ~/ 2;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBytes = yPlane.bytes;
    final uBytes = uPlane.bytes;
    final vBytes = vPlane.bytes;

    final yRowStride = yPlane.bytesPerRow;
    final uRowStride = uPlane.bytesPerRow;
    final vRowStride = vPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    int tensorIdx = 0;

    for (int y = 0; y < targetHeight; y++) {
      final srcY = startY + (y * cropSize ~/ targetHeight);
      final yRowOffset = srcY * yRowStride;
      final uvRowOffset = (srcY >> 1) * uRowStride;
      final vRowOffset = (srcY >> 1) * vRowStride;

      for (int x = 0; x < targetWidth; x++) {
        final mappedX = isFrontCamera ? (targetWidth - 1 - x) : x;
        final srcX = startX + (mappedX * cropSize ~/ targetWidth);

        final yVal = yBytes[yRowOffset + srcX];
        final uvCol = (srcX >> 1) * uvPixelStride;

        final uVal = uBytes[uvRowOffset + uvCol];
        final vVal = vBytes[vRowOffset + uvCol];

        // Standard ITU-R BT.601 YUV to RGB conversion
        final c = yVal - 16;
        final d = uVal - 128;
        final e = vVal - 128;

        int r = (298 * c + 409 * e + 128) >> 8;
        int g = (298 * c - 100 * d - 208 * e + 128) >> 8;
        int b = (298 * c + 516 * d + 128) >> 8;

        // Clamp to [0, 255]
        if (r < 0) {
          r = 0;
        } else if (r > 255) {
          r = 255;
        }
        if (g < 0) {
          g = 0;
        } else if (g > 255) {
          g = 255;
        }
        if (b < 0) {
          b = 0;
        } else if (b > 255) {
          b = 255;
        }

        // MobileNet SSD Normalization: (val - 127.5) / 127.5 -> [-1.0, 1.0]
        outTensor[tensorIdx++] = (r - 127.5) / 127.5;
        outTensor[tensorIdx++] = (g - 127.5) / 127.5;
        outTensor[tensorIdx++] = (b - 127.5) / 127.5;
      }
    }
  }

  /// Converts iOS BGRA8888 plane directly into normalized RGB tensor.
  static void _convertBgra8888(
    CameraImage image,
    Float32List outTensor,
    bool isFrontCamera,
  ) {
    final srcWidth = image.width;
    final srcHeight = image.height;

    final cropSize = srcWidth < srcHeight ? srcWidth : srcHeight;
    final startX = (srcWidth - cropSize) ~/ 2;
    final startY = (srcHeight - cropSize) ~/ 2;

    final plane = image.planes[0];
    final bytes = plane.bytes;
    final bytesPerRow = plane.bytesPerRow;

    int tensorIdx = 0;

    for (int y = 0; y < targetHeight; y++) {
      final srcY = startY + (y * cropSize ~/ targetHeight);
      final rowOffset = srcY * bytesPerRow;

      for (int x = 0; x < targetWidth; x++) {
        final mappedX = isFrontCamera ? (targetWidth - 1 - x) : x;
        final srcX = startX + (mappedX * cropSize ~/ targetWidth);
        final pixelOffset = rowOffset + (srcX * 4);

        final b = bytes[pixelOffset];
        final g = bytes[pixelOffset + 1];
        final r = bytes[pixelOffset + 2];

        outTensor[tensorIdx++] = (r - 127.5) / 127.5;
        outTensor[tensorIdx++] = (g - 127.5) / 127.5;
        outTensor[tensorIdx++] = (b - 127.5) / 127.5;
      }
    }
  }

  /// Fallback converter sampling single plane luminance or available planes.
  static void _convertFallback(
    CameraImage image,
    Float32List outTensor,
    bool isFrontCamera,
  ) {
    final bytes = image.planes[0].bytes;
    final srcWidth = image.width;
    final srcHeight = image.height;

    int tensorIdx = 0;
    for (int y = 0; y < targetHeight; y++) {
      final srcY = (y * srcHeight ~/ targetHeight);
      final rowOffset = srcY * srcWidth;

      for (int x = 0; x < targetWidth; x++) {
        final mappedX = isFrontCamera ? (targetWidth - 1 - x) : x;
        final srcX = (mappedX * srcWidth ~/ targetWidth);
        final val = (rowOffset + srcX < bytes.length)
            ? bytes[rowOffset + srcX]
            : 128;
        final norm = (val - 127.5) / 127.5;

        outTensor[tensorIdx++] = norm;
        outTensor[tensorIdx++] = norm;
        outTensor[tensorIdx++] = norm;
      }
    }
  }
}
