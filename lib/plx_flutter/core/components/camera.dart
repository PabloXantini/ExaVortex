import 'package:exagon_plus/plx_flutter/core/components/component.dart';
import 'package:exagon_plus/plx_flutter/core/components/transform.dart';
import 'package:vector_math/vector_math_64.dart';

enum CameraLensType {
  perspective,
  orthographic
}

class CameraView3D extends Component {
  CameraLensType lensType;
  Vector3 cameraPosition;
  Vector3 cameraFocusPosition;
  Vector3 cameraUp;

  // lens parameters: perspective lens
  double fov = 60;
  double pNear = 0.1;
  double far = 100;

  // lens parameters: orthographic lens
  double orthographicSize = 5;
  double oNear = -100; 

  bool isViewDirty = true;
  bool isProjectionDirty = true;
  
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
    isViewDirty = true;
  }

  Matrix4 getProjection(double w, double h) {
    if (w != _lastWidth || h != _lastHeight) {
      isProjectionDirty = true;
      _lastWidth = w;
      _lastHeight = h;
    }

    if (isProjectionDirty) {
      _projection = Matrix4.identity();
      switch (lensType) {
        case CameraLensType.perspective:
          setPerspectiveMatrix(_projection, radians(fov), w / h, pNear, far);
          break;
        case CameraLensType.orthographic:
          double aspect = w / h;
          double left = -(orthographicSize * aspect);
          double right = -left;
          double bottom = -orthographicSize;
          double top = orthographicSize;
          setOrthographicMatrix(_projection, left, right, bottom, top, oNear, 100);
          break;
      }
      isProjectionDirty = false;
    }
    return _projection;
  }

  Matrix4 get view {
    // sync if entity has transform
    if (entity != null) {
      final transform = entity!.getComponent<TransformUser>();
      if (transform != null && transform.position != cameraPosition) {
        cameraPosition.setFrom(transform.position);
        isViewDirty = true;
      }
    }
    if (isViewDirty) {
      _view = Matrix4.identity();
      if (cameraPosition != cameraFocusPosition) {
        setViewMatrix(_view, cameraPosition, cameraFocusPosition, cameraUp);
      }
      isViewDirty = false;
    }
    return _view;
  }
}
