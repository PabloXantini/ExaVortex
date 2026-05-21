import 'package:vector_math/vector_math_64.dart';

class SpriteQuad {
  final Vector2 tlPosition;
  final Vector2 brPosition;
  final double z;
  final Vector2 uv0, uv1, uv2, uv3;
  const SpriteQuad({
    required this.tlPosition,
    required this.brPosition,
    required this.z,
    required this.uv0, required this.uv1,
    required this.uv2, required this.uv3,
  });
}