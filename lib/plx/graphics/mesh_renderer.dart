import 'package:exa_vortex/plx/core/plx_core.dart';
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'mesh_component.dart';
import 'material.dart';
import 'renderer.dart';

class MeshRenderer extends Component {
  PlxMaterial? material;
  bool opaque = true;

  MeshRenderer({this.material, this.opaque = true});

  @override
  void draw(PlxRenderer renderer) {
    if (material == null || entity == null) return;
    final meshComponent = entity!.getComponent<MeshComponent>();
    if (meshComponent == null || meshComponent.mesh == null) return;

    double depth = 0.0;
    final instance = material!.use(PlxShader.vertex);
    final transform = entity!.getComponent<TransformUser>();
    if (transform != null) {
      // Compute MVP.
      final Matrix4 mvpMatrix = renderer.viewProjectionMatrix * transform.modelMatrix;
      // Calculate depth (Z distance from camera in clip space).
      final Vector4 centerClip = mvpMatrix.transform(Vector4(0, 0, 0, 1));
      depth = centerClip.z;
        instance.setMatrix4('ModelInfo', mvpMatrix);
      }
    renderer.submit(meshComponent.mesh!, material!, opaque: opaque, depth: depth, instance: instance);
  }

  @override
  void dispose() {
    material = null;
    super.dispose();
  }
}
