import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exa_vortex/plx/plx.dart' hide Colors;
import 'package:exa_vortex/plx/plx3d.dart';

import 'testgame.dart';

class TransitionScene1 extends GameScene {
  late PlxTexture cubeTex;
  late Entity3D cube1;
  late Entity3D cube2;
  late Entity3D cameraEntity;
  late PlxMaterial material1;

  @override
  Future<void> onLoad() async {
    cubeTex = await asset.loadTexture('TrollFace', '.assets/textures/jijija.png');
  }

  @override
  void dispose() {
    material1.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    cameraEntity = Entity3D(name: 'Camera');
    cube1 = Entity3D(name: 'Cube1');
    cube2 = Entity3D(name: 'Cube2');
    cube1.position = Vector3(-2, 0, -5);
    cube2.position = Vector3(5, 0, -10);
    cube2.scale = Vector3.all(2);
    cameraEntity.position = Vector3(0, 0, 5);
    cameraEntity.addComponent(CameraView3D(lens: CameraLensType.perspective));

    material1 = PlxMaterial(vertexShaderName: 'BaseTextureV', fragmentShaderName: 'BaseTextureF');
    material1.setTexture(PlxShader.fragment, 'tex', cubeTex);

    cube1.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1, opaque: false));
    cube2.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1, opaque: false));
    cube1.addComponent(RotatorComponent()..speedX = 0.0..speedY=2);

    addEntity(cameraEntity);
    addEntity(cube1);
    addEntity(cube2);
    
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
    input.bindInput(PhysicalInput.touch(0), 'Switch');
  }

  @override
  void update(double dt) {
    super.update(dt);
    Vector3 rot = cube1.rotation;
    cube1.rotation = Vector3(rot.x, rot.y, rot.z+dt*2); 
    if (input.wasActionTriggered('Switch')) {
      requestSceneChange(TransitionScene2());
    }
    input.update();
  }

  @override
  void draw(PlxRenderer renderer) {
    final view = cameraEntity.getComponent<CameraView3D>();
    if (view != null) {
      final res = view.getResult(renderer.size.width, renderer.size.height);
      cube1.getComponent<MeshRenderer>()?.viewProjectionMatrix = res;
      cube2.getComponent<MeshRenderer>()?.viewProjectionMatrix = res;
    }
    super.draw(renderer);
  }
}

class TransitionScene2 extends GameScene {
  late Entity3D cube2;
  late Entity3D cameraEntity;
  late PlxMaterial material;
  
  @override
  void dispose() {
    material.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    cameraEntity = Entity3D(name: 'Camera');
    cameraEntity.position = Vector3(0, 0, 5);
    cameraEntity.addComponent(CameraView3D(lens: CameraLensType.orthographic));
    addEntity(cameraEntity);

    cube2 = Entity3D(name: 'Cube2');
    cube2.scale = Vector3.all(1.5);
    material = PlxMaterial(vertexShaderName: 'BaseTextureV', fragmentShaderName: 'BaseTextureF');
    material.setTexture(PlxShader.fragment, 'tex', getCubeTexture());
    cube2.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material, opaque: false));
    cube2.addComponent(RotatorComponent()..speedX = 3.0..speedY=0);

    addEntity(cube2);

    // USANDO COMPONENTE para volver a la escena 1 después de 3 segundos
    cube2.addComponent(SceneTransition(
      targetScene: TransitionScene1(),
      delay: 3.0,
      duration: 1.0,
    ));
  }

  @override
  void draw(PlxRenderer renderer) {
    final view = cameraEntity.getComponent<CameraView3D>();
    if (view != null) {
      final res = view.getResult(renderer.size.width, renderer.size.height);
      cube2.getComponent<MeshRenderer>()?.viewProjectionMatrix = res;
    }
    super.draw(renderer);
  }
}

class TestScene2Game extends StatefulWidget {
  const TestScene2Game({super.key});

  @override
  State<TestScene2Game> createState() => _TestScene2GameState();
}

class _TestScene2GameState extends State<TestScene2Game> {
  late final TransitionScene1 _scene = TransitionScene1();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlxGame(
        initialScene: _scene,
        transitionBuilder: (context, alpha, state) {
          // Ejemplo de UI de transición limpia
          return IgnorePointer(
            child: Container(
              color: Colors.black.withValues(alpha: alpha),
              child: Center(
                child: Opacity(
                  opacity: alpha,
                  child: Text(
                    state == SceneTransitionState.fadingOut ? 'LOADING...' : 'READY',
                    style: const TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 4),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
