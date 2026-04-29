import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exa_vortex/plx/plx.dart' hide Colors;
import 'package:exa_vortex/plx/plx3d.dart';


import 'testgame.dart'; // Reusing getCubeMesh and getCubeTexture

class InputTestScene extends GameScene {
  late Entity3D cubeEntity;
  late Entity3D cameraEntity;
  late MeshRenderer renderComponent;
  late CameraView3D viewComponent;
  
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
    input.clearBindings();
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowUp), 'MoveUp');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowDown), 'MoveDown');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowLeft), 'MoveLeft');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowRight), 'MoveRight');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Reset');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.keyS), 'SaveConfig');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.keyL), 'LoadConfig');

    // Drag Bindings: Mouse Left Click (0) and Touch (0)
    input.bindInput(PhysicalInput.mouse(MouseButton.left), 'Drag');
    input.bindInput(PhysicalInput.touch(0), 'Drag');
    input.bindInput(PhysicalInput.touch(0), 'DragScale');
    // Mouse Move Binding (triggered by movement/hover)
    input.bindInput(PhysicalInput.mouse(MouseButton.unknown), 'MouseMove');
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Apply inputs to cube rotation
    final transform = cubeEntity.getComponent<TransformUser>();
    if (transform != null) {
      double speed = 2.0;
      if (input.isActionPressed('MoveUp')) transform.rotation.x -= speed * dt;
      if (input.isActionPressed('MoveDown')) transform.rotation.x += speed * dt;
      if (input.isActionPressed('MoveLeft')) transform.rotation.y -= speed * dt;
      if (input.isActionPressed('MoveRight')) transform.rotation.y += speed * dt;
      
      if (input.wasActionPressed('Reset')) {
        transform.rotation = Vector3.zero();
      }
      
      if (input.wasActionPressed('SaveConfig')) InputConfig.saveConfig(input);
      if (input.wasActionPressed('LoadConfig')) InputConfig.loadConfig(input);

      // Mouse/Touch Drag logic
      if (input.isActionPressed('Drag')) {
        input.cursor = CursorShape.move;
        final delta = input.pointerDelta;
        debugPrint('Drag: ${delta.dx}, ${delta.dy}');
        transform.rotation.y += delta.dx * 0.005;
        transform.rotation.x += delta.dy * 0.005;
      }
      
      // Fixed: Now correctly detects when the button is released
      if (input.wasActionReleased('Drag')) {
        input.cursor = CursorShape.basic;
      }

      // Mouse Move Action
      if (input.isActionPressed('MouseMove')) {
        // You can access input.mouse.position or input.mouse.delta here
      }

      // Mouse Wheel Zoom
      final scroll = input.mouse.scrollDelta;
      if (scroll != 0) {
        double factor = scroll > 0 ? 0.95 : 1.05;
        cubeEntity.scale = cubeEntity.scale * factor;
      }

      if (input.isActionPressed('DragScale')) {
        final pinch = input.touch.pinch;
        if (pinch!=0) cubeEntity.scale = cubeEntity.scale * pinch;
      }
      transform.isDirty = true;
    }
    // reset single frame flags
    input.update();
  }

  @override
  void draw(PlxRenderer renderer) {
    final res = viewComponent.getResult(renderer.size.width, renderer.size.height);
    renderComponent.viewProjectionMatrix = res;
    super.draw(renderer);
  }
}

class TestInputGame extends StatefulWidget {
  const TestInputGame({super.key});

  @override
  State<TestInputGame> createState() => _TestInputGameState();
}

class _TestInputGameState extends State<TestInputGame> {
  late final InputTestScene _scene = InputTestScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PlxGame(initialScene: _scene),
          Positioned(
            top: 20,
            left: 20,
            child: ListenableBuilder(
              listenable: _scene.input,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black54,
                  child: Text(
                    'Use Arrow Keys to rotate the cube\n'
                    'Press SPACE to reset rotation\n'
                    'Press S to save bindings\n'
                    'Press L to load bindings\n'
                    'DRAG with Mouse or Touch to rotate\n'
                    'Pointers: ${_scene.input.pointerCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
