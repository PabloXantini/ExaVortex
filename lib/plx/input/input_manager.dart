import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'physical_input.dart';
import 'input_action.dart';
import 'keyboard/keyboard_state.dart';
import 'mouse/mouse_state.dart';
import 'mouse/cursor.dart';
import 'touch/touch_state.dart';

class PlxInputManager extends ChangeNotifier {
  // Specialized States
  KeyboardState? keyboard;
  MouseState? mouse;
  TouchState? touch;

  // Actions and Bindings
  final Map<String, InputAction> _actions = {};
  final Map<PhysicalInput, List<String>> _bindings = {};

  // Initialization Factories
  /// Enables the keyboard inputs
  void enableKeyboard() {
    keyboard ??= KeyboardState();
  }
  /// Enables the mouse inputs
  void enableMouse() {
    mouse ??= MouseState();
  }
  /// Enables the touch inputs
  void enableTouch() {
    touch ??= TouchState();
  }

  // Getters
  /// Total number of active pointers (Mouse + Touches)
  int get pointerCount => (mouse?.isDown == true ? 1 : 0) + (touch?.count ?? 0);
  
  /// Shorthand for the primary pointer position (Mouse or first Touch)
  Offset get pointerPosition {
    if (mouse?.isDown == true || (touch?.count ?? 0) == 0) {
      return mouse?.position ?? Offset.zero;
    }
    return touch!.pointers.first.position;
  }
  
  /// Shorthand for the primary pointer delta (Mouse or first Touch)
  Offset get pointerDelta {
    if (mouse != null && mouse!.delta != Offset.zero) {
      return mouse!.delta;
    }
    if (touch != null && touch!.count > 0) {
      return touch!.pointers.first.delta;
    }
    return Offset.zero;
  }
  
  /// Current mouse cursor
  MouseCursor get cursor => mouse?.c ?? MouseCursor.defer;
  set cursor(CursorShape value) {
    if (mouse == null) return;
    mouse!.cursor = value;
    notifyListeners();
  }
  // Configuration
  void registerAction(String actionName) {
    _actions.putIfAbsent(actionName, () => InputAction(actionName));
  }
  void bindInput(PhysicalInput input, String actionName) {
    registerAction(actionName);
    _bindings.putIfAbsent(input, () => []).add(actionName);
  }
  void unbindInput(PhysicalInput input, String actionName) {
    _bindings[input]?.remove(actionName);
  }
  void clearBindings() {
    _bindings.clear();
    keyboard?.clear();
  }

  Map<PhysicalInput, List<String>> getBindings() => _bindings; 
  InputAction? getAction(String actionName) => _actions[actionName];
  
  /// Returns true if the action is currently triggered
  bool isActionTriggered(String actionName) => _actions[actionName]?.isTriggered ?? false;
  /// Returns true if the action was triggered this frame
  bool wasActionTriggered(String actionName) => _actions[actionName]?.wasTriggeredThisFrame ?? false;
  /// Returns true if the action was released this frame
  bool wasActionReleased(String actionName) => _actions[actionName]?.wasReleasedThisFrame ?? false;
  /// Returns the value of the action (e.g. for axes or analog triggers)
  double getActionValue(String actionName) => _actions[actionName]?.value ?? 0.0;

  // Event handling
  // Keyboard events
  bool handleKeyEvent(KeyEvent event) {
    if (keyboard == null) return false;
    final handled = keyboard!.handleEvent(event, _triggerBindings);
    if (handled) notifyListeners();
    return handled;
  }
  // Pointer events
  bool handlePointerEvent(PointerEvent event) {
    bool handled = false;
    switch(event.kind){
      case PointerDeviceKind.mouse:
        if (mouse == null) break;
        handled = mouse!.handlePointerEvent(event, _triggerBindings);
        break;
      case PointerDeviceKind.touch:
        if (touch == null) break;
        handled = touch!.handlePointerEvent(event, _triggerBindings);
        break;
      default: {
      }
      break;
    }
    if (handled) notifyListeners();
    return handled;
  }
  void handlePointerSignal(PointerSignalEvent event) {
    if (mouse==null) return;
    mouse!.handlePointerSignal(event);
    notifyListeners();
  }

  // Update
  void update() {
    // Update device states
    mouse?.update();
    touch?.update();
    // Reset actions
    for (final action in _actions.values) {
      action.resetFrame();
    }
    // Clear inputs
    keyboard?.clear();
    mouse?.cleanup();
  }
  bool _triggerBindings(PhysicalInput input, bool pressed, double value) {
    final actionsToUpdate = _bindings[input];
    if (actionsToUpdate == null) return false;

    for (final actionName in actionsToUpdate) {
      _actions[actionName]?.update(pressed, value);
    }
    return true;
  }
}
