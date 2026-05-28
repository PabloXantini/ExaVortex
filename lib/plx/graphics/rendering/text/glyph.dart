import 'dart:ui';
import 'package:exa_vortex/plx/graphics/rendering/sprite/quad.dart';
import 'package:vector_math/vector_math_64.dart';

class GlyphMetrics {
  final Vector2 uv1;
  final Vector2 uv2;
  final Size size;
  final Offset bearing;
  final double advance;

  GlyphMetrics({
    required this.uv1,
    required this.uv2,
    required this.size,
    required this.bearing,
    required this.advance,
  });
}

/// Returns a [SpriteQuad] for this glyph positioned at the given cursor.
///
/// [cursorX] is the horizontal pen position.
/// [baselineY] is the combined vertical offset (cursorY + ascent for multi-line, or 0 for single-line).
/// [fontSize] scales the glyph.
/// [z] is the depth value used for ordering.
SpriteQuad toSpriteQuad(
  GlyphMetrics glyph, {
  required double cursorX,
  required double baselineY,
  required double fontSize,
  required double z,
}) {
  final double x0 = cursorX + glyph.bearing.dx * fontSize;
  final double x1 = x0 + glyph.size.width * fontSize;
  final double y0 = -(baselineY + glyph.bearing.dy * fontSize);
  final double y1 = -(baselineY + (glyph.bearing.dy + glyph.size.height) * fontSize);

  return SpriteQuad(
    tlPosition: Vector2(x0, y0),
    brPosition: Vector2(x1, y1),
    z: z,
    uv0: glyph.uv1,
    uv1: Vector2(glyph.uv2.x, glyph.uv1.y),
    uv2: Vector2(glyph.uv1.x, glyph.uv2.y),
    uv3: glyph.uv2,
  );
}
