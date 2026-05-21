import 'package:exa_vortex/plx/graphics/mesh.dart';
import 'package:exa_vortex/plx/geometry/2d/rect.dart';
import 'package:exa_vortex/plx/graphics/sprite/quad.dart';
import 'package:exa_vortex/plx/graphics/text/geometry.dart';
import 'package:vector_math/vector_math_64.dart';
import 'plx_font.dart';

class TextGeometryBuilder {
  /// Builds a mesh from [text] using textured quads from the font atlas.
  ///
  /// [anchor] controls where the origin (0,0) sits relative to the text.
  /// [bounds] is filled with the un-offset bounding box so callers can query it.
  static Mesh buildMesh(
    String text,
    PlxFont font, {
    double fontSize = 1.0,
    Vector4? color,
    TextAnchor anchor = TextAnchor.bottomLeft,
  }) {
    final Vector4 finalColor = color ?? Vector4(1, 1, 1, 1);

    // First pass: collect raw quad data and measure bounds
    final _SpriteMeshBoundary spriteQuads = _collectQuads(text, font, fontSize, finalColor);
    final BoundRect bounds = spriteQuads.bounds;

    // Compute offset from anchor
    final Vector2 offset = _anchorOffset(bounds, anchor);

    // Second pass: write final vertex data with offset applied
    final List<double> vertexData = [];
    for (final q in spriteQuads.quads) {
      _addVertex(vertexData, Vector3(q.tlPosition.x + offset.x, q.tlPosition.y + offset.y, q.z), q.uv0, finalColor);
      _addVertex(vertexData, Vector3(q.brPosition.x + offset.x, q.tlPosition.y + offset.y, q.z), q.uv1, finalColor);
      _addVertex(vertexData, Vector3(q.tlPosition.x + offset.x, q.brPosition.y + offset.y, q.z), q.uv2, finalColor);
      _addVertex(vertexData, Vector3(q.brPosition.x + offset.x, q.brPosition.y + offset.y, q.z), q.uv3, finalColor);
    }

    final format = VertexFormat('TextFormat', [
      const VertexAttribute(AttributeUsage.position, 3),
      const VertexAttribute(AttributeUsage.uv, 2),
      const VertexAttribute(AttributeUsage.color, 4),
    ]);

    return Mesh.create(format, vertexData, indices32: spriteQuads.indices);
  }

  static _SpriteMeshBoundary _collectQuads(
    String text, PlxFont font, double fontSize, Vector4 color) {
    final List<SpriteQuad> quads = [];
    final List<int> indices = [];
    int vertexOffset = 0;

    double cursorX = 0.0;
    // Track bounds in y-up space (y0 = top positive, y1 = bottom negative)
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);
      final glyph = font.glyphs[charCode];
      if (glyph == null) {
        if (text[i] == ' ') {
          cursorX += 0.3 * fontSize;
        }
        continue;
      }

      // x0,x1 in horizontal direction; y is flipped to y-up
      final double x0 = cursorX + glyph.bearing.dx * fontSize;
      final double x1 = x0 + glyph.size.width * fontSize;
      final double y0 = -glyph.bearing.dy * fontSize;    // top edge (positive y-up)
      final double y1 = -(glyph.bearing.dy + glyph.size.height) * fontSize; // bottom edge
      final double z = i * 0.0001;

      minX = minX < x0 ? minX : x0;
      maxX = maxX > x1 ? maxX : x1;
      minY = minY < y1 ? minY : y1; // y1 is more negative (lower)
      maxY = maxY > y0 ? maxY : y0;

      quads.add(SpriteQuad(
        tlPosition: Vector2(x0, y0),
        brPosition: Vector2(x1, y1),
        z: z,
        uv0: glyph.uv1,
        uv1: Vector2(glyph.uv2.x, glyph.uv1.y),
        uv2: Vector2(glyph.uv1.x, glyph.uv2.y),
        uv3: glyph.uv2,
      ));

      indices.addAll([
        vertexOffset + 0, vertexOffset + 1, vertexOffset + 2,
        vertexOffset + 1, vertexOffset + 3, vertexOffset + 2,
      ]);
      vertexOffset += 4;
      cursorX += glyph.advance * fontSize;
    }

    final bounds = BoundRect(
      left:   quads.isEmpty ? 0 : minX,
      right:  quads.isEmpty ? 0 : maxX,
      top:    quads.isEmpty ? 0 : maxY,
      bottom: quads.isEmpty ? 0 : minY,
    );

    return _SpriteMeshBoundary(quads: quads, indices: indices, bounds: bounds);
  }

  /// Returns an XY offset that moves the raw geometry so that the anchor
  /// sits at the origin (0, 0).
  static Vector2 _anchorOffset(BoundRect b, TextAnchor anchor) {
    switch (anchor) {
      case TextAnchor.bottomLeft:
        return Vector2(-b.left, -b.bottom);
      case TextAnchor.bottomRight:
        return Vector2(-b.right, -b.bottom);
      case TextAnchor.topLeft:
        return Vector2(-b.left, -b.top);
      case TextAnchor.topRight:
        return Vector2(-b.right, -b.top);
      case TextAnchor.center:
        return Vector2(-b.center.x, -b.center.y);
    }
  }

  static void _addVertex(List<double> data, Vector3 pos, Vector2 uv, Vector4 col) {
    data.addAll([pos.x, pos.y, pos.z]);
    data.addAll([uv.x, uv.y]);
    data.addAll([col.x, col.y, col.z, col.w]);
  }
}

class _SpriteMeshBoundary {
  final List<SpriteQuad> quads;
  final List<int> indices;
  final BoundRect bounds;
  const _SpriteMeshBoundary({required this.quads, required this.indices, required this.bounds});
}
