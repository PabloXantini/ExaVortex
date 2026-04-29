import 'package:flutter/gestures.dart';
import '../pointer_data.dart';
import '../physical_input.dart';

class TouchState {
  final Map<int, PointerData> _pointers = {};
  
  // Getters
  int get count => _pointers.length;
  List<int> get activeIds => _pointers.keys.toList();
  Iterable<PointerData> get pointers => _pointers.values;
  PointerData? getPointer(int id) => _pointers[id];

  bool handlePointerEvent(PointerEvent event, Function(PhysicalInput, bool, double) triggerBindings) {
    final pointerId = event.pointer;
    final pData = _pointers.putIfAbsent(pointerId, () => PointerData(id: pointerId, kind: event.kind));
    
    final isDown = event is PointerDownEvent;
    final isUp = event is PointerUpEvent || event is PointerCancelEvent;
    
    pData.update(event.localPosition, event.delta, isDown ? true : (isUp ? false : pData.isDown));

    // Map pointer ID to an index (0, 1, 2...) based on insertion order
    final index = _pointers.keys.toList().indexOf(pointerId);
    final physicalInput = PhysicalInput.touch(index >= 0 ? index : 0);

    bool handled = false;
    final isMove = event is PointerMoveEvent;

    if (isMove && !isDown && !isUp) {
      handled = triggerBindings(physicalInput, true, 1.0);
    } else {
      handled = triggerBindings(physicalInput, pData.isDown, pData.isDown ? 1.0 : 0.0);
    }
    
    return handled;
  }

  double get pinch {
    if (_pointers.length < 2) return 0.0;
    final pList = _pointers.values.toList();
    final p1 = pList[0];
    final p2 = pList[1];
    
    final currentDist = (p1.position - p2.position).distance;
    final prevDist = (p1.previousPosition - p2.previousPosition).distance;
    
    if (prevDist == 0) return 0.0;
    return currentDist / prevDist;
  }

  void update() {
    for (final p in _pointers.values) {
      p.resetFrame();
    }
    _cleanup();
  }

  void _cleanup() {
    final toRemove = <int>[];
    for (final p in _pointers.values) {
      if (!p.isDown && !p.updatedThisFrame) {
        toRemove.add(p.id);
      }
      p.updatedThisFrame = false;
    }
    for (final id in toRemove) {
      _pointers.remove(id);
    }
  }
}
