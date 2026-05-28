import 'package:exa_vortex/plx/graphics/renderer.dart';
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/graphics/rendering/renderer.dart';
import 'package:exa_vortex/plx/graphics/components/mesh_component.dart';
import 'package:exa_vortex/plx/graphics/material/material.dart';

class MeshRenderer extends Renderer {
  bool opaque = true;

  MeshRenderer({super.material, this.opaque = true});

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
}
