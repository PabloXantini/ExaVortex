import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../plx.dart';
import '../plx3d.dart';
import 'testgame.dart'; // Para reutilizar getCubeMesh y getCubeTexture

class SceneA extends GameScene {
  late Entity3D cube1;
  late Entity3D cube2;
  late Entity3D cameraEntity;
  late CameraView3D viewComponent;
  late PlxMaterial material1;
  late MeshRenderer rM;
  
  @override
  void onInit() {
    PlxLogger.message('Initializing Scene A', system: 'Scene');
    
    cameraEntity = Entity3D(name: 'Camera');
    cube1 = Entity3D(name: 'RedCube');
    cube2 = Entity3D(name: 'GreenCube');
    cameraEntity.position = Vector3(0, 0, 5);
    cube1.position = Vector3(-1.5, 0, 0);
    cube2.position = Vector3(1.5, 0, 0);
    
    viewComponent = CameraView3D(lens: CameraLensType.orthographic);
    cameraEntity.addComponent(viewComponent);

    material1 = PlxMaterial(vertexShaderName: 'BaseTextureV', fragmentShaderName: 'BaseTextureF');
    material1.setTexture(PlxShader.fragment, 'tex', getCubeTexture());

    rM = MeshRenderer(material: material1);

    cube1.addComponent(MeshComponent(getCubeMesh()));
    cube1.addComponent(rM);
    cube1.addComponent(RotatorComponent()..speedX = -0.5..speedY = 0.5);

    cube2.addComponent(MeshComponent(getCubeMesh()));
    cube2.addComponent(rM);
    cube2.addComponent(RotatorComponent()..speedX = 0.5..speedY = -0.5);

    addEntity(cameraEntity);
    addEntity(cube1);
    addEntity(cube2);

    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
  }

  @override
  void dispose() {
    material1.dispose();
    rM.dispose();
    super.dispose();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (input.wasActionTriggered('Switch')) {
      requestSceneChange(SceneB());
    }
  }

  @override
  void draw(PlxRenderer renderer) {
    final res = viewComponent.getResult(renderer.size.width, renderer.size.height);
    renderer.viewProjectionMatrix = res;
    super.draw(renderer);
  }
}

class SceneB extends GameScene {
  late Entity3D cube1;
  late Entity3D cube2;
  late Entity3D cameraEntity;
  late CameraView3D viewComponent;
  late PlxMaterial material1;
  late MeshRenderer rM;
  
  @override
  void onInit() {
    PlxLogger.message('Initializing Scene B', system: 'Scene');

    cameraEntity = Entity3D(name: 'Camera');
    cube1 = Entity3D(name: 'BlueCube');
    cube2 = Entity3D(name: 'YellowCube');
    cameraEntity.position = Vector3(0, 0, 7);
    cube1.position = Vector3(0, 1.5, 0);
    cube1.scale = Vector3.all(1.5);
    cube2.position = Vector3(0, -1.5, 0);
    cube2.scale = Vector3.all(0.5);

    viewComponent = CameraView3D(lens: CameraLensType.perspective);
    cameraEntity.addComponent(viewComponent);

    material1 = PlxMaterial(vertexShaderName: 'BaseTextureV', fragmentShaderName: 'BaseTextureF');
    material1.setTexture(PlxShader.fragment, 'tex', getCubeTexture());

    rM = MeshRenderer(material: material1);

    cube1.addComponent(MeshComponent(getCubeMesh()));
    cube1.addComponent(rM);
    cube1.addComponent(RotatorComponent()..speedX = -0.5..speedY = 0.5);
    
    cube2.addComponent(MeshComponent(getCubeMesh()));
    cube2.addComponent(rM);
    cube2.addComponent(RotatorComponent()..speedX = -0.5..speedY = 0.5);

    addEntity(cameraEntity);
    addEntity(cube1);
    addEntity(cube2);

    input.clearBindings();
    input.enableKeyboard();
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
  }

  @override
  void dispose() {
    material1.dispose();
    rM.dispose();
    super.dispose();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (input.wasActionTriggered('Switch')) {
      requestSceneChange(SceneA());
    }
  }

  @override
  void draw(PlxRenderer renderer) {
    final res = viewComponent.getResult(renderer.size.width, renderer.size.height);
    renderer.viewProjectionMatrix = res;
    super.draw(renderer);
  }
}

class TestSceneGame extends StatefulWidget {
  const TestSceneGame({super.key});

  @override
  State<TestSceneGame> createState() => _TestSceneGameState();
}

class _TestSceneGameState extends State<TestSceneGame> {
  late final SceneA _initialScene = SceneA();
  late final PlxGame _game = PlxGame(initialScene: _initialScene);

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          _initialScene.input.handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: PlxGameFrame(
          game: _game,
        ),
      ),
    );
  }
}
