import 'package:exa_vortex/plx/input/input_manager.dart';
import 'package:flutter/material.dart';

class PlxInputLayer extends StatelessWidget {
  final FocusNode focusNode;
  final PlxInputManager inputManager;
  final Widget child;
  
  const PlxInputLayer(
    {super.key,
    required this.focusNode,
    required this.inputManager,
    required this.child}
  );

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapInside: (_)=>focusNode.requestFocus(),
      onTapOutside: (_)=>focusNode.unfocus(),
      child: Focus(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (node, event){
          final handled = inputManager.handleKeyEvent(event);
          return handled ? KeyEventResult.handled : KeyEventResult.ignored;
        },
        child: ListenableBuilder(
          listenable: inputManager, 
          builder: (context, _) {
            return MouseRegion(
              cursor: inputManager.cursor,
              child: Listener(
                onPointerDown: (event) => inputManager.handlePointerEvent(event),
                onPointerUp: (event) => inputManager.handlePointerEvent(event),
                onPointerMove: (event) => inputManager.handlePointerEvent(event),
                onPointerHover: (event) => inputManager.handlePointerEvent(event),
                onPointerCancel: (event) => inputManager.handlePointerEvent(event),
                onPointerSignal: (event) => inputManager.handlePointerSignal(event),
                child: child,
              ),
            );
          }
        )
      )
    );
  }
}