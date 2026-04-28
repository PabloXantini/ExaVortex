import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'type_adapter.dart';

class GfxTexture {
  final gpu.Texture gpuTexture;

  GfxTexture._(this.gpuTexture);

  /// Creates a texture from a list of pixels32.
  static GfxTexture fromPixels(int width, int height, List<int> pixels32) {
    final texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible, width, height,
        enableShaderReadUsage: true);
    texture.overwrite(uint32(pixels32));
    return GfxTexture._(texture);
  }

  /// Loads a texture from an asset path.
  static Future<GfxTexture> fromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Codec codec = await instantiateImageCodec(data.buffer.asUint8List());
    final FrameInfo fi = await codec.getNextFrame();
    return fromImage(fi.image);
  }

  /// Creates a texture from a ui.Image.
  static Future<GfxTexture> fromImage(Image image) async {
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
    return GfxTexture._(texture);
  }
}
