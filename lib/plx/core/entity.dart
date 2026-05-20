import '../graphics/renderer.dart';
import 'scene/game_scene.dart';
import 'component.dart';

class Entity {
  Entity? parent;
  String name;
  bool active = true;
  GameScene? scene;
  
  final List<Entity> _children = [];
  final List<Component> _components = [];

  Entity({this.name = 'Entity'});

  List<Entity> get children => _children;

  bool isSuper(Entity entity){
    Entity? ce;
    while(ce != null){
      if(ce == entity) return true;
      ce = entity.parent;
    }
    return false;
  }

  void addChild(Entity entity){
    assert(entity!=this, 'You dirty!, this entity cannot be his own son!');
    assert(!isSuper(entity), 'You dirty!, ${entity.name} super to $name!');
    _children.add(entity);
    entity.parent = this;
  }

  void removeChild(Entity entity){
    _children.remove(entity);
    entity.parent = null;
  }

  void addComponent(Component component) {
    _components.add(component);
    component.entity = this;
    component.onAdded();
  }

  void removeComponent(Component component) {
    if (_components.remove(component)) {
      component.onRemoved();
      component.entity = null;
    }
  }

  T? getComponent<T extends Component>() {
    for (var comp in _components) {
      if (comp is T) return comp;
    }
    return null;
  }

  void update(double dt) {
    for (var comp in _components) {
      if (comp.active) {
        comp.update(dt);
      }
    }
    for (var e in _children){
      if (e.active) e.update(dt);
    }
  }

  void draw(PlxRenderer renderer) {
    for (var comp in _components) {
      if (comp.active) comp.draw(renderer);
    }
    for (var e in _children){
      if (e.active) e.draw(renderer);
    }
  }

  /// Disposes of all components and children entities recursively.
  void dispose() {
    // Dispose components and clear them.
    for (var comp in _components) {
      comp.dispose();
    }
    _components.clear();
    // Dispose children creating a copy first, then clear them.
    final childrenCopy = List<Entity>.of(_children);
    for (var child in childrenCopy) {
      child.dispose();
    }
    _children.clear();
    // Remove from parent and scene.
    parent?.removeChild(this);
    scene?.removeEntity(this);
    parent = null;
    scene = null;
  }
}
