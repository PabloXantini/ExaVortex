import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/component.dart';
import 'package:exa_vortex/plx/core/entity.dart';

class TransformUser extends Component {
  final Vector3 _position = Vector3.zero();
  final Vector3 _rotation = Vector3.zero(); // Euler angles
  final Vector3 _scale = Vector3.all(1.0);

  bool _localDirty = true;
  bool _globalDirty = true;

  final Matrix4 _localModelMatrix = Matrix4.identity();
  final Matrix4 _globalModelMatrix = Matrix4.identity();

  Vector3 get position => _position;
  set position(Vector3 value) {
    if (_position == value) return;
    _position.setFrom(value);
    _setDirty();
  }

  Vector3 get rotation => _rotation;
  set rotation(Vector3 value) {
    if (_rotation == value) return;
    _rotation.setFrom(value);
    _setDirty();
  }

  Vector3 get scale => _scale;
  set scale(Vector3 value) {
    if (_scale == value) return;
    _scale.setFrom(value);
    _setDirty();
  }

  void _setDirty() {
    _localDirty = true;
    _setGlobalDirty();
  }

  void _setGlobalDirty() {
    if (_globalDirty) return;
    _globalDirty = true;
    if (entity != null) {
      for (var child in entity!.children) {
        child.getComponent<TransformUser>()?._setGlobalDirty();
        if (child.getComponent<TransformUser>() == null) {
          _propagateDirty(child);
        }
      }
    }
  }

  static void _propagateDirty(Entity entity) {
    for (var child in entity.children) {
      final t = child.getComponent<TransformUser>();
      if (t != null) {
        t._setGlobalDirty();
      } else {
        _propagateDirty(child);
      }
    }
  }

  Matrix4 get modelMatrix {
    if (_localDirty) {
      _localModelMatrix.setIdentity();
      _localModelMatrix.translateByVector3(_position);
      _localModelMatrix.rotateX(_rotation.x);
      _localModelMatrix.rotateY(_rotation.y);
      _localModelMatrix.rotateZ(_rotation.z);
      _localModelMatrix.scaleByVector3(_scale);
      _localDirty = false;
      _globalDirty = true;
    }

    if (_globalDirty) {
      final parentTransform = entity?.parent?.getComponent<TransformUser>();
      if (parentTransform != null) {
        _globalModelMatrix.setFrom(parentTransform.modelMatrix);
        _globalModelMatrix.multiply(_localModelMatrix);
      } else {
        _globalModelMatrix.setFrom(_localModelMatrix);
      }
      _globalDirty = false;
    }
    return _globalModelMatrix.clone();
  }

  // Backwards compatibility for the test scene if it uses isDirty directly
  bool get dirty => _localDirty;
  set dirty(bool value) {
    if (value) _setDirty();
  }
}
