import 'package:vector_math/vector_math_64.dart';

/// Helpers for reusing vertices in different geometries.
class Vertex {
  static void add(List<double> data, Vector3 pos, Vector2 uv, Vector4 color){
    data.addAll([pos.x, pos.y, pos.z]);
    data.addAll([uv.x, uv.y]);
    data.addAll([color.x, color.y, color.z, color.w]);
  }
}
