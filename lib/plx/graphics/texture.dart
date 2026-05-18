import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'type_adapter.dart';

class PlxTexture {
  final gpu.Texture gpuTexture;

  PlxTexture._(this.gpuTexture);

  /// Creates a texture from a list of pixels32.
  static PlxTexture fromPixels(int width, int height, List<int> pixels32) {
    final texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible, width, height,
        enableShaderReadUsage: true);
    texture.overwrite(uint32(pixels32));
    return PlxTexture._(texture);
  }

  /// Creates a texture from raw bytes (RGBA).
  static PlxTexture fromBytes(int width, int height, ByteData bytes) {
    final texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible, width, height,
        enableShaderReadUsage: true);
    texture.overwrite(bytes);
    return PlxTexture._(texture);
  }

  /// Loads a texture from an asset path.
  static Future<PlxTexture> fromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Codec codec = await instantiateImageCodec(data.buffer.asUint8List());
    final FrameInfo fi = await codec.getNextFrame();
    final texture = await fromImage(fi.image);
    fi.image.dispose();
    return texture;
  }

  /// Creates a texture from a ui.Image.
  static Future<PlxTexture> fromImage(Image image) async {
    final ByteData? bytes = await image.toByteData(format: ImageByteFormat.rawRgba);
    if (bytes == null) {
      throw Exception('GfxTexture: Failed to get byte data from image');
    }
    final texture = gpu.gpuContext.createTexture(
      gpu.StorageMode.hostVisible,
      image.width,
      image.height,
      enableShaderReadUsage: true,
    );
    texture.overwrite(bytes);
    return PlxTexture._(texture);
  }
}
