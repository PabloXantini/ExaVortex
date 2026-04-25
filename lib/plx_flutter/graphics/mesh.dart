import 'dart:typed_data';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'type_adapter.dart';

enum AttributeUsage { position, uv, normal, color, custom }

class VertexAttribute {
  final AttributeUsage usage;
  final int numArgs; // number of floats

  const VertexAttribute(this.usage, this.numArgs);
}

class VertexFormat {
  final String name;
  final List<VertexAttribute> attributes;
  final int stride; // total floats per vertex

  VertexFormat(this.name, this.attributes)
      : stride = attributes.fold(0, (sum, attr) => sum + attr.numArgs);
}

class Mesh {
  final gpu.DeviceBuffer vertexBuffer;
  final gpu.DeviceBuffer? indexBuffer;
  final gpu.IndexType indexType;
  final int vertexCount;
  final int indexCount;

  Mesh({
    required this.vertexBuffer,
    required this.vertexCount,
    this.indexBuffer,
    this.indexType = gpu.IndexType.int16,
    this.indexCount = 0,
  });

  void bindAndDraw(gpu.RenderPass pass) {
    pass.bindVertexBuffer(
        gpu.BufferView(vertexBuffer, offsetInBytes: 0, lengthInBytes: vertexBuffer.sizeInBytes),
        vertexCount);
    if (indexBuffer != null && indexCount > 0) {
      pass.bindIndexBuffer(
          gpu.BufferView(indexBuffer!, offsetInBytes: 0, lengthInBytes: indexBuffer!.sizeInBytes),
          indexType,
          indexCount);
      pass.draw();
    } else {
      pass.draw();
    }
  }

  /// Create a Mesh using a declarative VertexFormat and a raw list of interleaved vertices.
  /// This is much faster as it avoids dictionary lookups per vertex.
  static Mesh create(VertexFormat format, List<double> interleavedVertices,
      {List<int>? indices16, List<int>? indices32}) {
      
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

    return Mesh(
      vertexBuffer: vertexBuffer,
      vertexCount: vertexCount,
      indexBuffer: indexBuffer,
      indexType: indexType,
      indexCount: indexCount,
    );
  }
}

