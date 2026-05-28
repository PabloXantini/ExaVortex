import 'dart:math' as math;
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'collider_2d.dart';

class PolygonCollider extends Collider2D {
  final List<Vector2> localVertices;

  PolygonCollider({
    required this.localVertices,
    super.position,
    super.velocity,
    super.rotation = 0.0,
    super.angularVelocity = 0.0,
    super.mass = 1.0,
    super.restitution = 0.5,
    super.isStatic = false,
  });

  /// Factory for a simple rectangle (OBB)
  factory PolygonCollider.box({
    required double width,
    required double height,
    Vector2? position,
    double rotation = 0.0,
    bool isStatic = false,
  }) {
    final hw = width / 2.0;
    final hh = height / 2.0;
    return PolygonCollider(
      localVertices: [
        Vector2(-hw, -hh),
        Vector2(hw, -hh),
        Vector2(hw, hh),
        Vector2(-hw, hh),
      ],
      position: position,
      rotation: rotation,
      isStatic: isStatic,
    );
  }

  /// Calculates world vertices based on position and rotation
  List<Vector2> get worldVertices {
    final cosR = math.cos(rotation);
    final sinR = math.sin(rotation);

    return localVertices.map((v) {
      final rotatedX = v.x * cosR - v.y * sinR;
      final rotatedY = v.x * sinR + v.y * cosR;
      return Vector2(rotatedX + position.x, rotatedY + position.y);
    }).toList();
  }

  @override
  Aabb2 get aabb {
    final vertices = worldVertices;
    if (vertices.isEmpty) return Aabb2();

    double minX = vertices[0].x;
    double maxX = vertices[0].x;
    double minY = vertices[0].y;
    double maxY = vertices[0].y;

    for (int i = 1; i < vertices.length; i++) {
      final v = vertices[i];
      if (v.x < minX) minX = v.x;
      if (v.x > maxX) maxX = v.x;
      if (v.y < minY) minY = v.y;
      if (v.y > maxY) maxY = v.y;
    }
    return Aabb2.minMax(Vector2(minX, minY), Vector2(maxX, maxY));
  }

  @override
  List<Vector2> getAxes() {
    final axes = <Vector2>[];
    final vertices = worldVertices;

    for (int i = 0; i < vertices.length; i++) {
      final p1 = vertices[i];
      final p2 = vertices[(i + 1) % vertices.length];
      
      final edge = p2 - p1;
      // Normal is perpendicular to the edge
      final normal = Vector2(-edge.y, edge.x)..normalize();
      axes.add(normal);
    }
    return axes;
  }

  @override
  Vector2 project(Vector2 axis) {
    final vertices = worldVertices;
    if (vertices.isEmpty) return Vector2.zero();

    double min = vertices[0].dot(axis);
    double max = min;

    for (int i = 1; i < vertices.length; i++) {
      double p = vertices[i].dot(axis);
      if (p < min) min = p;
      if (p > max) max = p;
    }

    return Vector2(min, max);
  }
}
