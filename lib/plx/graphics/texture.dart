import 'package:flutter_gpu/gpu.dart' as gpu;
import 'type_adapter.dart';

class GfxTexture {
  final gpu.Texture gpuTexture;

  GfxTexture._(this.gpuTexture);

  /// creates a texture from a list of pixels32, this is the slower way to create a texture but it is the most flexible
  static GfxTexture fromPixels(int width, int height, List<int> pixels32) {
    final texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible, width, height,
        enableShaderReadUsage: true);
    texture.overwrite(uint32(pixels32));
    return GfxTexture._(texture);
  }

  // TODO: Implement fromAsset(String path) or fromImage(ui.Image image) in the future.
}
