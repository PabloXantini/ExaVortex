import 'dart:ui';
import '../graphics/renderer.dart';
import 'entities/entity.dart';

abstract class GameScene {
  final List<Entity> entities = [];
  GameScene? _nextScene;

  GameScene? get nextScene => _nextScene;

  void requestSceneChange(GameScene scene) {
    _nextScene = scene;
    // We could call SceneManager().changeScene(scene) directly here,
    // but keeping the property allows the SceneManager to detect it in its update loop
    // if the user prefers that pattern.
  }

  void clearSceneRequest() {
    _nextScene = null;
  }

  void onInit() {}
  void onClose() {}
  
  void update(double dt) {
    for (var entity in entities) {
      if (entity.active) {
        entity.update(dt);
      }
    }
  }

  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    for (var entity in entities) {
      if (entity.active) {
        entity.draw(renderer, canvas, size);
      }
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
