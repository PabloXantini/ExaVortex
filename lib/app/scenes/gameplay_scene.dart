import 'package:exa_vortex/app/scenes/background_scene.dart';
import 'package:exa_vortex/plx/plx.dart' hide Colors;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameplayScene extends GameScene{
  @override
  Future<void> onLoad() {
    // TODO: implement onLoad
    return super.onLoad();
  }
  @override
  void onInit() {
    // Input Config
    input.enableKeyboard();
    input.enableMouse();
    input.enableTouch();
    input.clearBindings();
    if(Device.isDesktop){
      input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.escape), 'Back');
    }
    super.onInit();
  }
  @override
  void update(double dt) {
    super.update(dt);
    if(input.isActionTriggered('Back')){
      requestSceneChange(BackgroundScene());
    }
  }
  @override
  List<Widget> buildUI(BuildContext context) {

    return [
      Positioned(
        top: 20,
        left: 20,
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) =>
                states.contains(WidgetState.hovered) ? Colors.yellow : Colors.white),
            shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
          ),
          onPressed: () {
            requestSceneChange(BackgroundScene());
          }, 
          child: const Text(
            '<<Back',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 36,
              color: Colors.white,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
              decorationThickness: 2,
            ),
          ),
        ),
      )
    ];
  }
}