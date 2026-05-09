import 'package:exa_vortex/plx/core/plx_core.dart';
import 'package:exa_vortex/plx/graphics/renderer.dart';
import 'package:exa_vortex/plx/input/plx_input.dart';
import 'resources.dart';

abstract class GameScene {
  GameCache? _cache;
  GameCache get cache => _cache ?? const NonCache();
  set cache(GameCache value) => _cache = value;

  final InputManager input = InputManager();
  final AssetManager assets = AssetManager();
  final List<Entity> entities = [];
  GameScene? _nextScene;

  GameScene({GameCache? cache}) : _cache = cache;

  GameScene? get nextScene => _nextScene;

  void requestSceneChange(GameScene scene) {
    _nextScene = scene;
  }

  void clearSceneRequest() {
    _nextScene = null;
  }

  /// Asynchronous preloading of assets (fonts, textures, audio).
  /// Do not instantiate Materials or Entities here, only use `await`.
  Future<void> onLoad() async {}

  /// Synchronous initialization of entities, components and materials.
  /// Called automatically after `onLoad` finishes. All assets are guaranteed to be loaded.
  void onInit() {}

  void onClose() {}
  
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
}
