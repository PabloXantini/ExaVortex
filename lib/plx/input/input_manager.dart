import 'package:flutter/services.dart';
import 'physical_input.dart';
import 'input_action.dart';

class InputManager {
  static final InputManager _instance = InputManager._internal();
  factory InputManager() => _instance;
  InputManager._internal();

  final Map<String, InputAction> _actions = {};
  final Map<PhysicalInput, List<String>> _bindings = {};

  void registerAction(String actionName) {
    if (!_actions.containsKey(actionName)) {
      _actions[actionName] = InputAction(actionName);
    }
  }

  void bindInput(PhysicalInput input, String actionName) {
    registerAction(actionName);
    if (!_bindings.containsKey(input)) {
      _bindings[input] = [];
    }
    if (!_bindings[input]!.contains(actionName)) {
      _bindings[input]!.add(actionName);
    }
  }

  void unbindInput(PhysicalInput input, String actionName) {
    _bindings[input]?.remove(actionName);
  }
  
  void clearBindings() {
    _bindings.clear();
  }

  Map<PhysicalInput, List<String>> getBindings() => _bindings;

  InputAction? getAction(String actionName) => _actions[actionName];

  bool isActionPressed(String actionName) => _actions[actionName]?.isPressed ?? false;
  bool wasActionPressed(String actionName) => _actions[actionName]?.wasPressedThisFrame ?? false;
  bool wasActionReleased(String actionName) => _actions[actionName]?.wasReleasedThisFrame ?? false;
  double getActionValue(String actionName) => _actions[actionName]?.value ?? 0.0;

  // Allows hooking into Flutter's RawKeyboard or HardwareKeyboard events
  bool handleKeyEvent(KeyEvent event) {
    final isDown = event is KeyDownEvent || event is KeyRepeatEvent;
    
    final physicalInput = PhysicalInput(
      device: InputDevice.keyboard,
      keyId: event.logicalKey.keyId,
    );

    return _triggerBindings(physicalInput, isDown, isDown ? 1.0 : 0.0);
  }

  // Returns true if the input was handled (bound to an action)
  bool _triggerBindings(PhysicalInput input, bool pressed, double value) {
    final actionsToUpdate = _bindings[input];
    if (actionsToUpdate != null && actionsToUpdate.isNotEmpty) {
      for (final actionName in actionsToUpdate) {
        _actions[actionName]?.update(pressed, value);
      }
      return true;
    }
    return false;
  }

  void update() {
    for (final action in _actions.values) {
      action.resetFrame();
    }
  }
}
