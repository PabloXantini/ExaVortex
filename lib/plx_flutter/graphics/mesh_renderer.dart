import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:exagon_plus/plx_flutter/core/core.dart';
import 'package:exagon_plus/plx_flutter/math/transform.dart';
import 'mesh.dart';
import 'material.dart';
import 'renderer.dart';
import 'type_adapter.dart';

class MeshRenderer extends Component {
  Mesh? mesh;
  GfxMaterial? material;

  // The projection/view matrix can be passed from the Scene or Camera entity.
  // For now, you can set it directly before drawing.
  Matrix4 viewProjectionMatrix = Matrix4.identity();

  MeshRenderer({this.mesh, this.material});

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    if (mesh == null || material == null || entity == null) return;

    final transform = entity!.getComponent<TransformUser>();
    if (transform != null) {
      // Compute MVP
      final mvpMatrix = viewProjectionMatrix * transform.modelMatrix;
      
      final transients = gpu.gpuContext.createHostBuffer();
      final mvpView = transients.emplace(float32Mat(mvpMatrix));
      
      // We assume your shader always uses 'FrameInfo' for the MVP matrix.
      // This can be customized if needed.
      material!.setUniform('FrameInfo', mvpView);
    }

    renderer.drawMesh(mesh!, material!);
  }
}
