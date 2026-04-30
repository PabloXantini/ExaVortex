import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import '../pointer_data.dart';
import '../physical_input.dart';
import 'cursor.dart';

enum MouseEventKind { move, drag, button, scroll }

class MouseState {
  PointerData? _pointer;
  double _scrollDelta = 0.0;
  MouseCursor c = SystemMouseCursors.basic;
  // Getters
  Offset get position => _pointer?.position ?? Offset.zero;
  Offset get delta => _pointer?.delta ?? Offset.zero;
  double get scrollDelta => _scrollDelta;
  
  bool get isDown => _pointer?.isDown ?? false;
  
  set cursor(CursorShape value) => c = _getCursorShape(value);

  int _lastButtons = 0;

  bool handlePointerEvent(PointerEvent event, Function(PhysicalInput, bool, double) triggerBindings) {
    _pointer ??= PointerData(id: event.pointer, kind: PointerDeviceKind.mouse);
    _pointer!.update(event.localPosition, event.delta, event.buttons != 0);
    
    bool handled = false;

    // Detect button state changes
    final int changedButtons = _lastButtons ^ event.buttons;
    _lastButtons = event.buttons;

    // Trigger specific button bindings for changed bits
    if (changedButtons != 0) {
      handled |= _updateButton(kPrimaryButton, MouseButton.left, event.buttons, triggerBindings);
      handled |= _updateButton(kSecondaryButton, MouseButton.right, event.buttons, triggerBindings);
      handled |= _updateButton(kTertiaryButton, MouseButton.middle, event.buttons, triggerBindings);
    }

    // Trigger movement/hover bindings
    if (event is PointerHoverEvent) {
      handled |= triggerBindings(PhysicalInput.mouse(MouseButton.hover), true, 1.0);
    } else if (event is PointerMoveEvent) {
      handled |= triggerBindings(PhysicalInput.mouse(MouseButton.move), true, 1.0);
    }

    // Still trigger unknown for backward compatibility if needed
    if (event is PointerMoveEvent || event is PointerHoverEvent) {
      handled |= triggerBindings(PhysicalInput.mouse(MouseButton.unknown), true, 1.0);
    }
    
    return handled;
  }
  void handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _scrollDelta += event.scrollDelta.dy;
    }
  }

  void update() {
    _pointer?.resetFrame();
    _scrollDelta = 0.0;
  }

  void cleanup() {
    if (_pointer != null && !_pointer!.isDown && !_pointer!.updatedThisFrame) {
      _pointer = null;
    }
    if (_pointer != null) _pointer!.updatedThisFrame = false;
  }

  MouseCursor _getCursorShape(CursorShape shape){
    switch(shape){
      case CursorShape.basic: return SystemMouseCursors.basic;
      case CursorShape.hand: return SystemMouseCursors.grab;
      case CursorShape.grabbing: return SystemMouseCursors.grabbing;
      case CursorShape.text: return SystemMouseCursors.text;
      case CursorShape.move: return SystemMouseCursors.move;
    }
  }

  bool _updateButton(int mask, MouseButton button, int currentButtons, Function(PhysicalInput, bool, double) triggerBindings) {
    final bool isDown = (currentButtons & mask) != 0;
    return triggerBindings(PhysicalInput.mouse(button), isDown, isDown ? 1.0 : 0.0);
  }
}
