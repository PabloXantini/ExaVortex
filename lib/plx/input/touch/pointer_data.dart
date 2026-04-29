import 'dart:ui';

class PointerData {
  final int id;
  final PointerDeviceKind kind;
  Offset position = Offset.zero;
  Offset previousPosition = Offset.zero;
  Offset delta = Offset.zero;
  bool isDown = false;
  bool updatedThisFrame = false;

  PointerData({required this.id, required this.kind});

  void update(Offset newPosition, Offset newDelta, bool down) {
    previousPosition = position == Offset.zero ? newPosition : position;
    position = newPosition;
    delta += newDelta;
    isDown = down;
    updatedThisFrame = true;
  }

  void resetFrame() {
    delta = Offset.zero;
    previousPosition = position;
    updatedThisFrame = false;
  }
}
