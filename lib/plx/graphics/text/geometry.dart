import 'package:exa_vortex/plx/geometry/2d/rect.dart';
import 'package:vector_math/vector_math_64.dart';

/// Defines the anchor point for text positioning.
enum TextAnchor {
  /// Origin at bottom-left corner.
  bottomLeft,
  /// Origin at bottom-right corner.
  bottomRight,
  /// Origin at bottom-center corner.
  bottomCenter,
  /// Origin at top-left corner.
  topLeft,
  /// Origin at top-right corner.
  topRight,
  /// Origin at top-center corner.
  topCenter,
  /// Origin at the center of the bounding box.
  center,
  /// Origin at center-left corner.
  centerLeft,
  /// Origin at center-right corner.
  centerRight,
}

enum TextAlign {
  left,
  right,
  center,
  justified,
}

Vector2 getLayoutPosition(TextAnchor anchor, BoundRect bounds) {
  switch (anchor) {
    case TextAnchor.bottomLeft:
      return Vector2(-bounds.left, -bounds.bottom);
    case TextAnchor.bottomRight:
      return Vector2(-bounds.right, -bounds.bottom);
    case TextAnchor.bottomCenter:
      return Vector2(-bounds.center.x, -bounds.bottom);
    case TextAnchor.topLeft:
      return Vector2(-bounds.left, -bounds.top);
    case TextAnchor.topRight:
      return Vector2(-bounds.right, -bounds.top);
    case TextAnchor.topCenter:
      return Vector2(-bounds.center.x, -bounds.top);
    case TextAnchor.center:
      return Vector2(-bounds.center.x, -bounds.center.y);
    case TextAnchor.centerLeft:
      return Vector2(-bounds.left, -bounds.center.y);
    case TextAnchor.centerRight:
      return Vector2(-bounds.right, -bounds.center.y);
  }
}
