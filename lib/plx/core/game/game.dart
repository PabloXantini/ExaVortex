import 'package:exa_vortex/plx/graphics/renderer.dart';
import 'package:exa_vortex/plx/audio/plx_audio.dart';
import 'package:exa_vortex/plx/core/resources/resources.dart';
import 'package:exa_vortex/plx/core/scene/scene_manager.dart';
import 'package:exa_vortex/plx/core/scene/game_scene.dart';
import 'package:exa_vortex/plx/core/game/game_cache.dart';
import 'package:exa_vortex/plx/input/input_manager.dart';
import 'package:exa_vortex/plx/graphics/graphics.dart';
import 'package:exa_vortex/plx/core/utils/device.dart';
import 'package:exa_vortex/plx/core/utils/platform_hints.dart';
import 'package:flutter/widgets.dart';
import '../logger.dart';

class PlxGame {
  final GameScene initialScene;
  final GameCache? cache;
  
  late final PlxRenderer renderer = PlxGraphics.instance.createRenderer();
  late final PlxAssetManager assets = PlxAssetManager();
  late final SceneManager sceneManager = SceneManager(
    assetManager: assets, 
    cache: cache
  );
  
  // Global input manager
  final PlxInputManager input = PlxInputManager();
  
  bool _initialized = false;
  bool _wasPaused = false;
  
  PlxGame({required this.initialScene, this.cache});
  
  void init() {
    if(_initialized) return;
    AudioManager.instance.init();
    sceneManager.init(initialScene);
    _initialized = true;
  }
  
  void onTick(double dt) {
    if (dt > 0.1) dt = 0.1;
    input.update(); // Update global inputs
    sceneManager.update(dt);
    AudioManager.instance.update();
  }
  
  void onLifecycleStateChange(AppLifecycleState state) {
    PlxLogger.log('Lifecycle current state: ${state.name}');
    if(sceneManager.activeScene == null) return;
    bool shouldPause = false;
    switch(state){
      case AppLifecycleState.resumed:
        shouldPause = false;
        break;
      case AppLifecycleState.hidden:
        shouldPause = sceneManager.activeScene!.lifecycle.shouldPauseWhenHidden;
        break;
      case AppLifecycleState.paused:
        shouldPause = sceneManager.activeScene!.lifecycle.shouldPauseWhenHidden;
        break;
      case AppLifecycleState.inactive:
        shouldPause = sceneManager.activeScene!.lifecycle.shouldPauseWhenOffFocus;
        if(Device.isDesktop || PlxPlatform.minimized) {
          shouldPause = sceneManager.activeScene!.lifecycle.shouldPauseWhenHidden;
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
    if(shouldPause && !_wasPaused){
      PlxLogger.log('Pausing scene');
      sceneManager.activeScene!.onPause();
      _wasPaused = true;
    } else if(!shouldPause && _wasPaused && state != AppLifecycleState.detached){
      _wasPaused = false;
      PlxLogger.log('Resuming scene');
      sceneManager.activeScene!.onResume();
    }
  }
  
  void dispose() {
    sceneManager.dispose();
    renderer.dispose();
    assets.dispose();
    input.dispose();
    AudioManager.instance.dispose();
  }

  /// Called when the application is requested to close.
  /// Return true to allow closing, false to prevent it.
  Future<bool> onExit() async {
    if (sceneManager.activeScene != null) {
      return await sceneManager.activeScene!.onAppExit();
    }
    return true;
  }
}
