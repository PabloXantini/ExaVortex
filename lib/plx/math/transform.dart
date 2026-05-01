import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/component.dart';

class TransformUser extends Component {
  Vector3 position = Vector3.zero();
  Vector3 rotation = Vector3.zero(); // Euler angles
  Vector3 scale = Vector3.all(1.0);

  bool isDirty = true;
  bool _isGlobalDirty = true;

  final Matrix4 _localModelMatrix = Matrix4.identity();
  final Matrix4 _globalModelMatrix = Matrix4.identity();

  final Vector3 _lastPosition = Vector3.zero();
  final Vector3 _lastRotation = Vector3.zero();
  final Vector3 _lastScale = Vector3.all(1.0);

  void setDirty() {
    isDirty = true;
    _setGlobalDirty();
  }

  void _setGlobalDirty() {
    if (_isGlobalDirty) return;
    _isGlobalDirty = true;
    if (entity != null) {
      for (var child in entity!.children) {
        child.getComponent<TransformUser>()?._setGlobalDirty();
      }
    }
  }

  Matrix4 get modelMatrix {
    if (isDirty) {
      _localModelMatrix.setIdentity();
      _localModelMatrix.translateByVector3(position);
      _localModelMatrix.rotateX(rotation.x);
      _localModelMatrix.rotateY(rotation.y);
      _localModelMatrix.rotateZ(rotation.z);
      _localModelMatrix.scaleByVector3(scale);
      isDirty = false;
      _isGlobalDirty = true;
    }

    if (_isGlobalDirty) {
      final parentTransform = entity?.parent?.getComponent<TransformUser>();
      if (parentTransform != null) {
        _globalModelMatrix.setFrom(parentTransform.modelMatrix);
        _globalModelMatrix.multiply(_localModelMatrix);
      } else {
        _globalModelMatrix.setFrom(_localModelMatrix);
      }
      _isGlobalDirty = false;
    }
    return _globalModelMatrix;
  }

  @override
  void update(double dt) {
    if (_lastPosition != position || _lastRotation != rotation || _lastScale != scale) {
      setDirty();
      _lastPosition.setFrom(position);
      _lastRotation.setFrom(rotation);
      _lastScale.setFrom(scale);
    }
  }
}
