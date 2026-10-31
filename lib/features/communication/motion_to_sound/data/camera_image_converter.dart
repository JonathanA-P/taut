import 'dart:typed_data';

import 'package:camera/camera.dart';

/// High-performance, zero-allocation image converter for TAUT on-device AI.
/// Converts [CameraImage] (Android YUV420 & iOS BGRA8888) directly into
/// normalized RGB Float32 tensor buffer (320x320x3, [-1.0, 1.0]) with
/// center-square cropping and sensor orientation handling to preserve hand sign aspect ratio.
class CameraImageConverter {
  CameraImageConverter._();

  static const int targetWidth = 320;
  static const int targetHeight = 320;
  static const int tensorSize = targetWidth * targetHeight * 3;

  /// Converts [cameraImage] to a contiguous [Float32List] buffer.
  /// Set [isFrontCamera] to true to mirror coordinates horizontally.
  /// [sensorOrientation] handles Android/iOS portrait/landscape rotation (0, 90, 180, 270).
  static Float32List convertToRgbTensor(
    CameraImage cameraImage, {
    bool isFrontCamera = false,
    int sensorOrientation = 0,
  }) {
    final tensor = Float32List(tensorSize);

    if (cameraImage.format.group == ImageFormatGroup.yuv420 ||
        cameraImage.format.group == ImageFormatGroup.nv21) {
      _convertYuv420(cameraImage, tensor, isFrontCamera, sensorOrientation);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      _convertBgra8888(cameraImage, tensor, isFrontCamera, sensorOrientation);
    } else {
      _convertFallback(cameraImage, tensor, isFrontCamera);
    }

    return tensor;
  }

  /// Converts Android YUV420_8888 planes directly into normalized RGB tensor.
  static void _convertYuv420(
    CameraImage image,
    Float32List outTensor,
    bool isFrontCamera,
    int sensorOrientation,
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
    final vPixelStride = vPlane.bytesPerPixel ?? uvPixelStride;

    int tensorIdx = 0;

    for (int y = 0; y < targetHeight; y++) {
      final double v = y / (targetHeight - 1);

      for (int x = 0; x < targetWidth; x++) {
        double u = x / (targetWidth - 1);
        if (isFrontCamera) {
          u = 1.0 - u;
        }

        // Map screen coordinates (u, v) to sensor coordinates (nx, ny)
        double nx, ny;
        switch (sensorOrientation) {
          case 90:
            nx = v;
            ny = 1.0 - u;
            break;
          case 270:
            nx = 1.0 - v;
            ny = u;
            break;
          case 180:
            nx = 1.0 - u;
            ny = 1.0 - v;
            break;
          case 0:
          default:
            nx = u;
            ny = v;
            break;
        }

        final srcX = (startX + nx * (cropSize - 1)).toInt().clamp(0, srcWidth - 1);
        final srcY = (startY + ny * (cropSize - 1)).toInt().clamp(0, srcHeight - 1);

        final yIdx = srcY * yRowStride + srcX;
        final uvCol = (srcX >> 1);
        final uvRow = (srcY >> 1);
        final uIdx = uvRow * uRowStride + uvCol * uvPixelStride;
        final vIdx = uvRow * vRowStride + uvCol * vPixelStride;

        final yVal = (yIdx >= 0 && yIdx < yBytes.length) ? yBytes[yIdx] : 128;
        final uVal = (uIdx >= 0 && uIdx < uBytes.length) ? uBytes[uIdx] : 128;
        final vVal = (vIdx >= 0 && vIdx < vBytes.length) ? vBytes[vIdx] : 128;

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
    int sensorOrientation,
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
      final double v = y / (targetHeight - 1);

      for (int x = 0; x < targetWidth; x++) {
        double u = x / (targetWidth - 1);
        if (isFrontCamera) {
          u = 1.0 - u;
        }

        double nx, ny;
        switch (sensorOrientation) {
          case 90:
            nx = v;
            ny = 1.0 - u;
            break;
          case 270:
            nx = 1.0 - v;
            ny = u;
            break;
          case 180:
            nx = 1.0 - u;
            ny = 1.0 - v;
            break;
          case 0:
          default:
            nx = u;
            ny = v;
            break;
        }

        final srcX = (startX + nx * (cropSize - 1)).toInt().clamp(0, srcWidth - 1);
        final srcY = (startY + ny * (cropSize - 1)).toInt().clamp(0, srcHeight - 1);
        final pixelOffset = srcY * bytesPerRow + (srcX * 4);

        final b = (pixelOffset >= 0 && pixelOffset < bytes.length) ? bytes[pixelOffset] : 128;
        final g = (pixelOffset + 1 >= 0 && pixelOffset + 1 < bytes.length) ? bytes[pixelOffset + 1] : 128;
        final r = (pixelOffset + 2 >= 0 && pixelOffset + 2 < bytes.length) ? bytes[pixelOffset + 2] : 128;

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
        final val = (rowOffset + srcX >= 0 && rowOffset + srcX < bytes.length)
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
