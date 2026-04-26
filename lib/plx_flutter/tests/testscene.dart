import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../plx.dart';
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
    cameraEntity.position = Vector3(0, 0, 5);
    viewComponent = CameraView3D(lens: CameraLensType.orthographic);
    cameraEntity.addComponent(viewComponent);
    addEntity(cameraEntity);

    // Cubo Rojo
    cube1 = Entity3D(name: 'RedCube');
    cube1.position = Vector3(-1.5, 0, 0);
    final material1 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material1.setTexture('tex', getCubeTexture());
    cube1.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1));
    addEntity(cube1);

    // Cubo Verde
    cube2 = Entity3D(name: 'GreenCube');
    cube2.position = Vector3(1.5, 0, 0);
    final material2 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material2.setTexture('tex', getCubeTexture());
    cube2.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material2));
    addEntity(cube2);

    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
  }

  @override
  void update(double dt) {
    super.update(dt);
    cube1.rotation.y += dt;
    cube2.rotation.x += dt;
    
    if (inputManager.wasActionPressed('Switch')) {
      requestSceneChange(SceneB());
    }
    inputManager.update();
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
    cameraEntity.position = Vector3(0, 0, 7);
    viewComponent = CameraView3D(lens: CameraLensType.orthographic);
    cameraEntity.addComponent(viewComponent);
    addEntity(cameraEntity);

    // Cubo Azul (Grande)
    cube1 = Entity3D(name: 'BlueCube');
    cube1.position = Vector3(0, 1.5, 0);
    cube1.scale = Vector3.all(1.5);
    final material1 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material1.setTexture('tex', getCubeTexture());
    cube1.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1));
    addEntity(cube1);

    // Cubo Amarillo (Pequeño)
    cube2 = Entity3D(name: 'YellowCube');
    cube2.position = Vector3(0, -1.5, 0);
    cube2.scale = Vector3.all(0.5);
    final material2 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material2.setTexture('tex', getCubeTexture());
    cube2.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material2));
    addEntity(cube2);

    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
  }

  @override
  void update(double dt) {
    super.update(dt);
    cube1.rotation.z += dt * 2;
    cube2.rotation.y -= dt * 3;

    if (inputManager.wasActionPressed('Switch')) {
      requestSceneChange(SceneA());
    }
    inputManager.update();
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
          // El InputManager es un singleton o instancia en escena? 
          // En mi test puse uno por escena, así que necesito pasarlo.
          // Pero el InputManager que hice antes es un singleton.
          // Vamos a usar el singleton para que sea más fácil.
          InputManager().handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: PlxGame(
          initialScene: _initialScene,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // También podemos forzar el cambio desde afuera si tuviéramos acceso a la escena activa
          // Pero la idea es que sea la escena la que pida el cambio.
        },
        child: const Icon(Icons.swap_horiz),
      ),
    );
  }
}
