import 'package:exa_vortex/plx/math/plx_math.dart';

abstract class Collider2D {
  Vector2 position;
  Vector2 velocity;
  double rotation;
  double angularVelocity;
  
  double mass;
  double restitution;
  bool isStatic;

  /// For broadphase AABB
  Aabb2 get aabb;

  Collider2D({
    Vector2? position,
    Vector2? velocity,
    this.rotation = 0.0,
    this.angularVelocity = 0.0,
    this.mass = 1.0,
    this.restitution = 0.5,
    this.isStatic = false,
  })  : position = position ?? Vector2.zero(),
        velocity = velocity ?? Vector2.zero();

  double get inverseMass => isStatic || mass <= 0.0 ? 0.0 : 1.0 / mass;

  /// Calculates the min and max projection along an axis.
  /// Used for the SAT narrow phase.
  Vector2 project(Vector2 axis);

  /// Get the axes (normals) for SAT testing
  List<Vector2> getAxes();
}
