import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exa_vortex/plx/plx.dart' hide Colors;
import 'package:exa_vortex/plx/plx3d.dart';
import 'package:exa_vortex/plx/plx2d.dart';

import 'testgame.dart'; // Reusing getCubeMesh and getCubeTexture

class InputTestScene extends GameScene {
  late World world;
  late Entity3D cube;
  late Camera3D camera;
  late Text2D helloW;
  late MeshRenderer renderM;
  late PlxFont font;

  @override
  Future<void> onLoad() async {
    font = await PlxFont.load('PressStart2P');
    return super.onLoad();
  }

  @override
  void dispose() {
    font.dispose();
    super.dispose();
  }
  
  @override
  void onInit() {
    world = World(name: 'MyWorld');
    camera = Camera3D(name: 'Camera', world: world);
    camera.view?.lensType = CameraLensType.orthographic;
    
    cube = Entity3D(name: 'InputControlledCube');
    final material = PlxMaterial(vertexShaderName: 'BaseTextureV', fragmentShaderName: 'BaseTextureF');
    material.setTexture(PlxShader.fragment, 'tex', getCubeTexture());
    renderM = MeshRenderer(material: material, opaque: false);
    
    helloW = Text2D(
      name: 'HWTEXT',
      text: 'Hello! ExaVortex Jijija',
      font: font,
      fontSize: 1, // Small scale for 2D in a 3D context or relative units
      color: Vector4(0, 1, 0.8, 1),
    );

    helloW.position = Vector2(-5, -5);
    helloW.rotation = radians(90);
    cube.position = Vector3(0, 0, 0);
    camera.position = Vector3(0, 0, 5);
    
    cube.addComponent(MeshComponent(getCubeMesh()));
    cube.addComponent(renderM);
    world.addChild(cube);
    world.addChild(helloW);
    addEntity(camera);
    addEntity(world);
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
    input.bindInput(PhysicalInput.mouse(MouseInput.leftButton), 'Drag');
    input.bindInput(PhysicalInput.touch(0), 'Drag');
    input.bindInput(PhysicalInput.touch(0), 'DragScale');
    // Mouse Move Binding (triggered by movement/hover)
    input.bindInput(PhysicalInput.mouse(MouseInput.unknown), 'MouseMove');
    input.bindInput(PhysicalInput.mouse(MouseInput.hover), 'MouseHover');
  }

  @override
  void update(double dt) {
    super.update(dt);
    double speed = 2.0;
    if (input.isActionTriggered('MoveUp')) cube.rotation = Vector3(cube.rotation.x - speed * dt, cube.rotation.y, cube.rotation.z);
    if (input.isActionTriggered('MoveDown')) cube.rotation = Vector3(cube.rotation.x + speed * dt, cube.rotation.y, cube.rotation.z);
    if (input.isActionTriggered('MoveLeft')) cube.rotation = Vector3(cube.rotation.x, cube.rotation.y - speed * dt, cube.rotation.z);
    if (input.isActionTriggered('MoveRight')) cube.rotation = Vector3(cube.rotation.x, cube.rotation.y + speed * dt, cube.rotation.z);
    if (input.wasActionTriggered('Reset')) cube.rotation = Vector3.zero();
    if (input.wasActionTriggered('SaveConfig')) InputConfig.saveConfig(input);
    if (input.wasActionTriggered('LoadConfig')) InputConfig.loadConfig(input);
    // Mouse/Touch Drag logic
    if (input.isActionTriggered('Drag')) {
      //debugPrint('Dragging at: ${cube.transform.modelMatrix}');
      input.cursor = CursorShape.move;
      final delta = input.pointerDelta;
      cube.rotation = Vector3(cube.rotation.x + delta.dy * 0.005, cube.rotation.y + delta.dx * 0.005, cube.rotation.z);
    } else if (input.isActionTriggered('MouseHover')) {
      //debugPrint('Hovering at: ${input.mouse.position.dx}, ${input.mouse.position.dy}');
    }
    // Mouse drag
    if (input.wasActionReleased('Drag')) {
      input.cursor = CursorShape.basic;
    }
    // Mouse Wheel Zoom
    final scroll = input.mouse.scrollDelta;
    if (scroll != 0) {
      double factor = scroll > 0 ? 0.95 : 1.05;
      cube.scale = cube.scale * factor;
    }

    if (input.isActionTriggered('DragScale')) {
      final pinch = input.touch.pinch;
      if (pinch!=0) cube.scale = cube.scale * pinch;
    }
    input.update();
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
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'PressStart2P'),
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
