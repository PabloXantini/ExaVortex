import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import '../touch/pointer_data.dart';
import '../physical_input.dart';

enum MouseEventKind { move, drag, button, scroll }
enum CursorShape {
  basic, 
  hand, 
  grabbing, 
  text,
  moving 
}

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

  bool handlePointerEvent(PointerEvent event, Function(PhysicalInput, bool, double) triggerBindings) {
    _pointer ??= PointerData(id: event.pointer, kind: PointerDeviceKind.mouse);
    _pointer!.update(event.localPosition, event.delta, event.buttons != 0);
    final button = _cast(event.buttons);
    final physicalInput = PhysicalInput.mouse(button);
    
    bool handled = false;
    final isDownEvent = event is PointerDownEvent;
    final isUpEvent = event is PointerUpEvent || event is PointerCancelEvent;
    final isMoveEvent = event is PointerMoveEvent || event is PointerHoverEvent;

    if (isMoveEvent && !isDownEvent && !isUpEvent) {
      handled = triggerBindings(physicalInput, true, 1.0);
    } else {
      handled = triggerBindings(physicalInput, _pointer!.isDown, _pointer!.isDown ? 1.0 : 0.0);
    }
    
    return handled;
  }

  void handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      _scrollDelta += event.scrollDelta.dy;
    }
  }

  MouseButton _cast(int buttons) {
    if (buttons & kPrimaryButton != 0) return MouseButton.left;
    if (buttons & kSecondaryButton != 0) return MouseButton.right;
    if (buttons & kTertiaryButton != 0) return MouseButton.middle;
    return MouseButton.unknown;
  }

  void update() {
    _pointer?.resetFrame();
    _scrollDelta = 0.0;
  }

  void cleanup() {
    if (_pointer != null && !_pointer!.isDown && !_pointer!.updatedThisFrame) {
      _pointer = null;
    }
    _pointer?.updatedThisFrame = false;
  }

  MouseCursor _getCursorShape(CursorShape shape){
    switch(shape){
      case CursorShape.basic: return SystemMouseCursors.basic;
      case CursorShape.hand: return SystemMouseCursors.grab;
      case CursorShape.grabbing: return SystemMouseCursors.grabbing;
      case CursorShape.text: return SystemMouseCursors.text;
      case CursorShape.moving: return SystemMouseCursors.move;
    }
  }
}
