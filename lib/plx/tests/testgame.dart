import 'package:flutter/material.dart';

import 'package:exagon_plus/plx/plx.dart' hide Colors; // Importa toda la abstracción que creamos
import 'package:exagon_plus/plx/plx3d.dart';

// Malla del Cubo
Mesh getCubeMesh() {
  final format = VertexFormat('CubeFormat', const [
    VertexAttribute(AttributeUsage.position, 3),
    VertexAttribute(AttributeUsage.uv, 2),
    VertexAttribute(AttributeUsage.color, 4),
  ]);

  final vertices = <double>[
    // X, Y, Z,       U, V,     R, G, B, A
    -1, -1, -1,       0, 0,     1, 0, 0, 1,
     1, -1, -1,       1, 0,     0, 1, 0, 1,
     1,  1, -1,       1, 1,     0, 0, 1, 1,
    -1,  1, -1,       0, 1,     0, 0, 0, 1,
    -1, -1,  1,       0, 0,     0, 1, 1, 1,
     1, -1,  1,       1, 0,     1, 0, 1, 1,
     1,  1,  1,       1, 1,     1, 1, 0, 1,
    -1,  1,  1,       0, 1,     1, 1, 1, 1,
  ];

  return Mesh.create(format, vertices, indices16: [
    0, 1, 3, 3, 1, 2, // Frontal
    1, 5, 2, 2, 5, 6, // Derecha
    5, 4, 6, 6, 4, 7, // Trasera
    4, 0, 7, 7, 0, 3, // Izquierda
    3, 2, 7, 7, 2, 6, // Arriba
    4, 5, 0, 0, 5, 1, // Abajo
  ]);
}

// Textura del Cubo
GfxTexture getCubeTexture() {
  return GfxTexture.fromPixels(5, 5, [
    0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
    0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
    0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
    0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
    0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
  ]);
}

/// Creamos un componente personalizado para rotar el cubo usando dt
class RotatorComponent extends Component {
  double speedX = 1.0;
  double speedY = 1.0;

  @override
  void update(double dt) {
    if (entity == null) return;
    final transform = entity!.getComponent<TransformUser>();
    if (transform != null) {
      transform.rotation.x += speedX * dt;
      transform.rotation.y += speedY * dt;
      transform.isDirty = true;
    }
  }
}

/// Definimos nuestra escena principal implementando GameScene
class CubeDemoScene extends GameScene {
  late Entity3D cubeEntity;
  late Entity3D cameraEntity;
  late MeshRenderer renderComponent;
  late CameraView3D viewComponent;
  late RotatorComponent rotator = RotatorComponent();

  @override
  void onInit() {
    // 1. Entities instantiation
    cubeEntity = Entity3D(name: 'SpinningCube');
    cameraEntity = Entity3D(name: 'Camera');
    // 2. Set position
    cubeEntity.position = Vector3(0, 0, 0); // for the view from camera
    cameraEntity.position = Vector3(0, 0, 5); 
    // 3. Material setup
    final material = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material.setTexture('tex', getCubeTexture());
    // 4. Create the mesh renderer
    renderComponent = MeshRenderer(mesh: getCubeMesh(), material: material);
    // Cube:
    rotator = RotatorComponent()
      ..speedX = -0.5
      ..speedY = 0.5;
    cubeEntity.addComponent(renderComponent);
    cubeEntity.addComponent(rotator);
    addEntity(cameraEntity);
    // Camera:
    viewComponent = CameraView3D(lens: CameraLensType.orthographic);
    cameraEntity.addComponent(viewComponent);
    addEntity(cubeEntity);
  }

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    // Calculamos la cámara (proyección) basándonos en el tamaño actual de la pantalla
    final res = viewComponent.getResult(size.width, size.height);
    // Le pasamos la matriz de la cámara al componente de renderizado antes de que se dibuje
    renderComponent.viewProjectionMatrix = res;

    // Ejecuta el draw de todas las entidades y componentes base
    super.draw(renderer, canvas, size);
  }
}

/// UI Widget
class TestGame extends StatefulWidget {
  const TestGame({super.key});

  @override
  State<TestGame> createState() => _TestGameState();
}

class _TestGameState extends State<TestGame> {
  final CubeDemoScene _scene = CubeDemoScene();
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Capa base: El motor 3D
          PlxGame(
            initialScene: _scene,
          ),
          
          // Capa superior: UI de Flutter
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Speed X:', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _scene.rotator.speedX,
                          min: -5,
                          max: 5,
                          onChanged: (val) {
                            setState(() {
                              _scene.rotator.speedX = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Speed Y:', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _scene.rotator.speedY,
                          min: -5,
                          max: 5,
                          onChanged: (val) {
                            setState(() {
                              _scene.rotator.speedY = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Scale:   ', style: TextStyle(color: Colors.white)),
                      Expanded(
                        child: Slider(
                          value: _scale,
                          min: 0.1,
                          max: 3.0,
                          onChanged: (val) {
                            setState(() {
                              _scale = val;
                              _scene.cubeEntity.scale = Vector3.all(_scale);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
