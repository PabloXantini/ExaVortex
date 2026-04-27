import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../plx.dart';
import '../plx3d.dart';
import 'testgame.dart'; // Para reutilizar getCubeMesh y getCubeTexture

class SceneA extends GameScene {
  late Entity3D cube1;
  late Entity3D cube2;
  late Entity3D cameraEntity;
  late CameraView3D viewComponent;
  
  final InputManager inputManager = InputManager();

  @override
  void onInit() {
    debugPrint('Initializing Scene A');
    
    cameraEntity = Entity3D(name: 'Camera');
    cube1 = Entity3D(name: 'RedCube');
    cube2 = Entity3D(name: 'GreenCube');
    cameraEntity.position = Vector3(0, 0, 5);
    cube1.position = Vector3(-1.5, 0, 0);
    cube2.position = Vector3(1.5, 0, 0);
    
    viewComponent = CameraView3D(lens: CameraLensType.orthographic);
    cameraEntity.addComponent(viewComponent);

    final material1 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material1.setTexture('tex', getCubeTexture());

    cube1.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1));
    cube1.addComponent(RotatorComponent()..speedX = -0.5..speedY = 0.5);

    cube2.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1));
    cube2.addComponent(RotatorComponent()..speedX = 0.5..speedY = -0.5);

    addEntity(cameraEntity);
    addEntity(cube1);
    addEntity(cube2);

    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (inputManager.wasActionPressed('Switch')) {
      requestSceneChange(SceneB());
    }
  }

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    final res = viewComponent.getResult(size.width, size.height);
    for (var entity in entities) {
      final rendererComp = entity.getComponent<MeshRenderer>();
      if (rendererComp != null) {
        rendererComp.viewProjectionMatrix = res;
      }
    }
    super.draw(renderer, canvas, size);
  }
}

class SceneB extends GameScene {
  late Entity3D cube1;
  late Entity3D cube2;
  late Entity3D cameraEntity;
  late CameraView3D viewComponent;
  
  final InputManager inputManager = InputManager();

  @override
  void onInit() {
    debugPrint('Initializing Scene B');

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

    final material1 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material1.setTexture('tex', getCubeTexture());

    cube1.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1));
    cube1.addComponent(RotatorComponent()..speedX = -0.5..speedY = 0.5);
    cube2.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1));
    cube2.addComponent(RotatorComponent()..speedX = -0.5..speedY = 0.5);

    addEntity(cameraEntity);
    addEntity(cube1);
    addEntity(cube2);

    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (inputManager.wasActionPressed('Switch')) {
      requestSceneChange(SceneA());
    }
  }

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    final res = viewComponent.getResult(size.width, size.height);
    for (var entity in entities) {
      final rendererComp = entity.getComponent<MeshRenderer>();
      if (rendererComp != null) {
        rendererComp.viewProjectionMatrix = res;
      }
    }
    super.draw(renderer, canvas, size);
  }
}

class TestSceneGame extends StatefulWidget {
  const TestSceneGame({super.key});

  @override
  State<TestSceneGame> createState() => _TestSceneGameState();
}

class _TestSceneGameState extends State<TestSceneGame> {
  late SceneA _initialScene;

  @override
  void initState() {
    super.initState();
    _initialScene = SceneA();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          InputManager().handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: PlxGame(
          initialScene: _initialScene,
        ),
      ),
    );
  }
}
