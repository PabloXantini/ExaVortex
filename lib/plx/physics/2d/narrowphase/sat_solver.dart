import 'dart:math' as math;
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/physics/2d/colliders/collider_2d.dart';
import 'package:exa_vortex/plx/physics/2d/colliders/circle_collider.dart';
import 'package:exa_vortex/plx/physics/2d/colliders/polygon_collider.dart';
import 'package:exa_vortex/plx/physics/2d/narrowphase/collision_manifold.dart';

class SATSolver {
  
  /// Performs SAT collision detection.
  /// If [dt] is provided and > 0, it performs Continuous Collision Detection (Swept SAT)
  static CollisionManifold? test(Collider2D a, Collider2D b, {double dt = 0.0}) {
    if (a is PolygonCollider && b is PolygonCollider) {
      return _testPolygonPolygon(a, b, dt: dt);
    } else if (a is PolygonCollider && b is CircleCollider) {
      return _testPolygonCircle(a, b, dt: dt);
    } else if (a is CircleCollider && b is PolygonCollider) {
      final manifold = _testPolygonCircle(b, a, dt: dt);
      if (manifold != null) {
        // Flip normal if we swapped order
        return CollisionManifold(
          a: a,
          b: b,
          normal: -manifold.normal,
          penetrationDepth: manifold.penetrationDepth,
          contactPoints: manifold.contactPoints,
          timeOfImpact: manifold.timeOfImpact,
        );
      }
      return null;
    } else if (a is CircleCollider && b is CircleCollider) {
      return _testCircleCircle(a, b, dt: dt);
    }
    return null;
  }

  static CollisionManifold? _testPolygonPolygon(PolygonCollider a, PolygonCollider b, {double dt = 0.0}) {
    double minOverlap = double.infinity;
    Vector2? smallestAxis;

    final axes = <Vector2>[...a.getAxes(), ...b.getAxes()];
    
    // For swept SAT
    double tFirst = 0.0;
    double tLast = dt > 0 ? 1.0 : 0.0;
    Vector2 relativeVelocity = (b.velocity - a.velocity) * dt;

    for (final axis in axes) {
      final projA = a.project(axis);
      final projB = b.project(axis);

      double minA = projA.x;
      double maxA = projA.y;
      double minB = projB.x;
      double maxB = projB.y;

      if (dt > 0.0) {
        // Swept SAT logic for CCD
        double speed = relativeVelocity.dot(axis);
        
        if (speed < 0) {
          if (maxA < minB) return null; // moving apart
          if (maxB < minA) {
            double t = (minA - maxB) / speed;
            if (t > tFirst) tFirst = t;
            double t2 = (maxA - minB) / speed;
            if (t2 < tLast) tLast = t2;
          }
        } else if (speed > 0) {
          if (maxB < minA) return null; // moving apart
          if (maxA < minB) {
            double t = (minB - maxA) / speed;
            if (t > tFirst) tFirst = t;
            double t2 = (maxB - minA) / speed;
            if (t2 < tLast) tLast = t2;
          }
        } else {
           if (maxA < minB || maxB < minA) return null; // No overlap, not moving on this axis
        }
        
        if (tFirst > tLast || tFirst > 1.0) return null;
      } else {
        // Discrete SAT
        if (maxA < minB || maxB < minA) {
          return null; // Separating axis found
        }
      }

      // Calculate overlap for discrete resolution
      double overlap = math.min(maxA, maxB) - math.max(minA, minB);
      if (overlap < minOverlap) {
        minOverlap = overlap;
        smallestAxis = axis;
        
        // Ensure normal always points from A to B
        final d = b.position - a.position;
        if (d.dot(smallestAxis) < 0) {
          smallestAxis = -smallestAxis;
        }
      }
    }

    if (smallestAxis == null) return null;

    // Contact point extraction for Polygons
    List<Vector2> contacts = _findPolygonContactPoints(a, b, smallestAxis);

    return CollisionManifold(
      a: a,
      b: b,
      normal: smallestAxis,
      penetrationDepth: minOverlap,
      contactPoints: contacts,
      timeOfImpact: tFirst,
    );
  }

  static CollisionManifold? _testPolygonCircle(PolygonCollider a, CircleCollider b, {double dt = 0.0}) {
    double minOverlap = double.infinity;
    Vector2? smallestAxis;

    final axes = a.getAxes();
    
    // Add axis from closest polygon vertex to circle center
    Vector2 closestVertex = a.worldVertices[0];
    double minDistanceSq = (closestVertex - b.position).length2;
    for (int i = 1; i < a.worldVertices.length; i++) {
      final distSq = (a.worldVertices[i] - b.position).length2;
      if (distSq < minDistanceSq) {
        minDistanceSq = distSq;
        closestVertex = a.worldVertices[i];
      }
    }
    
    final circleAxis = (b.position - closestVertex);
    if (circleAxis.length2 > 0) {
      axes.add(circleAxis.normalized());
    }

    double tFirst = 0.0;
    double tLast = dt > 0 ? 1.0 : 0.0;
    Vector2 relativeVelocity = (b.velocity - a.velocity) * dt;

    for (final axis in axes) {
      final projA = a.project(axis);
      final projB = b.project(axis);

      double minA = projA.x;
      double maxA = projA.y;
      double minB = projB.x;
      double maxB = projB.y;

      if (dt > 0.0) {
        // Swept logic
        double speed = relativeVelocity.dot(axis);
        if (speed < 0) {
          if (maxA < minB) return null; 
          if (maxB < minA) {
            double t = (minA - maxB) / speed;
            if (t > tFirst) tFirst = t;
            double t2 = (maxA - minB) / speed;
            if (t2 < tLast) tLast = t2;
          }
        } else if (speed > 0) {
          if (maxB < minA) return null; 
          if (maxA < minB) {
            double t = (minB - maxA) / speed;
            if (t > tFirst) tFirst = t;
            double t2 = (maxB - minA) / speed;
            if (t2 < tLast) tLast = t2;
          }
        } else {
           if (maxA < minB || maxB < minA) return null;
        }
        if (tFirst > tLast || tFirst > 1.0) return null;
      } else {
        if (maxA < minB || maxB < minA) return null;
      }

      double overlap = math.min(maxA, maxB) - math.max(minA, minB);
      if (overlap < minOverlap) {
        minOverlap = overlap;
        smallestAxis = axis;
        
        final d = b.position - a.position;
        if (d.dot(smallestAxis) < 0) {
          smallestAxis = -smallestAxis;
        }
      }
    }

    if (smallestAxis == null) return null;

    // Contact point is essentially circle center moved towards polygon by radius
    Vector2 contactPoint = b.position - (smallestAxis * b.radius);

    return CollisionManifold(
      a: a,
      b: b,
      normal: smallestAxis,
      penetrationDepth: minOverlap,
      contactPoints: [contactPoint],
      timeOfImpact: tFirst,
    );
  }

  static CollisionManifold? _testCircleCircle(CircleCollider a, CircleCollider b, {double dt = 0.0}) {
    Vector2 d = b.position - a.position;
    double distSq = d.length2;
    double radiiSum = a.radius + b.radius;

    double tFirst = 0.0;

    if (dt > 0.0) {
      // Swept Circle vs Circle (Raycast against expanded circle)
      Vector2 rv = (b.velocity - a.velocity) * dt;
      
      // Quadratic equation for moving circle intersection
      double aC = rv.length2;
      double bC = 2 * d.dot(rv);
      double cC = distSq - radiiSum * radiiSum;

      if (cC < 0) {
        // Already overlapping
        tFirst = 0.0;
      } else if (aC > 0) {
        double discriminant = bC * bC - 4 * aC * cC;
        if (discriminant < 0) return null; // No collision

        double t = (-bC - math.sqrt(discriminant)) / (2 * aC);
        if (t < 0 || t > 1) return null;
        tFirst = t;
      } else {
        return null;
      }
      
      // Move objects to TOI to get correct normal and overlap
      Vector2 posA = a.position + (a.velocity * (dt * tFirst));
      Vector2 posB = b.position + (b.velocity * (dt * tFirst));
      d = posB - posA;
      distSq = d.length2;
    } else {
      if (distSq >= radiiSum * radiiSum) {
        return null; // Not colliding
      }
    }

    double dist = math.sqrt(distSq);
    Vector2 normal;
    if (dist == 0) {
      normal = Vector2(1, 0); // Arbitrary normal if same position
      dist = 0.001; // Avoid divide by zero
    } else {
      normal = d / dist;
    }

    double penetration = radiiSum - dist;
    Vector2 contactPoint = a.position + (normal * a.radius);

    return CollisionManifold(
      a: a,
      b: b,
      normal: normal,
      penetrationDepth: penetration,
      contactPoints: [contactPoint],
      timeOfImpact: tFirst,
    );
  }

  /// Finds the contact points between two convex polygons based on the collision normal
  static List<Vector2> _findPolygonContactPoints(PolygonCollider a, PolygonCollider b, Vector2 normal) {
    // 1. Find the reference and incident faces
    var faceA = _getBestFace(a, normal);
    var faceB = _getBestFace(b, -normal);
    
    List<Vector2> refFace;
    List<Vector2> incFace;
    bool flipped = false;

    // Reference face is the most orthogonal to the normal
    if (faceA.normal.dot(normal).abs() <= faceB.normal.dot(normal).abs()) {
      refFace = faceA.vertices;
      incFace = faceB.vertices;
    } else {
      refFace = faceB.vertices;
      incFace = faceA.vertices;
      flipped = true;
    }

    // 2. Clip incident face against adjacent planes of reference face (Sutherland-Hodgman)
    Vector2 refv1 = refFace[0];
    Vector2 refv2 = refFace[1];
    Vector2 refDir = (refv2 - refv1).normalized();
    
    // First clip
    double o1 = refDir.dot(refv1);
    List<Vector2> cp = _clip(incFace[0], incFace[1], refDir, o1);
    if (cp.length < 2) return cp;

    // Second clip
    double o2 = -refDir.dot(refv2);
    cp = _clip(cp[0], cp[1], -refDir, o2);
    if (cp.length < 2) return cp;

    // 3. Keep points that are below the reference face
    Vector2 refNormal = flipped ? normal : -normal;
    double maxDepth = refNormal.dot(refv1);
    
    List<Vector2> finalContacts = [];
    for (var p in cp) {
      double depth = refNormal.dot(p) - maxDepth;
      if (depth >= 0) { // Point is penetrating
        finalContacts.add(p);
      }
    }
    
    // Fallback if clipping failed
    if (finalContacts.isEmpty && cp.isNotEmpty) {
      finalContacts.add(cp[0]);
    }

    return finalContacts;
  }

  static _Face _getBestFace(PolygonCollider poly, Vector2 direction) {
    final vertices = poly.worldVertices;
    double maxDot = -double.infinity;
    int index = 0;

    for (int i = 0; i < vertices.length; i++) {
      double d = vertices[i].dot(direction);
      if (d > maxDot) {
        maxDot = d;
        index = i;
      }
    }

    Vector2 v = vertices[index];
    Vector2 v1 = vertices[(index - 1 + vertices.length) % vertices.length];
    Vector2 v2 = vertices[(index + 1) % vertices.length];

    Vector2 leftEdge = (v - v1).normalized();
    Vector2 rightEdge = (v - v2).normalized();
    
    if (leftEdge.dot(direction) <= rightEdge.dot(direction)) {
      Vector2 normal = Vector2(-leftEdge.y, leftEdge.x); // Assuming CCW winding
      return _Face([v1, v], normal);
    } else {
      Vector2 normal = Vector2(-rightEdge.y, rightEdge.x);
      return _Face([v, v2], normal);
    }
  }

  static List<Vector2> _clip(Vector2 v1, Vector2 v2, Vector2 n, double o) {
    List<Vector2> cp = [];
    double d1 = n.dot(v1) - o;
    double d2 = n.dot(v2) - o;

    if (d1 >= 0.0) cp.add(v1);
    if (d2 >= 0.0) cp.add(v2);

    if (d1 * d2 < 0.0) {
      Vector2 e = v2 - v1;
      double u = d1 / (d1 - d2);
      e.scale(u);
      e.add(v1);
      cp.add(e);
    }
    return cp;
  }
}

class _Face {
  final List<Vector2> vertices;
  final Vector2 normal;
  _Face(this.vertices, this.normal);
}
