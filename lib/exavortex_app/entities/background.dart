import 'package:exagon_plus/exavortex_app/utils/shapes/polygons.dart';
import 'package:exagon_plus/plx_flutter/plx3d.dart';
import 'package:vector_math/vector_math_64.dart';

class Background extends Entity3D {
  late Mesh model;
  late RegularPolygon2D skeleton;
  late List<Vector4> colorPalette;

  Background({
    super.name = 'Background',
    int numSides = 6,
    double radius = 5.0,
    this.vertexColoring = 3,
  }) {
    colorPalette = [
      Vector4(0.1, 0.1, 0.15, 1.0), // Cycle color A
      Vector4(0.15, 0.15, 0.2, 1.0), // Cycle color B
      Vector4(0.2, 0.05, 0.05, 1.0), // Special color
    ];

    skeleton = RegularPolygon2D(numvertices: numSides, radius: radius);
    _generateMesh();
  }

  final int vertexColoring;

  void _generateMesh() {
    // Vertex Format: vec3 position, vec2 uv, vec4 color
    final format = VertexFormat('BackgroundFormat', [
      const VertexAttribute(AttributeUsage.position, 3),
      const VertexAttribute(AttributeUsage.uv, 2),
      const VertexAttribute(AttributeUsage.color, 4),
    ]);

    final List<double> vertexData = [];
    final List<Vector2> polyVertices = skeleton.vertices ?? [];
    final int n = skeleton.vnum;

    if (polyVertices.isEmpty) return;

    int vertexCounter = 0;
    for (int i = 0; i < n; i++) {
      final v1 = polyVertices[i];
      final v2 = polyVertices[(i + 1) % n];

      // Triangulate: Center (0,0,0) -> v1 -> v2
      final triangleVertices = [
        Vector3(0.0, 0.0, 0.0),
        Vector3(v1.x, v1.y, 0.0),
        Vector3(v2.x, v2.y, 0.0),
      ];

      for (var pos in triangleVertices) {
        // Determine color based on vertex count
        int colorIndex;
        // The parity rule is applied based on which triangle we are in (i)
        // but we now pick a color for every vertex.
        if (n % 2 == 0) {
          colorIndex = (vertexCounter ~/ vertexColoring) % (colorPalette.length - 1);
        } else {
          // If odd, we still want to use the last color for the last "segment"
          // We'll define the segment as the last triangle's vertices.
          if (i == n - 1) {
            colorIndex = colorPalette.length - 1;
          } else {
            colorIndex = (vertexCounter ~/ vertexColoring) % (colorPalette.length - 1);
          }
        }
        
        final color = colorPalette[colorIndex];
        
        vertexData.addAll([pos.x, pos.y, pos.z]); // pos
        vertexData.addAll([0.0, 0.0]);            // uv
        vertexData.addAll([color.x, color.y, color.z, color.w]); // col
        
        vertexCounter++;
      }
    }

    model = Mesh.create(format, vertexData);

    // Attach renderer component
    final renderer = MeshRenderer(mesh: model);
    final material1 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material1.setTexture('tex', GfxTexture.fromPixels(1, 1, [0xFFFFFFFF]));
    renderer.material = material1;
    addComponent(renderer);
  }
}
