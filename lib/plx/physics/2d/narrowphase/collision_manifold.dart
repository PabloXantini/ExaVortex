import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/physics/2d/colliders/collider_2d.dart';

class CollisionManifold {
  final Collider2D a;
  final Collider2D b;
  
  /// Normal points from A to B
  final Vector2 normal;
  
  /// The depth of penetration
  final double penetrationDepth;
  
  /// The exact points of contact (vertices or points on edges)
  final List<Vector2> contactPoints;
  
  /// The Time Of Impact. 0 for discrete collision, > 0 for predictive CCD
  final double timeOfImpact;

  CollisionManifold({
    required this.a,
    required this.b,
    required this.normal,
    required this.penetrationDepth,
    required this.contactPoints,
    this.timeOfImpact = 0.0,
  });

  /// Helper to get the total mass of the collision pair
  double get inverseMassSum => a.inverseMass + b.inverseMass;
}
