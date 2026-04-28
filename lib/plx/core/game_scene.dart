import 'package:exa_vortex/plx/core/plx_core.dart';
import 'package:exa_vortex/plx/graphics/renderer.dart';

abstract class GameScene {
  final InputManager input = InputManager();
  final List<Entity> entities = [];
  GameScene? _nextScene;

  GameScene? get nextScene => _nextScene;

  void requestSceneChange(GameScene scene) {
    _nextScene = scene;
  }

  void clearSceneRequest() {
    _nextScene = null;
  }

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
