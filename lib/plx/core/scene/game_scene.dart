import 'package:exa_vortex/plx/core/game/game_lifecycle.dart';
import 'package:exa_vortex/plx/core/plx_core.dart';
import 'package:exa_vortex/plx/core/resources/resources.dart';
import 'package:exa_vortex/plx/graphics/renderer.dart';
import 'package:exa_vortex/plx/input/plx_input.dart';
import 'package:flutter/widgets.dart';

abstract class GameScene {
  GameCache? _cache;
  // Flags
  bool _loaded = false;
  bool _initialized = false;
  // Dependencies
  final PlxLifecyclePolicy lifecycle = PlxLifecyclePolicy();
  final PlxInputManager input = PlxInputManager();
  late PlxAssetManager asset;
  final List<Entity> entities = [];
  GameScene? _nextScene;
  // UI overlay notifier
  final PlxUINotifier uiNotifier = PlxUINotifier();

  GameScene({GameCache? cache}) : _cache = cache;

  set initalized(bool value) => _initialized = value;
  set loaded(bool value) => _loaded = value;
  set cache(GameCache value) => _cache = value;

  bool get wasLoaded => _loaded;
  bool get wasInitialized => _initialized;
  GameCache get cache => _cache ?? const NonCache();
  GameScene? get nextScene => _nextScene;

  void requestSceneChange(GameScene scene) {
    _nextScene = scene;
  }

  void clearSceneRequest() {
    _nextScene = null;
  }

  /// Signals the UI layer to rebuild. Call this from [update] or game logic
  /// whenever data displayed in [buildUI] has changed.
  void refreshUI() => uiNotifier.notify();

  /// Returns the list of Flutter widgets to render as overlay layers on top
  /// of the game canvas. Each widget in the list is an independent layer
  /// placed inside a full-screen [Stack].
  ///
  /// Override this in your scene to build HUDs, menus, or any Flutter UI.
  /// Return an empty list (default) to render no overlay.
  List<Widget> buildUI(BuildContext context) => const [];

  /// Asynchronous preloading of assets (fonts, textures, audio).
  /// Do not instantiate Materials or Entities here, only use `await`.
  Future<void> onLoad() async {}

  /// Synchronous initialization of entities, components and materials.
  /// Called automatically after `onLoad` finishes. All assets are guaranteed to be loaded.
  void onInit() {}

  void onClose() {}

  /// Called when the application is requested to close.
  /// Return true to allow closing, false to prevent it.
  Future<bool> onAppExit() async {
    return true;
  }

  void onPause() {}
  
  void onResume() {}
  
  void update(double dt) {
    for (var entity in entities) {
      if (entity.active) entity.update(dt);
    }
  }

  void draw(PlxRenderer renderer) {
    for (var entity in entities) {
      if (entity.active) entity.draw(renderer);
    }
  }

  void addEntity(Entity entity) {
    entities.add(entity);
    entity.scene = this;
  }

  void removeEntity(Entity entity) {
    entities.remove(entity);
    entity.scene = null;
  }

  /// Disposes of the scene and all its entities.
  void dispose() {
    final entitiesCopy = List<Entity>.of(entities);
    for (var entity in entitiesCopy) {
      entity.dispose();
    }
    entities.clear();
    uiNotifier.dispose();
    _loaded = false;
    _initialized = false;
    _cache = null;
    _nextScene = null;
  }
}
