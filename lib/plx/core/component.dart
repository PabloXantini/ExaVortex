import '../graphics/renderer.dart';
import 'entity.dart';

abstract class Component {
  Entity? entity;
  bool active = true;

  /// Called when the component is added to the entity.
  void onAdded() {}
  
  /// Called when the component is removed from the entity.
  void onRemoved() {}
  
  /// Called before the entity update call. Use this to override the entity update.
  void update(double dt) {}

  /// Called after the entity draw call. Use this to draw on top of the entity.
  void draw(PlxRenderer renderer) {}
  
  /// Called when the component is being destroyed.
  /// Use this to release native resources or remove listeners.
  void dispose() {
    entity = null;
  }
}
