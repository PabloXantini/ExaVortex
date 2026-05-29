import 'dart:math';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx3d.dart';
import '../utils/level_vm.dart';

/// Wall obstacle entity. Holds a PolygonCollider shaped as the trapezoidal
/// arc-segment of one hexagon side. Synced each frame from the LevelVM's ActiveWall.
class WallShape extends Entity3D {
  late PolygonCollider collider;
  int sides = 6;
  Vector4 obstacleColor = Vector4(1, 1, 1, 1);

  WallShape({super.name = 'Wall'}) {
    // Initialize with dummy vertices — will be rebuilt before first SAT test.
    collider = PolygonCollider(
      localVertices: [
        Vector2.zero(),
        Vector2.zero(),
        Vector2.zero(),
        Vector2.zero(),
      ],
      isStatic: true,
    );
  }

  /// Rebuilds the polygon collider to match the current arc position of [aw].
  ///
  /// The 4 vertices are provided in world-space and the collider position
  /// stays at zero/rotation stays at zero, so localVertices == worldVertices.
  /// Winding order is CCW: outerLeft → innerLeft → innerRight → outerRight.
  void syncFromActiveWall(ActiveWall aw, {required int numSides, required Vector4 color}) {
    sides = numSides;
    obstacleColor = color;
    
    final double step = 2 * pi / sides;
    final double a1 = aw.wall.side * step;
    final double a2 = (aw.wall.side + 1) * step;

    final double innerR = aw.distance;
    final double outerR = aw.distance + aw.wall.thickness;

    collider = PolygonCollider(
      localVertices: [
        Vector2(outerR * cos(a1), outerR * sin(a1)), // outer-left
        Vector2(innerR * cos(a1), innerR * sin(a1)), // inner-left
        Vector2(innerR * cos(a2), innerR * sin(a2)), // inner-right
        Vector2(outerR * cos(a2), outerR * sin(a2)), // outer-right
      ],
      isStatic: true,
    );

    _generateMesh(aw);
  }

  void _generateMesh(ActiveWall aw) {
    final format = VertexFormat('WallFormat', [
      const VertexAttribute(AttributeUsage.position, 3),
      const VertexAttribute(AttributeUsage.uv, 2),
      const VertexAttribute(AttributeUsage.color, 4),
    ]);

    final List<double> vertexData = [];
    final double step = 2 * pi / sides;
    final a1 = aw.wall.side * step;
    final a2 = (aw.wall.side + 1) * step;

    final innerR = aw.distance;
    final outerR = aw.distance + aw.wall.thickness;

    // Inner vertices (Z=0.01 — behind center)
    final iv1 = Vector3(innerR * cos(a1), innerR * sin(a1), 0.01);
    final iv2 = Vector3(innerR * cos(a2), innerR * sin(a2), 0.01);

    // Outer vertices
    final ov1 = Vector3(outerR * cos(a1), outerR * sin(a1), 0.01);
    final ov2 = Vector3(outerR * cos(a2), outerR * sin(a2), 0.01);

    // Triangulate Wall Quad: Triangle 1 (ov1 -> ov2 -> iv1)
    Vertex.add(vertexData, ov1, Vector2(0, 0), obstacleColor);
    Vertex.add(vertexData, ov2, Vector2(1, 0), obstacleColor);
    Vertex.add(vertexData, iv1, Vector2(0, 1), obstacleColor);

    // Triangle 2 (iv1 -> ov2 -> iv2)
    Vertex.add(vertexData, iv1, Vector2(0, 1), obstacleColor);
    Vertex.add(vertexData, ov2, Vector2(1, 0), obstacleColor);
    Vertex.add(vertexData, iv2, Vector2(1, 1), obstacleColor);

    final model = PlxGraphics.instance.createMesh(format, vertexData);
    
    var meshComp = getComponent<MeshComponent>();
    if (meshComp == null) {
      addComponent(MeshComponent(model));
    } else {
      meshComp.mesh = model;
    }
  }
}
