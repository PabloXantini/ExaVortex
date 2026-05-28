import 'package:exa_vortex/plx/math/plx_math.dart';
import 'collider_2d.dart';

class CircleCollider extends Collider2D {
  final double radius;

  CircleCollider({
    required this.radius,
    super.position,
    super.velocity,
    super.rotation = 0.0,
    super.angularVelocity = 0.0,
    super.mass = 1.0,
    super.restitution = 0.5,
    super.isStatic = false,
  });

  @override
  Aabb2 get aabb {
    return Aabb2.minMax(
      Vector2(position.x - radius, position.y - radius),
      Vector2(position.x + radius, position.y + radius),
    );
  }

  @override
  List<Vector2> getAxes() {
    // A circle has infinite axes. For SAT against another circle, the axis is the line between centers.
    // For SAT against a polygon, the axis is from the closest polygon vertex to the circle's center.
    // This is handled in the SATSolver. This method returns an empty list for circles inherently.
    return [];
  }

  @override
  Vector2 project(Vector2 axis) {
    // Projection of a circle onto an axis is a segment centered at the projection
    // of the center point, with a length of 2 * radius.
    double centerProj = position.dot(axis);
    return Vector2(centerProj - radius, centerProj + radius);
  }
}
