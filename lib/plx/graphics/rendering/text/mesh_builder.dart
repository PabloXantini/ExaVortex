import 'package:exa_vortex/plx/graphics/primitives/mesh.dart';
import 'package:exa_vortex/plx/graphics/graphics.dart';
import 'package:exa_vortex/plx/graphics/primitives/vertex.dart';
import 'package:exa_vortex/plx/graphics/rendering/sprite/quad.dart';
import 'package:exa_vortex/plx/graphics/rendering/text/geometry.dart';
import 'package:exa_vortex/plx/graphics/rendering/text/rich_text.dart';
import 'package:exa_vortex/plx/graphics/rendering/text/layout_builder.dart';
import 'package:flutter/material.dart' show Size;
import 'package:vector_math/vector_math_64.dart';

/// Utility class to build [Mesh] objects from text quads.
///
/// Both [TextLayoutBuilder] and [TextBuilder] delegate here.
class TextMeshBuilder {
  /// Runs layout on a [TextComposition] and returns a map of fontId → [Mesh].
  ///
  /// The caller is responsible for pairing each mesh with the correct font renderer.
  static Map<int, PlxMesh> buildMeshes(
    TextComposition composition, {
    required Size bounds,
    TextAlign align = TextAlign.left,
    TextAnchor anchor = TextAnchor.topLeft,
    double lineSpacing = 0.0,
  }) {
    final layout = TextLayoutBuilder.layout(
      composition,
      maxWidth: bounds.width,
      align: align,
      anchor: anchor,
      lineSpacing: lineSpacing,
    );

    final Map<int, PlxMesh> result = {};
    final seen = <int>{};

    for (var segment in composition.segments) {
      final fontId = segment.font.hashCode;
      if (seen.contains(fontId)) continue;
      seen.add(fontId);

      if (!layout.quadsByFontId.containsKey(fontId)) continue;
      final quads = layout.quadsByFontId[fontId]!;
      if (quads.isEmpty) continue;

      result[fontId] = buildQuadMesh(quads, segment.color);
    }

    return result;
  }

  /// Converts a list of [SpriteQuad]s with a uniform [color] into a [Mesh].
  static PlxMesh buildQuadMesh(List<SpriteQuad> quads, Vector4 color) {
    final List<double> vertexData = [];
    final List<int> indices = [];
    int vertexOffset = 0;

    for (var q in quads) {
      Vertex.add(vertexData, Vector3(q.tlPosition.x, q.tlPosition.y, q.z), q.uv0, color);
      Vertex.add(vertexData, Vector3(q.brPosition.x, q.tlPosition.y, q.z), q.uv1, color);
      Vertex.add(vertexData, Vector3(q.tlPosition.x, q.brPosition.y, q.z), q.uv2, color);
      Vertex.add(vertexData, Vector3(q.brPosition.x, q.brPosition.y, q.z), q.uv3, color);

      indices.addAll([
        vertexOffset + 0, vertexOffset + 1, vertexOffset + 2,
        vertexOffset + 1, vertexOffset + 3, vertexOffset + 2,
      ]);
      vertexOffset += 4;
    }

    final format = VertexFormat('TextFormat', [
      const VertexAttribute(AttributeUsage.position, 3),
      const VertexAttribute(AttributeUsage.uv, 2),
      const VertexAttribute(AttributeUsage.color, 4),
    ]);

    return PlxGraphics.instance.createMesh(format, vertexData, indices32: indices);
  }
}
