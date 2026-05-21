import 'dart:ui';
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
