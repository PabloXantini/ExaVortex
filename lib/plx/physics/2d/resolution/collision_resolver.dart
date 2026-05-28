import 'dart:math' as math;
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/physics/2d/narrowphase/collision_manifold.dart';

class CollisionResolver {
  
  /// Standard Impulse-based velocity resolution
  static void resolveVelocity(CollisionManifold manifold) {
    final a = manifold.a;
    final b = manifold.b;

    // Calculate relative velocity
    Vector2 rv = b.velocity - a.velocity;

    // Calculate relative velocity in terms of the normal direction
    double velAlongNormal = rv.dot(manifold.normal);

    // Do not resolve if velocities are separating
    if (velAlongNormal > 0) return;

    // Calculate restitution (bounciness) - taking the minimum of both objects
    double e = math.min(a.restitution, b.restitution);

    // Calculate impulse scalar
    double j = -(1 + e) * velAlongNormal;
    j /= manifold.inverseMassSum;

    // Apply impulse
    Vector2 impulse = manifold.normal * j;
    
    if (!a.isStatic) {
      a.velocity -= impulse * a.inverseMass;
    }
    if (!b.isStatic) {
      b.velocity += impulse * b.inverseMass;
    }

    // TODO: Implement friction (tangential impulse) here if needed
  }

  /// Linear projection to prevent objects from sinking into each other due to floating point errors
  static void positionalCorrection(CollisionManifold manifold) {
    const double percent = 0.2; // Penetration percentage to correct
    const double slop = 0.01;   // Penetration allowance

    final a = manifold.a;
    final b = manifold.b;

    double depth = math.max(manifold.penetrationDepth - slop, 0.0);
    if (depth == 0.0 || manifold.inverseMassSum == 0.0) return;

    Vector2 correction = (manifold.normal * depth) / manifold.inverseMassSum * percent;

    if (!a.isStatic) {
      a.position -= correction * a.inverseMass;
    }
    if (!b.isStatic) {
      b.position += correction * b.inverseMass;
    }
  }

  /// Resolve speculative contacts (for CCD)
  /// Modifies velocity so objects perfectly reach the point of impact and stop/bounce
  static void resolveSpeculativeContacts(CollisionManifold manifold, double dt) {
    if (manifold.timeOfImpact <= 0.0 || manifold.timeOfImpact > 1.0) return;

    final a = manifold.a;
    final b = manifold.b;

    Vector2 rv = b.velocity - a.velocity;
    double velAlongNormal = rv.dot(manifold.normal);

    // If already moving apart, do nothing
    if (velAlongNormal > 0) return;

    // We want the relative velocity along the normal to be 0 at the time of impact.
    // Calculate the distance they will cover before impact
    double distanceToImpact = manifold.penetrationDepth; // From swept SAT, this is usually 0 if TOI is used correctly
    
    // Instead of full impulse, we remove the velocity that would cause penetration after TOI
    // Speculative contact removes velocity along the contact normal *before* the bodies actually penetrate.
    double remove = velAlongNormal + (distanceToImpact / dt); 
    
    if (remove < 0) {
      double e = math.min(a.restitution, b.restitution);
      double j = -(1 + e) * remove;
      j /= manifold.inverseMassSum;

      Vector2 impulse = manifold.normal * j;
      
      if (!a.isStatic) {
        a.velocity -= impulse * a.inverseMass;
      }
      if (!b.isStatic) {
        b.velocity += impulse * b.inverseMass;
      }
    }
  }
}
