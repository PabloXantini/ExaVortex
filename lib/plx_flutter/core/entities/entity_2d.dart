import 'package:vector_math/vector_math_64.dart';
import 'entity.dart';
import '../components/transform.dart';

class Entity2D extends Entity {
  late final TransformUser transform;

  Entity2D({super.name = 'Entity2D'}) {
    transform = TransformUser();
    addComponent(transform);
  }

  Vector2 get position => Vector2(transform.position.x, transform.position.y);
  set position(Vector2 value) {
    transform.position.x = value.x;
    transform.position.y = value.y;
    transform.isDirty = true;
  }

  double get rotation => transform.rotation.z;
  set rotation(double value) {
    transform.rotation.z = value;
    transform.isDirty = true;
  }

  Vector2 get scale => Vector2(transform.scale.x, transform.scale.y);
  set scale(Vector2 value) {
    transform.scale.x = value.x;
    transform.scale.y = value.y;
    transform.isDirty = true;
  }
}
