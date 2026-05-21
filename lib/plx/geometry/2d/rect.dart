import 'package:vector_math/vector_math_64.dart';

/// Immutable bounding box of a built text mesh, in local space.
class BoundRect {
  final double left;
  final double right;
  final double top;
  final double bottom;

  const BoundRect({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  double get width  => right - left;
  double get height => top - bottom; // top > bottom (y-up)
  Vector2 get center => Vector2((left + right) / 2, (top + bottom) / 2);

  @override
  String toString() =>
      'BoundRect(l=$left, r=$right, t=$top, b=$bottom, w=$width, h=$height)';
}