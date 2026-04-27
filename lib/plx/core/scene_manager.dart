import 'package:flutter/material.dart';
import 'game_scene.dart';
import '../input/input_manager.dart';

enum SceneTransitionState { idle, fadingOut, fadingIn }

class SceneManager extends ChangeNotifier {
  InputManager inputManager;
  
  SceneManager({required this.inputManager});

  GameScene? _activeScene;
  GameScene? _pendingScene;
  
  SceneTransitionState _state = SceneTransitionState.idle;
  double _progress = 0.0;
  double _duration = 0.5;

  GameScene? get activeScene => _activeScene;
  SceneTransitionState get state => _state;
  double get progress => _progress;

  void init(GameScene initialScene) {
    _activeScene = initialScene;
    _activeScene?.input = inputManager;
    _activeScene?.onInit();
    notifyListeners();
  }

  void update(double dt) {
    // Reset input flags for next frame
    //inputManager.update();
    switch(_state){
      case SceneTransitionState.idle:
        _activeScene?.update(dt);
        // Auto-detect scene change requests from the scene itself
        if (_activeScene!.nextScene != null) {
          changeScene(_activeScene!.nextScene!);
          _activeScene!.clearSceneRequest();
        }
        break;
      case SceneTransitionState.fadingOut:
        _progress += dt / _duration;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _performSwitch();
          _state = SceneTransitionState.fadingIn;
        }
        notifyListeners();
        break;
      case SceneTransitionState.fadingIn:
        _activeScene?.update(dt);
        _progress -= dt / _duration;
        if (_progress <= 0.0) {
          _progress = 0.0;
          _state = SceneTransitionState.idle;
        }
        notifyListeners();
        break;
    }
    notifyListeners();
  }

  void changeScene(GameScene scene, {double duration = 0.5}) {
    if (_state != SceneTransitionState.idle) return;
    _pendingScene = scene;
    _duration = duration;
    _state = SceneTransitionState.fadingOut;
    notifyListeners();
  }

  void _performSwitch() {
    _activeScene?.onClose();
    _activeScene = _pendingScene;
    _activeScene?.input = inputManager;
    _activeScene?.onInit();
    _pendingScene = null;
  }
}
