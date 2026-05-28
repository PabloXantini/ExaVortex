import 'package:exa_vortex/plx/geometry/2d/rect.dart';
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

BoundRect calculateBounds(Iterable<SpriteQuad> quads) {
  if (quads.isEmpty) return const BoundRect(left: 0, right: 0, top: 0, bottom: 0);
  double minX = double.infinity;
  double maxX = double.negativeInfinity;
  double minY = double.infinity;
  double maxY = double.negativeInfinity;

  for (final q in quads) {
    if (q.tlPosition.x < minX) minX = q.tlPosition.x;
    if (q.brPosition.x > maxX) maxX = q.brPosition.x;
    if (q.tlPosition.y > maxY) maxY = q.tlPosition.y;
    if (q.brPosition.y < minY) minY = q.brPosition.y;
  }
  return BoundRect(left: minX, right: maxX, top: maxY, bottom: minY);
}