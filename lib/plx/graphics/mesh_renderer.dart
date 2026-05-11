import 'package:exa_vortex/plx/core/plx_core.dart';
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'mesh.dart';
import 'material.dart';
import 'renderer.dart';

class MeshRenderer extends Component {
  Mesh? mesh;
  GfxMaterial? material;
  bool opaque = true;
  Matrix4 viewProjectionMatrix = Matrix4.identity();

  MeshRenderer({this.mesh, this.material, this.opaque = true});

  @override
  void draw(PlxRenderer renderer) {
    if (mesh == null || material == null || entity == null) return;

    double depth = 0.0;
    Matrix4? mvpMatrix;
    final transform = entity!.getComponent<TransformUser>();
    if (transform != null) {
      // Compute MVP
      mvpMatrix = viewProjectionMatrix * transform.modelMatrix;
      // Calculate depth (Z distance from camera in clip space)
      final Vector4 centerClip = mvpMatrix!.transform(Vector4(0, 0, 0, 1));
      depth = centerClip.z;
      material?.setMatrix4(GfxShader.vertex, 'ModelInfo', mvpMatrix);
    }
    
    renderer.submitMesh(mesh!, material!, opaque: opaque, depth: depth);
  }
}
