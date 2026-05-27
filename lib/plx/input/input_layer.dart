import 'package:exa_vortex/plx/input/input_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PlxInputLayer extends StatelessWidget {
  final FocusNode focusNode;
  final List<PlxInputManager> inputManagers;
  final Widget child;

  const PlxInputLayer({
    super.key,
    required this.focusNode,
    required this.inputManagers,
    required this.child,
  });

  bool get _hasMouse => inputManagers.any((m) => m.mouse != null);
  bool get _hasTouch => inputManagers.any((m) => m.touch != null);
  bool get _hasKeyboard => inputManagers.any((m) => m.keyboard != null);

  MouseCursor get _currentCursor {
    for (var m in inputManagers) {
      if (m.mouse != null && m.cursor != MouseCursor.defer) {
        return m.cursor;
      }
    }
    return MouseCursor.defer;
  }

  void _handlePointerEvent(PointerEvent event) {
    for (var m in inputManagers) {
      m.handlePointerEvent(event);
    }
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    for (var m in inputManagers) {
      m.handlePointerSignal(event);
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    bool handled = false;
    for (var m in inputManagers) {
      if (m.handleKeyEvent(event)) {
        handled = true;
      }
    }
    return handled;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(inputManagers),
      builder: (context, _) {
        Widget current = child;

        // Apply pointer listener if mouse or touch is enabled
        if (_hasMouse || _hasTouch) {
          current = Listener(
            onPointerDown: _handlePointerEvent,
            onPointerUp: _handlePointerEvent,
            onPointerMove: _handlePointerEvent,
            onPointerHover: _handlePointerEvent,
            onPointerCancel: _handlePointerEvent,
            onPointerSignal: _handlePointerSignal,
            child: current,
          );
        }
        // Apply mouse region if mouse is enabled
        if (_hasMouse) {
          current = MouseRegion(cursor: _currentCursor, child: current);
        }
        // Apply focus and keyboard handling if keyboard is enabled
        if (_hasKeyboard) {
          current = TapRegion(
            onTapInside: (_) => focusNode.requestFocus(),
            onTapOutside: (_) => focusNode.unfocus(),
            child: Focus(
              skipTraversal: true,
              focusNode: focusNode,
              autofocus: true,
              onKeyEvent: (node, event) {
                final handled = _handleKeyEvent(event);
                return handled ? KeyEventResult.handled : KeyEventResult.ignored;
              },
              child: current,
            ),
          );
        }

        return current;
      },
    );
  }
}
