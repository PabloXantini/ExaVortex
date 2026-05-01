import 'package:exa_vortex/plx/core/component.dart';
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/audio/plx_audio.dart';
import 'package:exa_vortex/plx/scene/3d/camera/camera.dart';

class AudioListener3D extends Component {
  Vector3 velocity = Vector3.zero();

  @override
  void update(double dt) {
    final cameraView = entity?.getComponent<CameraView3D>();
    final transform = entity?.getComponent<TransformUser>();

    if (cameraView != null) {
      AudioManager.instance.mod3dListener(
        cameraView.cameraPosition,
        cameraView.cameraFocusPosition,
        cameraView.cameraUp,
        velocity: velocity,
      );
    } else if (transform != null) {
      // Fallback a posición de la entidad
      AudioManager.instance.mod3dListener(
        transform.position,
        transform.position + Vector3(0, 0, 1), // default lookAt
        Vector3(0, 1, 0), // default up
        velocity: velocity,
      );
    }
  }
}

