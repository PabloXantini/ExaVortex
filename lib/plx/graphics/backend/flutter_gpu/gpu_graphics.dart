import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import '../../graphics.dart';
import '../../primitives/mesh.dart';
import '../../material/material.dart';
import '../../material/texture.dart';
import '../../renderer.dart';
import '../../utils/type_adapter.dart';
import 'gpu_renderer.dart';
import 'gpu_mesh.dart';
import 'gpu_material.dart';
import 'gpu_texture.dart';

class GpuGraphics implements PlxGraphics {
  @override
  PlxRenderer createRenderer() {
    return GpuRenderer();
  }

  @override
  PlxMesh createMesh(VertexFormat format, List<double> interleavedVertices, {List<int>? indices16, List<int>? indices32}) {
    assert(interleavedVertices.length % format.stride == 0,
        "The length of interleavedVertices must be a multiple of the stride (${format.stride})");
    int vertexCount = interleavedVertices.length ~/ format.stride;

    ByteData vertexData = float32(interleavedVertices);
    gpu.DeviceBuffer vertexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(vertexData);

    gpu.DeviceBuffer? indexBuffer;
    gpu.IndexType indexType = gpu.IndexType.int16;
    int indexCount = 0;

    if (indices16 != null) {
      indexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(uint16(indices16));
      indexType = gpu.IndexType.int16;
      indexCount = indices16.length;
    } else if (indices32 != null) {
      indexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(uint32(indices32));
      indexType = gpu.IndexType.int32;
      indexCount = indices32.length;
    }

    return GpuMesh(
      vertexBuffer: vertexBuffer,
      vertexCount: vertexCount,
      indexBuffer: indexBuffer,
      indexType: indexType,
      indexCount: indexCount,
    );
  }

  @override
  PlxMaterial createMaterial({required String vertexShaderName, required String fragmentShaderName}) {
    return GpuMaterial(
      vertexShaderName: vertexShaderName,
      fragmentShaderName: fragmentShaderName,
    );
  }

  @override
  PlxTexture createTextureFromBytes(int width, int height, ByteData bytes) {
    final texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible, width, height,
        enableShaderReadUsage: true);
    texture.overwrite(bytes);
    return GpuTexture(texture);
  }

  @override
  PlxTexture createTextureFromPixels(int width, int height, List<int> pixels32) {
    final texture = gpu.gpuContext.createTexture(
        gpu.StorageMode.hostVisible, width, height,
        enableShaderReadUsage: true);
    texture.overwrite(uint32(pixels32));
    return GpuTexture(texture);
  }

  @override
  Future<PlxTexture> createTextureFromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Codec codec = await instantiateImageCodec(data.buffer.asUint8List());
    final FrameInfo fi = await codec.getNextFrame();
    final texture = await createTextureFromImage(fi.image);
    fi.image.dispose();
    return texture;
  }

  @override
  Future<PlxTexture> createTextureFromImage(Image image) async {
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
    return GpuTexture(texture);
  }
}
