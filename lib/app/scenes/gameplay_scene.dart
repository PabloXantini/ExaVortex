import 'package:exa_vortex/app/scenes/background_scene.dart';
import 'package:exa_vortex/plx/plx.dart';
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
    } else if (Device.isMobile){
      input.bindInput(PhysicalInput.touch(0), 'Back');
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
}