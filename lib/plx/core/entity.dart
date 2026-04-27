import '../graphics/renderer.dart';
import 'game_scene.dart';
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
  }

  void draw(PlxRenderer renderer) {
    for (var comp in _components) {
      if (comp.active) comp.draw(renderer);
    }
    for (var e in _children){
      if (e.active) e.draw(renderer);
    }
  }
}
