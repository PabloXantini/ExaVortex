import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../plx.dart';
import 'testgame.dart'; // Reusing getCubeMesh and getCubeTexture

class InputTestScene extends GameScene {
  late Entity3D cubeEntity;
  late Entity3D cameraEntity;
  late MeshRenderer renderComponent;
  late CameraView3D viewComponent;
  
  final InputManager inputManager = InputManager();

  @override
  void onInit() {
    // Basic setup
    cubeEntity = Entity3D(name: 'InputControlledCube');
    cameraEntity = Entity3D(name: 'Camera');
    
    cubeEntity.position = Vector3(0, 0, 0);
    cameraEntity.position = Vector3(0, 0, 5);
    
    final material = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material.setTexture('tex', getCubeTexture());
    
    renderComponent = MeshRenderer(mesh: getCubeMesh(), material: material);
    cubeEntity.addComponent(renderComponent);
    
    viewComponent = CameraView3D(lens: CameraLensType.orthographic);
    cameraEntity.addComponent(viewComponent);
    
    addEntity(cameraEntity);
    addEntity(cubeEntity);

    // Input Setup
    inputManager.clearBindings();
    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowUp), 'MoveUp');
    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowDown), 'MoveDown');
    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowLeft), 'MoveLeft');
    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowRight), 'MoveRight');
    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Reset');
    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.keyS), 'SaveConfig');
    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.keyL), 'LoadConfig');
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply inputs to cube rotation
    final transform = cubeEntity.getComponent<TransformUser>();
    if (transform != null) {
      double speed = 2.0;
      if (inputManager.isActionPressed('MoveUp')) transform.rotation.x -= speed * dt;
      if (inputManager.isActionPressed('MoveDown')) transform.rotation.x += speed * dt;
      if (inputManager.isActionPressed('MoveLeft')) transform.rotation.y -= speed * dt;
      if (inputManager.isActionPressed('MoveRight')) transform.rotation.y += speed * dt;
      
      if (inputManager.wasActionPressed('Reset')) {
        transform.rotation = Vector3.zero();
      }
      
      if (inputManager.wasActionPressed('SaveConfig')) {
        InputConfig.saveConfig(inputManager);
      }
      if (inputManager.wasActionPressed('LoadConfig')) {
        InputConfig.loadConfig(inputManager);
      }
      
      transform.isDirty = true;
    }
    
    // reset single frame flags
    inputManager.update();
  }

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    final res = viewComponent.getResult(size.width, size.height);
    renderComponent.viewProjectionMatrix = res;
    super.draw(renderer, canvas, size);
  }
}

class TestInputGame extends StatefulWidget {
  const TestInputGame({super.key});

  @override
  State<TestInputGame> createState() => _TestInputGameState();
}

class _TestInputGameState extends State<TestInputGame> {
  final InputTestScene _scene = InputTestScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Keyboard event listener wrapper
          Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              final handled = _scene.inputManager.handleKeyEvent(event);
              return handled ? KeyEventResult.handled : KeyEventResult.ignored;
            },
            child: PlxGame(
              initialScene: _scene,
            ),
          ),
          
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black54,
              child: const Text(
                'Use Arrow Keys to rotate the cube\n'
                'Press SPACE to reset rotation\n'
                'Press S to save bindings\n'
                'Press L to load bindings',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
