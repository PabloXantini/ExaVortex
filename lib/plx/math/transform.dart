import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/component.dart';

class TransformUser extends Component {
  final Vector3 _position = Vector3.zero();
  final Vector3 _rotation = Vector3.zero(); // Euler angles
  final Vector3 _scale = Vector3.all(1.0);

  bool isDirty = true;
  bool _isGlobalDirty = true;

  final Matrix4 _localModelMatrix = Matrix4.identity();
  final Matrix4 _globalModelMatrix = Matrix4.identity();

  Vector3 get position => _position;
  set position(Vector3 value) {
    if(position == value) return;
    _position.setFrom(value);
    setDirty();
  }
  Vector3 get rotation => _rotation;
  set rotation(Vector3 value) {
    if(rotation == value) return;
    _rotation.setFrom(value);
    setDirty();
  }
  Vector3 get scale => _scale;
  set scale(Vector3 value) {
    if(scale == value) return;
    _scale.setFrom(value);
    setDirty();
  }

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
      _localModelMatrix.translateByVector3(_position);
      _localModelMatrix.rotateX(_rotation.x);
      _localModelMatrix.rotateY(_rotation.y);
      _localModelMatrix.rotateZ(_rotation.z);
      _localModelMatrix.scaleByVector3(_scale);
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
}
