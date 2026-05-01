import 'package:exa_vortex/plx/math/transform.dart';
import 'package:exa_vortex/plx/scene/3d/entity_3d.dart';
import 'package:exa_vortex/plx/scene/view.dart';
import 'package:exa_vortex/plx/scene/world.dart';
import 'package:vector_math/vector_math_64.dart';

enum CameraLensType {
  perspective,
  orthographic
}

class CameraView3D extends PlxView {
  CameraLensType lensType;
  Vector3 cameraPosition;
  Vector3 cameraFocusPosition;
  Vector3 cameraUp;
  // lens parameters
  double far = 100;
  // lens parameters: perspective lens
  double fov = 60;
  double pNear = 0.1;
  // lens parameters: orthographic lens
  double orthographicSize = 5;
  double oNear = -100; 

  bool _isViewDirty = true;
  bool _isProjectionDirty = true;  
  double _lastWidth = 0;
  double _lastHeight = 0;

  Matrix4 _projection = Matrix4.identity();
  Matrix4 _view = Matrix4.identity();

  CameraView3D({
    CameraLensType? lens,
    Vector3? position,
    Vector3? focus,
    Vector3? up,
  })  : lensType = lens ?? CameraLensType.perspective,
        cameraPosition = position ?? Vector3.zero(),
        cameraFocusPosition = focus ?? Vector3.zero(),
        cameraUp = up ?? Vector3(0, 1, 0);

  void lookAt(Vector3 position, Vector3 target, Vector3 up) {
    cameraPosition.setFrom(position);
    cameraFocusPosition.setFrom(target);
    cameraUp.setFrom(up);
    _isViewDirty = true;
  }

  Matrix4 getProjection(double w, double h) {
    if (w != _lastWidth || h != _lastHeight) {
      _isProjectionDirty = true;
      _lastWidth = w;
      _lastHeight = h;
    }

    if (_isProjectionDirty) {
      _projection = Matrix4.identity();
      final aspect = w/h;
      switch (lensType) {
        case CameraLensType.perspective:
          setPerspectiveMatrix(_projection, radians(fov), aspect, pNear, far);
          break;
        case CameraLensType.orthographic:
          final s = orthographicSize;
          setOrthographicMatrix(_projection, -s * aspect, s * aspect, -s, s, oNear, far);
          break;
      }
      _isProjectionDirty = false;
    }
    return _projection;
  }

  Matrix4 get view {
    if (_isViewDirty) {
      _view = Matrix4.identity();
      if (cameraPosition != cameraFocusPosition) {
        setViewMatrix(_view, cameraPosition, cameraFocusPosition, cameraUp);
      }
      _isViewDirty = false;
    }
    return _view;
  }

  @override
  Matrix4 getResult(double w, double h) => getProjection(w, h) * view;

  @override
  void update(double dt) {
    super.update(dt);
    // sync if entity has transform
    final transform = entity?.getComponent<TransformUser>();
    if (transform != null && transform.position != cameraPosition) {
      cameraPosition.setFrom(transform.position);
      _isViewDirty = true;
    }
  }
}

class Camera3D extends Entity3D{
  World? world;
  CameraView3D? view;
  Camera3D({super.name = 'Camera3D', required this.world}){
    view = CameraView3D(lens: CameraLensType.perspective);
    addComponent(view!);
    world?.view = view;
  }
}