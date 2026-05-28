import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';
import 'primitives/mesh.dart';
import 'material/material.dart';

abstract class PlxRenderer {
  Size get size;
  Matrix4 viewProjectionMatrix = Matrix4.identity();
  void setBackgroundColor(Vector4 color);
  void beginFrame(Size size);
  void submit(
    PlxMesh mesh,
    PlxMaterial material, {
    bool opaque = true,
    double depth = 0.0,
    MaterialInstance? instance,
  });
  Image endFrame();
  void dispose();
}
