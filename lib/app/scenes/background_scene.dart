import 'package:exa_vortex/app/components/rotator.dart';
import 'package:exa_vortex/app/entities/background.dart';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx2d.dart';
import 'package:exa_vortex/plx/plx3d.dart';
import 'package:vector_math/vector_math.dart' as v32;

class BackgroundScene extends GameScene{
  //Resources
  late AudioHandler handler;
  late PlxFont font;
  //Components
  late AudioListener3D listener;
  late AudioSource3D song;
  late Rotator rotator;
  //Entities
  late World w1;
  late Text2D title;
  late Text2D titleShadow;
  late Background background;
  late Camera3D camera;
  @override
  Future<void> onLoad() async {
    handler = AudioHandler();
    await handler.preload('Song', '.assets/audio/shape_whirlwinds.ogg');
    font = await PlxFont.load('PressStart2P');
    return super.onLoad();
  }
  @override
  void onInit() {
    super.onInit();
    w1 = World();
    title = Text2D(
      name: 'GameTitle', 
      text: 'ExaVortex', 
      font: font,
      fontSize: 1
    );
    titleShadow = Text2D(
      name: 'GameTitleShadow', 
      text: 'ExaVortex', 
      font: font,
      fontSize: 1,
      color: Vector4(0, 0, 0, 1)
    );
    background = Background(name: 'BG', numSides: 6, radius: 1000);
    camera = Camera3D(name: 'Camera', world: w1);

    title.position = Vector2(-4.2,-0.3);
    titleShadow.position = Vector2(-4.27,-0.37);
    background.position = Vector3(0,0,0);
    camera.position = Vector3(0,0,5);
    camera.view?.far = 1000;

    listener = AudioListener3D();
    
    rotator = Rotator();
    rotator.speed = Vector3(0, 0, 1);
    rotator.minAngle = Vector3(-45, -45, double.negativeInfinity);
    rotator.maxAngle = Vector3(45, 45, double.infinity);
    
    camera.addComponent(listener);
    background.addComponent(rotator);
    
    w1.addChild(background);
    w1.addChild(titleShadow);
    w1.addChild(title);
    addEntity(camera);
    addEntity(w1);
    handler.playSoundtrack('Song', volume: 1);
  }

  @override
  void onPause() {
    handler.pauseSoundtrack();
    super.onPause();
  }

  @override
  void onResume() {
    handler.resumeSoundtrack();
    super.onResume();
  }

  @override
  void draw(PlxRenderer renderer) {
    final cb = background.colorPalette.first;
    renderer.setBackgroundColor(v32.Vector4(cb.x,cb.y,cb.z,cb.w));
    w1.draw(renderer);
    super.draw(renderer);
  }
  @override
  void dispose() {
    font.dispose();
    handler.dispose();
    super.dispose();
  }
}