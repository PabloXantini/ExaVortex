import 'package:vector_math/vector_math_64.dart';
import '../../core/entity.dart';
import '../../math/transform.dart';

class Entity2D extends Entity {
  late final TransformUser transform;

  Entity2D({super.name = 'Entity2D'}) {
    transform = TransformUser();
    addComponent(transform);
  }

  Vector2 get position => Vector2(transform.position.x, transform.position.y);
  set position(Vector2 value) {
    transform.position = Vector3(value.x, value.y, transform.position.z);
  }

  double get rotation => transform.rotation.z;
  set rotation(double value) {
    transform.rotation = Vector3(transform.rotation.x, transform.rotation.y, value);
  }

  Vector2 get scale => Vector2(transform.scale.x, transform.scale.y);
  set scale(Vector2 value) {
    transform.scale = Vector3(value.x, value.y, transform.scale.z);
  }

  double get zLayer => transform.position.z;
  void setZLayer(double z) {
    transform.position = Vector3(transform.position.x, transform.position.y, z);
  }
}
