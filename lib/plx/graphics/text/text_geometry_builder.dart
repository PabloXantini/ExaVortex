import 'package:exa_vortex/plx/graphics/mesh.dart';
import 'package:vector_math/vector_math_64.dart';
import 'plx_font.dart';

class TextGeometryBuilder {
  /// Builds a mesh from the given [text] using textured quads from the font atlas.
  static Mesh buildMesh(String text, PlxFont font, {
    double fontSize = 1.0,
    Vector4? color,
  }) {
    final List<double> vertexData = [];
    final List<int> indices = [];
    int vertexOffset = 0;

    double cursorX = 0.0;
    final Vector4 finalColor = color ?? Vector4(1, 1, 1, 1);

    for (int i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);
      final glyph = font.glyphs[charCode];
      if (glyph == null) {
        if (text[i] == ' ') {
          cursorX += 0.3 * fontSize; // Space advance (approximate if not in atlas)
        }
        continue;
      }

      // Glyph coordinates
      // Note: y is down in dart:ui, we might want to invert it if needed for the scene
      double x0 = cursorX + glyph.left * fontSize;
      double y0 = glyph.top * fontSize;
      double x1 = x0 + glyph.width * fontSize;
      double y1 = y0 + glyph.height * fontSize;
      double z = i * 0.0001;

      // 4 vertices for the quad
      // Top-Left
      _addVertex(vertexData, Vector3(x0, -y0, z), Vector2(glyph.u1, glyph.v1), finalColor);
      // Top-Right
      _addVertex(vertexData, Vector3(x1, -y0, z), Vector2(glyph.u2, glyph.v1), finalColor);
      // Bottom-Left
      _addVertex(vertexData, Vector3(x0, -y1, z), Vector2(glyph.u1, glyph.v2), finalColor);
      // Bottom-Right
      _addVertex(vertexData, Vector3(x1, -y1, z), Vector2(glyph.u2, glyph.v2), finalColor);

      // Two triangles (0,1,2) and (1,3,2)
      indices.addAll([
        vertexOffset + 0, vertexOffset + 1, vertexOffset + 2,
        vertexOffset + 1, vertexOffset + 3, vertexOffset + 2,
      ]);

      vertexOffset += 4;
      cursorX += glyph.advance * fontSize;
    }

    final format = VertexFormat('TextFormat', [
      const VertexAttribute(AttributeUsage.position, 3),
      const VertexAttribute(AttributeUsage.uv, 2),
      const VertexAttribute(AttributeUsage.color, 4),
    ]);

    return Mesh.create(format, vertexData, indices32: indices);
  }

  static void _addVertex(List<double> data, Vector3 pos, Vector2 uv, Vector4 col) {
    data.addAll([pos.x, pos.y, pos.z]);
    data.addAll([uv.x, uv.y]);
    data.addAll([col.x, col.y, col.z, col.w]);
  }
}
