import 'dart:math';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx3d.dart';

/// Player cursor entity. Holds a CircleCollider positioned at the edge
/// of the center hexagon, synced each frame from the game-logic angle.
class ArrowPlayer extends Entity3D {
  // Distance from center where the player base sits (just outside center hexagon)
  static const double orbitRadius = 0.58;

  // Radius of the collision circle (matches the visual cursor tip width)
  static const double colliderRadius = 0.035;

  late CircleCollider collider;
  Vector4 color; // matches the wall/obstacle color

  ArrowPlayer({
    super.name = 'ArrowPlayer',
    Vector4? color,
  }) : color = color ?? Vector4(0.0, 0.5, 1.0, 1.0) {
    collider = CircleCollider(
      radius: colliderRadius,
      isStatic: true,
    );
    _generateMesh();
  }

  /// Syncs collider + entity position & rotation transform. Pass the current level's obstacle color.
  void syncCollider(double playerAngle, {Vector4? playerColor}) {
    if (playerColor != null && playerColor != color) {
      color = playerColor;
      _generateMesh(); // rebuild mesh only if color changes
    }
    
    // 1. Position collider in background local space
    collider.position = Vector2(
      orbitRadius * cos(playerAngle),
      orbitRadius * sin(playerAngle),
    );

    // 2. Position and rotate entity using standard scene graph transform
    position = Vector3(
      orbitRadius * cos(playerAngle),
      orbitRadius * sin(playerAngle),
      0.0,
    );
    rotation.z = playerAngle;
    transform.dirty = true;
  }

  void _generateMesh() {
    final format = VertexFormat('PlayerFormat', [
      const VertexAttribute(AttributeUsage.position, 3),
      const VertexAttribute(AttributeUsage.uv, 2),
      const VertexAttribute(AttributeUsage.color, 4),
    ]);

    final List<double> vertexData = [];
    final double playerSize = 0.06;
    final double playerHalfWidth = 0.045; // half width of base

    // Local coordinates: base is at X=0, tip points outward along positive X-axis (Z=0.04 — on top of everything)
    final pLeft = Vector3(0.0, -playerHalfWidth, 0.04);
    final pRight = Vector3(0.0, playerHalfWidth, 0.04);
    final pTip = Vector3(playerSize, 0.0, 0.04);

    Vertex.add(vertexData, pLeft,  Vector2(0, 1), color);
    Vertex.add(vertexData, pRight, Vector2(1, 1), color);
    Vertex.add(vertexData, pTip,   Vector2(0.5, 0), color);

    final model = PlxGraphics.instance.createMesh(format, vertexData);
    
    var meshComp = getComponent<MeshComponent>();
    if (meshComp == null) {
      addComponent(MeshComponent(model));
    } else {
      meshComp.mesh = model;
    }
  }
}
