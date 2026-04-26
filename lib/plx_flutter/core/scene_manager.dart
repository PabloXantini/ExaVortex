import 'package:flutter/material.dart';
import 'game_scene.dart';

enum SceneTransitionState { none, fadingOut, fadingIn }

class SceneManager extends ChangeNotifier {
  static final SceneManager _instance = SceneManager._internal();
  factory SceneManager() => _instance;
  SceneManager._internal();

  GameScene? _activeScene;
  GameScene? _pendingScene;
  
  SceneTransitionState _state = SceneTransitionState.none;
  double _alpha = 0.0;
  double _duration = 0.5;

  GameScene? get activeScene => _activeScene;
  SceneTransitionState get state => _state;
  double get alpha => _alpha;

  void init(GameScene initialScene) {
    _activeScene = initialScene;
    _activeScene?.onInit();
    notifyListeners();
  }

  void update(double dt) {
    if (_state == SceneTransitionState.none) {
      if (_activeScene != null) {
        _activeScene!.update(dt);
        
        // Auto-detect scene change requests from the scene itself
        if (_activeScene!.nextScene != null) {
          changeScene(_activeScene!.nextScene!);
          _activeScene!.clearSceneRequest();
        }
      }
    } else if (_state == SceneTransitionState.fadingOut) {
      _alpha += dt / _duration;
      if (_alpha >= 1.0) {
        _alpha = 1.0;
        _performSwitch();
        _state = SceneTransitionState.fadingIn;
      }
      notifyListeners();
    } else if (_state == SceneTransitionState.fadingIn) {
      _activeScene?.update(dt);
      _alpha -= dt / _duration;
      if (_alpha <= 0.0) {
        _alpha = 0.0;
        _state = SceneTransitionState.none;
      }
      notifyListeners();
    }
  }

  void changeScene(GameScene scene, {double duration = 0.5}) {
    if (_state != SceneTransitionState.none) return;
    _pendingScene = scene;
    _duration = duration;
    _state = SceneTransitionState.fadingOut;
    notifyListeners();
  }

  void _performSwitch() {
    _activeScene?.onClose();
    _activeScene = _pendingScene;
    _activeScene?.onInit();
    _pendingScene = null;
  }
}
