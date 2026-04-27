import 'dart:ui';

import 'package:exagon_plus/app/entities/background.dart';
import 'package:exagon_plus/plx/plx.dart';
import 'package:exagon_plus/plx/plx3d.dart';

class BackgroundScene extends GameScene{
  late Background background;
  late Entity3D camera;
  late CameraView3D view;
  @override
  void onInit() {
    background = Background(name: 'main', numSides: 5);
    camera = Entity3D(name: 'Camera');
    
    background.position = Vector3(0,0,0);
    camera.position = Vector3(0,0,5);
    
    //Camera setup
    view = CameraView3D(lens: CameraLensType.perspective);
    camera.addComponent(view);
    
    addEntity(camera);
    addEntity(background);
  }
  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    final res = view.getResult(size.width, size.height);
    for (var entity in entities) {
      final rendererComp = entity.getComponent<MeshRenderer>();
      if (rendererComp != null) {
        rendererComp.viewProjectionMatrix = res;
      }
    }
    super.draw(renderer, canvas, size);
  }
}