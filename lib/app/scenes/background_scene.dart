import 'package:exa_vortex/app/components/rotator.dart';
import 'package:exa_vortex/app/entities/background.dart';
import 'package:exa_vortex/app/entities/exa_text.dart';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx3d.dart';

class BackgroundScene extends GameScene{
  //Resources
  late AudioHandler handler;
  late PlxFont font;
  late PlxMaterial material1;
  late MeshRenderer rM;
  //Components
  late AudioListener3D listener;
  late AudioSource3D song;
  late Rotator rotator;
  //Entities
  late World w1;
  late ExaVortexTitle gameTitle;
  late ExaVortexTitle startText;
  late Background background;
  late Camera3D camera;
  @override
  Future<void> onLoad() async {
    handler = AudioHandler();
    await handler.preload('Song', '.assets/audio/shape_whirlwinds.ogg');
    font = await PlxFont.load('PressStart2P');
    await PlxPlatform.toggleFullScreen(true);
    return super.onLoad();
  }
  @override
  void onInit() {
    super.onInit();
    //Creating the material for the background
    material1 = PlxGraphics.instance.createMaterial(vertexShaderName: 'BaseTextureV', fragmentShaderName: 'BaseTextureF');
    //Creating a simple texture for the background
    material1.setTexture(PlxShader.fragment, 'tex', PlxGraphics.instance.createTextureFromPixels(1, 1, [0xFFFFFFFF]));
    //Creating a reusable mesh renderer
    rM = MeshRenderer(material: material1);
    //Scene Settings
    w1 = World();
    gameTitle = ExaVortexTitle(text: 'ExaVortex', font: font, fontSize: 0.8);
    
    //Game Flow before setup things
    String playTextMessage = "";
    if(Device.isDesktop){
      playTextMessage = "Press Space to start";
    } else if (Device.isMobile){
      playTextMessage = "Tap to start";
    }

    startText = ExaVortexTitle(text: playTextMessage, font: font, fontSize: 0.2); 
    
    background = Background(name: 'BG', numSides: 6, radius: 1000);
    camera = Camera3D(name: 'Camera', world: w1);

    gameTitle.position = Vector2(0,0);
    startText.position = Vector2(0,-0.5);
    startText.setZLayer(0.02);
    background.position = Vector3(0,0,0);
    camera.position = Vector3(0,0,5);
    camera.view?.far = 1000;

    listener = AudioListener3D();
    
    rotator = Rotator();
    rotator.speed = Vector3(0, 0, 1);
    rotator.minAngle = Vector3(-45, -45, double.negativeInfinity);
    rotator.maxAngle = Vector3(45, 45, double.infinity);
    
    camera.addComponent(listener);
    background.addComponent(rM);
    background.addComponent(rotator);
    
    w1.addChild(background);
    w1.addChild(gameTitle);
    w1.addChild(startText);
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
    renderer.setBackgroundColor(Vector4(cb.x,cb.y,cb.z,cb.w));
    w1.draw(renderer);
    super.draw(renderer);
  }
  @override
  void dispose() {
    font.dispose();
    handler.dispose();
    material1.dispose();
    rM.dispose();
    super.dispose();
  }
}