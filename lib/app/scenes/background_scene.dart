import 'package:exagon_plus/app/entities/background.dart';
import 'package:exagon_plus/plx/plx.dart';
import 'package:exagon_plus/plx/plx3d.dart';

class BackgroundScene extends GameScene{
  late World w1;
  late Background background;
  late Camera3D camera;
  @override
  void onInit() {
    w1 = World();
    background = Background(name: 'BG', numSides: 6);
    camera = Camera3D(name: 'Camera', world: w1);
    
    background.position = Vector3(0,0,0);
    camera.position = Vector3(0,0,5);
    w1.addChild(background);
    addEntity(camera);
    addEntity(w1);
  }
  @override
  void update(double dt) {
    background.rotation = background.rotation + Vector3(dt*0.5, dt*0.5, dt*2);
    super.update(dt);
  }
  @override
  void draw(PlxRenderer renderer) {
    w1.draw(renderer);
    super.draw(renderer);
  }
}