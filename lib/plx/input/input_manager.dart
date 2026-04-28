import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'physical_input.dart';
import 'input_action.dart';

class PointerData {
  final int id;
  final PointerDeviceKind kind;
  Offset position = Offset.zero;
  Offset delta = Offset.zero;
  bool isDown = false;
  bool updatedThisFrame = false;

  PointerData({required this.id, required this.kind});
}

class InputManager extends ChangeNotifier {
  final Map<String, InputAction> _actions = {};
  final Map<PhysicalInput, List<String>> _bindings = {};
  final Map<int, PointerData> _pointers = {};

  // Primary pointer state (legacy/shorthand)
  Offset _pointerPosition = Offset.zero;
  Offset _pointerDelta = Offset.zero;

  // Getters
  Offset get pointerPosition => _pointerPosition;
  Offset get pointerDelta => _pointerDelta;
  List<int> get activePointerIds => _pointers.keys.toList();
  PointerData? getPointer(int id) => _pointers[id];
  Iterable<PointerData> get pointers => _pointers.values;

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
  }

  Map<PhysicalInput, List<String>> getBindings() => _bindings; 
  InputAction? getAction(String actionName) => _actions[actionName];
  bool isActionPressed(String actionName) => _actions[actionName]?.isPressed ?? false;
  bool wasActionPressed(String actionName) => _actions[actionName]?.wasPressedThisFrame ?? false;
  bool wasActionReleased(String actionName) => _actions[actionName]?.wasReleasedThisFrame ?? false;
  double getActionValue(String actionName) => _actions[actionName]?.value ?? 0.0;

  /// Handles keyboard events
  bool handleKeyEvent(KeyEvent event) {
    final isDown = event is KeyDownEvent || event is KeyRepeatEvent;
    final physicalInput = PhysicalInput.keyboard(event.logicalKey);

    final handled = _triggerBindings(physicalInput, isDown, isDown ? 1.0 : 0.0);
    if (handled) notifyListeners();
    return handled;
  }

  /// Handles mouse/touch pointer events
  bool handlePointerEvent(PointerEvent event) {
    final pData = _updatePointerState(event);
    _updatePrimaryPointerLegacy(event, pData);
    // Identify which physical button or touch index triggered this
    final physicalInput = _mapPointerToPhysicalInput(event);
    // Process actions
    bool handled = false;
    final isDown = event is PointerDownEvent;
    final isUp = event is PointerUpEvent || event is PointerCancelEvent;
    final isMove = event is PointerMoveEvent || event is PointerHoverEvent;
    if (isMove && !isDown && !isUp) {
      handled = _triggerBindings(physicalInput, true, 1.0);
    } else {
      handled = _triggerBindings(physicalInput, pData.isDown, pData.isDown ? 1.0 : 0.0);
    }

    notifyListeners();
    return handled;
  }

  void update() {
    for (final action in _actions.values) {
      action.resetFrame();
    }
    _pointerDelta = Offset.zero;
    _cleanupInactivePointers();
  }

  PointerData _updatePointerState(PointerEvent event) {
    final pointerId = event.pointer;
    final pData = _pointers.putIfAbsent(pointerId, () => PointerData(id: pointerId, kind: event.kind));
    pData.position = event.localPosition;
    pData.updatedThisFrame = true;
    if (event is PointerMoveEvent || event is PointerHoverEvent) {
      pData.delta += event.delta;
    }
    if (event is PointerDownEvent) pData.isDown = true;
    if (event is PointerUpEvent || event is PointerCancelEvent) pData.isDown = false;
    return pData;
  }

  void _updatePrimaryPointerLegacy(PointerEvent event, PointerData pData) {
    if (_pointers.isEmpty) return;
    final primary = _pointers.values.first;
    _pointerPosition = primary.position;
    if (event.pointer == primary.id && (event is PointerMoveEvent || event is PointerHoverEvent)) {
      _pointerDelta += event.delta;
    }
  }

  PhysicalInput _mapPointerToPhysicalInput(PointerEvent event) {
    if (event.kind == PointerDeviceKind.touch) {
      // Map pointer ID to an index (0, 1, 2...) based on insertion order in _pointers
      final index = _pointers.keys.toList().indexOf(event.pointer);
      return PhysicalInput.touch(index >= 0 ? index : 0);
    } else {
      // Map mouse buttons using the provided enum values
      MouseButton button = MouseButton.unknown;
      if (event.buttons & kPrimaryButton != 0) {
        button = MouseButton.left;
      } else if (event.buttons & kSecondaryButton != 0) {
        button = MouseButton.right;
      } else if (event.buttons & kTertiaryButton != 0) {
        button = MouseButton.middle;
      }
      return PhysicalInput.mouse(button);
    }
  }

  bool _triggerBindings(PhysicalInput input, bool pressed, double value) {
    final actionsToUpdate = _bindings[input];
    if (actionsToUpdate == null) return false;

    for (final actionName in actionsToUpdate) {
      _actions[actionName]?.update(pressed, value);
    }
    return true;
  }

  void _cleanupInactivePointers() {
    final toRemove = <int>[];
    for (final p in _pointers.values) {
      p.delta = Offset.zero; 
      // Remove if not pressed AND no update was received this frame (e.g. mouse stopped)
      if (!p.isDown && !p.updatedThisFrame) {
        toRemove.add(p.id);
      }
      p.updatedThisFrame = false;
    }
    if (toRemove.isNotEmpty) {
      for (final id in toRemove) {
        _pointers.remove(id);
      }
      notifyListeners();
    }
  }
}
