import 'package:vector_math/vector_math_64.dart';

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

/// Helpers for reusing vertices in different geometries.
class Vertex {
  static void add(List<double> data, Vector3 pos, Vector2 uv, Vector4 color){
    data.addAll([pos.x, pos.y, pos.z]);
    data.addAll([uv.x, uv.y]);
    data.addAll([color.x, color.y, color.z, color.w]);
  }
}
