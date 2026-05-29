import 'dart:math';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx3d.dart';

class CenterShape extends Entity3D {
  final int sides;
  final double radius;
  final Vector4 fillColor;   // single solid fill — matches background dark tone
  final Vector4 borderColor; // border matches the wall/obstacle color

  CenterShape({
    super.name = 'Center',
    required this.sides,
    this.radius = 0.5,
    required this.fillColor,
    required this.borderColor,
  }) {
    _generateMesh();
  }

  void _generateMesh() {
    final format = VertexFormat('CenterFormat', [
      const VertexAttribute(AttributeUsage.position, 3),
      const VertexAttribute(AttributeUsage.uv, 2),
      const VertexAttribute(AttributeUsage.color, 4),
    ]);

    final List<double> vertexData = [];
    final double angleStep = 2 * pi / sides;
    const double borderThickness = 0.05;

    // Z layers: bg=0.0, walls=0.01, center fill=0.02, center border=0.03, player=0.04
    const double fillZ = 0.02;
    const double borderZ = 0.03;

    for (int i = 0; i < sides; i++) {
      final a1 = i * angleStep;
      final a2 = (i + 1) * angleStep;

      // --- Solid fill fan from center ---
      final fv1 = Vector3(radius * cos(a1), radius * sin(a1), fillZ);
      final fv2 = Vector3(radius * cos(a2), radius * sin(a2), fillZ);

      Vertex.add(vertexData, Vector3(0, 0, fillZ), Vector2(0.5, 0.5), fillColor);
      Vertex.add(vertexData, fv1, Vector2(0.5 + 0.5 * cos(a1), 0.5 + 0.5 * sin(a1)), fillColor);
      Vertex.add(vertexData, fv2, Vector2(0.5 + 0.5 * cos(a2), 0.5 + 0.5 * sin(a2)), fillColor);

      // --- Border quad along each edge (same color as walls) ---
      final ov1 = Vector3(radius * cos(a1), radius * sin(a1), borderZ);
      final ov2 = Vector3(radius * cos(a2), radius * sin(a2), borderZ);
      final iv1 = Vector3((radius - borderThickness) * cos(a1), (radius - borderThickness) * sin(a1), borderZ);
      final iv2 = Vector3((radius - borderThickness) * cos(a2), (radius - borderThickness) * sin(a2), borderZ);

      // Triangle 1
      Vertex.add(vertexData, ov1, Vector2(0, 0), borderColor);
      Vertex.add(vertexData, ov2, Vector2(1, 0), borderColor);
      Vertex.add(vertexData, iv1, Vector2(0, 1), borderColor);
      // Triangle 2
      Vertex.add(vertexData, iv1, Vector2(0, 1), borderColor);
      Vertex.add(vertexData, ov2, Vector2(1, 0), borderColor);
      Vertex.add(vertexData, iv2, Vector2(1, 1), borderColor);
    }

    final model = PlxGraphics.instance.createMesh(format, vertexData);
    addComponent(MeshComponent(model));
  }
}
