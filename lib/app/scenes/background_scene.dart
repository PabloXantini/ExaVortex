import 'package:exa_vortex/app/components/rotator.dart';
import 'package:exa_vortex/app/entities/background.dart';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx3d.dart';

class BackgroundScene extends GameScene{
  late World3D w1;
  late Background background;
  late Camera3D camera;
  late Rotator rotator;
  @override
  void onInit() {
    w1 = World3D();
    background = Background(name: 'BG', numSides: 6);
    camera = Camera3D(name: 'Camera', world: w1);
    
    background.position = Vector3(0,0,0);
    camera.position = Vector3(0,0,5);

    rotator = Rotator();
    rotator.speed = Vector3(0.5, -0.5, 2);
    rotator.minAngle = Vector3(-45, -45, double.negativeInfinity);
    rotator.maxAngle = Vector3(45, 45, double.infinity);
    w1.addComponent(rotator);
    w1.addChild(background);
    addEntity(camera);
    addEntity(w1);
  }
  @override
  void update(double dt) {
    //background.rotation = background.rotation + Vector3(dt*0.5, dt*0.5, dt*2);
    super.update(dt);
  }
  @override
  void draw(PlxRenderer renderer) {
    w1.draw(renderer);
    super.draw(renderer);
  }
}