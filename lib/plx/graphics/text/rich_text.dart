import 'package:vector_math/vector_math_64.dart';
import 'font.dart';

/// A segment of text with a specific style
class TextSegment {
  final String text;
  final PlxFont font;
  final double fontSize;
  final Vector4 color;
  final double letterSpacing;

  TextSegment({
    required this.text,
    required this.font,
    this.fontSize = 1.0,
    Vector4? color,
    this.letterSpacing = 0.0,
  }) : color = color ?? Vector4(1, 1, 1, 1);
}

/// A collection of text segments to be rendered together
class TextComposition {
  final List<TextSegment> segments;

  TextComposition({required this.segments});
}
