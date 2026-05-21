import 'package:exa_vortex/plx/graphics/mesh.dart';
import 'package:exa_vortex/plx/graphics/sprite/quad.dart';
import 'package:exa_vortex/plx/graphics/text/geometry.dart';
import 'package:exa_vortex/plx/graphics/text/glyph.dart';
import 'package:exa_vortex/plx/graphics/text/mesh_builder.dart';
import 'package:vector_math/vector_math_64.dart';
import 'font.dart';

/// Builds a [Mesh] from a plain string using a single [PlxFont].
///
/// For rich text or multi-line layout use [TextMeshBuilder] with a [TextComposition].
class TextBuilder {
  /// Builds a mesh from [text] using textured quads from the font atlas.
  ///
  /// [anchor] controls where the origin (0,0) sits relative to the text.
  static Mesh buildMesh(
    String text,
    PlxFont font, {
    double fontSize = 1.0,
    Vector4? color,
    TextAnchor anchor = TextAnchor.bottomLeft,
    double letterSpacing = 0.0,
  }) {
    final Vector4 finalColor = color ?? Vector4(1, 1, 1, 1);

    // First pass: collect quads and measure bounds
    final List<SpriteQuad> quads = _collectQuads(text, font, fontSize, letterSpacing);

    // Compute offset from anchor and apply it
    final offset = getLayoutPosition(anchor, calculateBounds(quads));
    for (var q in quads) {
      q.tlPosition.add(offset);
      q.brPosition.add(offset);
    }

    return TextMeshBuilder.buildQuadMesh(quads, finalColor);
  }

  static List<SpriteQuad> _collectQuads(String text, PlxFont font, double fontSize, double letterSpacing) {
    final List<SpriteQuad> quads = [];
    double cursorX = 0.0;

    for (int i = 0; i < text.length; i++) {
      final charCode = text.codeUnitAt(i);
      final glyph = font.glyphs[charCode];
      if (glyph == null) {
        if (text[i] == ' ') cursorX += 0.3 * fontSize;
        continue;
      }

      quads.add(toSpriteQuad(glyph, cursorX: cursorX, baselineY: 0, fontSize: fontSize, z: i * 0.0001));
      cursorX += glyph.advance * fontSize + letterSpacing;
    }
    return quads;
  }
}
