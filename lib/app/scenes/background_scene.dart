import 'package:exagon_plus/app/entities/background.dart';
import 'package:exagon_plus/plx/plx.dart';
import 'package:exagon_plus/plx/plx3d.dart';

class BackgroundScene extends GameScene{
  late Background background;
  late Camera3D camera;
  @override
  void onInit() {
    background = Background(name: 'BG', numSides: 6);
    camera = Camera3D(name: 'Camera');
    
    background.position = Vector3(0,0,0);
    camera.position = Vector3(0,0,5);
        
    addEntity(camera);
    addEntity(background);
  }
  @override
  void update(double dt) {
    background.rotation = background.rotation + Vector3(dt*0.5, dt*0.5, dt*2);
    super.update(dt);
  }
  @override
  void draw(PlxRenderer renderer) {
    final res = camera.view?.getResult(renderer.size.width, renderer.size.height);
    for (var entity in entities) {
      final rendererComp = entity.getComponent<MeshRenderer>();
      if (rendererComp != null) {
        rendererComp.viewProjectionMatrix = res!;
      }
    }
    super.draw(renderer);
  }
}