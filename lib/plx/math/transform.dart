import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/component.dart';

class TransformUser extends Component {
  Vector3 position = Vector3.zero();
  Vector3 rotation = Vector3.zero(); // Euler angles
  Vector3 scale = Vector3.all(1.0);

  bool isDirty = true;
  Matrix4 _modelMatrix = Matrix4.identity();

  Matrix4 get modelMatrix {
    if (isDirty) {
      _modelMatrix = Matrix4.identity()
        ..translateByVector3(position)
        ..rotateX(rotation.x)
        ..rotateY(rotation.y)
        ..rotateZ(rotation.z)
        ..scaleByVector3(scale);
      isDirty = false;
    }
    return _modelMatrix;
  }

  @override
  void update(double dt) {
    // If you need animations or specific update logic, it goes here.
  }
}
