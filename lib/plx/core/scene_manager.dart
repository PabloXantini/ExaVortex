import 'package:flutter/material.dart';
import 'game_scene.dart';

enum SceneTransitionState { idle, fadingOut, loading, fadingIn }

class SceneManager extends ChangeNotifier {
  
  SceneManager(); 

  GameScene? _activeScene;
  GameScene? _pendingScene;
  
  SceneTransitionState _state = SceneTransitionState.idle;
  double _progress = 0.0;
  double _duration = 0.5;

  GameScene? get activeScene => _activeScene;
  SceneTransitionState get state => _state;
  double get progress => _progress;

  Future<void> init(GameScene initialScene) async {
    _activeScene = initialScene;
    await _activeScene?.onLoad();
    _activeScene?.onInit();
    notifyListeners();
  }

  void update(double dt) {
    switch(_state){
      case SceneTransitionState.idle:
        _activeScene?.update(dt);
        if (_activeScene?.nextScene != null) {
          changeScene(_activeScene!.nextScene!);
          _activeScene!.clearSceneRequest();
        }
        break;
      case SceneTransitionState.fadingOut:
        _progress += dt / _duration;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _state = SceneTransitionState.loading;
          _performSwitch();
        }
        break;
      case SceneTransitionState.fadingIn:
        _activeScene?.update(dt);
        _progress -= dt / _duration;
        if (_progress <= 0.0) {
          _progress = 0.0;
          _state = SceneTransitionState.idle;
        }
        break;
      default:
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

  Future<void> _performSwitch() async {
    // 1. Preload the new scene while the old one might still be in memory
    if (_pendingScene != null) {
      await _pendingScene!.onLoad();
    }    
    // 2. Now that the new scene is ready, close the old one and swap
    _activeScene?.onClose();
    _activeScene = _pendingScene;
    // 3. Initialize entities
    _activeScene?.onInit();
    _pendingScene = null;
    _state = SceneTransitionState.fadingIn;
    notifyListeners();
  }
}
