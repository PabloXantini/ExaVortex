import 'package:flutter/material.dart';
import 'game_scene.dart';
import '../game_cache.dart';

enum SceneTransitionState { idle, fadingOut, loading, fadingIn }

class SceneManager extends ChangeNotifier {
  final GameCache cache;
  
  SceneManager({GameCache? cache}) : 
  cache = cache ?? const NonCache()
  ; 

  GameScene? _activeScene;
  GameScene? _pendingScene;
  
  SceneTransitionState _state = SceneTransitionState.loading;
  double _progress = 0.0;
  double _duration = 0.5;

  bool get isLoading => _activeScene == null || _state == SceneTransitionState.loading;
  bool get isTransitioning => _state != SceneTransitionState.idle;
  GameScene? get activeScene => _activeScene;
  SceneTransitionState get state => _state;
  double get progress => _progress;

  Future<void> init(GameScene initialScene) async {
    _state = SceneTransitionState.loading;
    _activeScene = initialScene;
    await _loadScene(_activeScene!);
    _initializeScene(_activeScene!);
    _state = SceneTransitionState.idle;
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

  @override
  void dispose(){
    _activeScene?.onClose();
    _activeScene?.dispose();
    _pendingScene?.dispose();
    _activeScene = null;
    _pendingScene = null;
    super.dispose();
  }

  Future<void> _performSwitch() async {
    // 1. Load the new scene
    await _loadScene(_pendingScene!);
    // 2. Close the old scene and swap
    _activeScene?.onClose();
    _activeScene?.dispose();
    _activeScene = _pendingScene;
    _initializeScene(_activeScene!);
    _pendingScene = null;
    _state = SceneTransitionState.fadingIn;
    notifyListeners();
  }
  Future<void> _loadScene(GameScene scene) async {
    if(scene.wasLoaded) return;
    scene.cache = cache;
    await scene.onLoad();
    scene.loaded = true;
  }
  void _initializeScene(GameScene scene) {
    if(scene.wasInitialized) return;
    scene.onInit();
    scene.initalized = true;
  }
}
