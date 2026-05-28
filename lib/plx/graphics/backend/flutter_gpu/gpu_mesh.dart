import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:exa_vortex/plx/graphics/primitives/mesh.dart';
import 'package:exa_vortex/plx/graphics/utils/type_adapter.dart';

class GpuMesh implements PlxMesh {
  gpu.DeviceBuffer vertexBuffer;
  gpu.DeviceBuffer? indexBuffer;
  gpu.IndexType indexType;
  int vertexCount;
  int indexCount;
  final int stride;

  GpuMesh({
    required this.vertexBuffer,
    required this.vertexCount,
    required this.stride,
    this.indexBuffer,
    this.indexType = gpu.IndexType.int16,
    this.indexCount = 0,
  });

  @override
  void overwrite(List<double> vertices, {List<int>? indices16, List<int>? indices32}) {
    assert(vertices.length % stride == 0,
        "The length of vertices must be a multiple of the stride ($stride)");
    
    vertexCount = vertices.length ~/ stride;
    vertexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(float32(vertices));

    if (indices16 != null) {
      indexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(uint16(indices16));
      indexType = gpu.IndexType.int16;
      indexCount = indices16.length;
    } else if (indices32 != null) {
      indexBuffer = gpu.gpuContext.createDeviceBufferWithCopy(uint32(indices32));
      indexType = gpu.IndexType.int32;
      indexCount = indices32.length;
    }
  }

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
