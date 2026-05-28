import 'package:flutter_gpu/gpu.dart' as gpu;
import '../../mesh.dart';

class GpuMesh implements PlxMesh {
  final gpu.DeviceBuffer vertexBuffer;
  final gpu.DeviceBuffer? indexBuffer;
  final gpu.IndexType indexType;
  final int vertexCount;
  final int indexCount;

  GpuMesh({
    required this.vertexBuffer,
    required this.vertexCount,
    this.indexBuffer,
    this.indexType = gpu.IndexType.int16,
    this.indexCount = 0,
  });

  void bind(gpu.RenderPass pass) {
    pass.bindVertexBuffer(
      gpu.BufferView(vertexBuffer, offsetInBytes: 0, lengthInBytes: vertexBuffer.sizeInBytes),
      vertexCount
    );
    if (indexBuffer != null && indexCount > 0) {
      pass.bindIndexBuffer(
        gpu.BufferView(indexBuffer!, offsetInBytes: 0, lengthInBytes: indexBuffer!.sizeInBytes),
        indexType,
        indexCount
      );
    }
  }
}
