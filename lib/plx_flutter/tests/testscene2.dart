import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../plx.dart';
import 'testgame.dart';

class TransitionScene1 extends GameScene {
  late Entity3D cube1;
  late Entity3D cameraEntity;
  
  final InputManager inputManager = InputManager();

  @override
  void onInit() {
    cameraEntity = Entity3D(name: 'Camera');
    cameraEntity.position = Vector3(0, 0, 5);
    cameraEntity.addComponent(CameraView3D(lens: CameraLensType.orthographic));
    addEntity(cameraEntity);

    cube1 = Entity3D(name: 'Cube1');
    final material1 = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material1.setTexture('tex', getCubeTexture());
    cube1.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material1));
    addEntity(cube1);

    inputManager.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Switch');
  }

  @override
  void update(double dt) {
    super.update(dt);
    cube1.rotation.y += dt * 2;
    
    if (inputManager.wasActionPressed('Switch')) {
      // Uso manual del SceneManager a través de la escena
      requestSceneChange(TransitionScene2());
    }
    inputManager.update();
  }

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    final view = cameraEntity.getComponent<CameraView3D>();
    if (view != null) {
      final res = view.getResult(size.width, size.height);
      cube1.getComponent<MeshRenderer>()?.viewProjectionMatrix = res;
    }
    super.draw(renderer, canvas, size);
  }
}

class TransitionScene2 extends GameScene {
  late Entity3D cube2;
  late Entity3D cameraEntity;
  
  @override
  void onInit() {
    cameraEntity = Entity3D(name: 'Camera');
    cameraEntity.position = Vector3(0, 0, 5);
    cameraEntity.addComponent(CameraView3D(lens: CameraLensType.orthographic));
    addEntity(cameraEntity);

    cube2 = Entity3D(name: 'Cube2');
    cube2.scale = Vector3.all(1.5);
    final material = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material.setTexture('tex', getCubeTexture());
    cube2.addComponent(MeshRenderer(mesh: getCubeMesh(), material: material));
    addEntity(cube2);

    // USANDO COMPONENTE para volver a la escena 1 después de 3 segundos
    cube2.addComponent(SceneTransition(
      targetScene: TransitionScene1(),
      delay: 3.0,
      duration: 1.0,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    cube2.rotation.x += dt * 3;
  }

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    final view = cameraEntity.getComponent<CameraView3D>();
    if (view != null) {
      final res = view.getResult(size.width, size.height);
      cube2.getComponent<MeshRenderer>()?.viewProjectionMatrix = res;
    }
    super.draw(renderer, canvas, size);
  }
}

class TestScene2Game extends StatelessWidget {
  const TestScene2Game({super.key});

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
          initialScene: TransitionScene1(),
          transitionBuilder: (context, alpha, state) {
            // Ejemplo de UI de transición limpia
            return IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(alpha),
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
      ),
    );
  }
}
