import 'package:vector_math/vector_math_64.dart';
import '../../core/entity.dart';
import '../../math/transform.dart';

class Entity3D extends Entity {
  late final TransformUser transform;

  Entity3D({super.name = 'Entity3D'}) {
    transform = TransformUser();
    addComponent(transform);
  }

  Vector3 get position => transform.position;
  set position(Vector3 value) {
    transform.position = value;
    transform.isDirty = true;
  }

  Vector3 get rotation => transform.rotation;
  set rotation(Vector3 value) {
    transform.rotation = value;
    transform.isDirty = true;
  }

  Vector3 get scale => transform.scale;
  set scale(Vector3 value) {
    transform.scale = value;
    transform.isDirty = true;
  }
}
