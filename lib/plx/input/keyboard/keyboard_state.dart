import 'package:flutter/services.dart';
import '../physical_input.dart';

class KeyboardState {
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  bool handleEvent(KeyEvent event, Function(PhysicalInput, bool, double) triggerBindings) {
    final isDown = event is KeyDownEvent || event is KeyRepeatEvent;
    if (isDown) {
      _pressedKeys.add(event.logicalKey);
    } else {
      _pressedKeys.remove(event.logicalKey);
    }
    final physicalInput = PhysicalInput.keyboard(event.logicalKey);
    return triggerBindings(physicalInput, isDown, isDown ? 1.0 : 0.0);
  }
  bool isKeyPressed(LogicalKeyboardKey key) => _pressedKeys.contains(key);
  void clear() {
    _pressedKeys.clear();
  }
}
