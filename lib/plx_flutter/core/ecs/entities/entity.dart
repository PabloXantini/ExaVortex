import 'dart:ui';
import '../../../graphics/renderer.dart';
import '../../game_scene.dart';
import '../components/component.dart';

class Entity {
  String name;
  bool active = true;
  GameScene? scene;
  
  final List<Component> _components = [];

  Entity({this.name = 'Entity'});

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

  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    for (var comp in _components) {
      if (comp.active) {
        comp.draw(renderer, canvas, size);
      }
    }
  }
}
