import 'dart:ui';
import '../graphics/renderer.dart';
import 'ecs/entities/entity.dart';

abstract class GameScene {
  final List<Entity> entities = [];

  void onInit() {}
  void onClose() {}
  void show() {}
  
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
