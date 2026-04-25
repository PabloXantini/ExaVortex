import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../plx.dart'; // Importa toda la abstracción que creamos

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
  late MeshRenderer rendererComponent;
  late RotatorComponent rotator = RotatorComponent();

  @override
  void onInit() {
    // 1. Instanciamos la entidad 3D
    cubeEntity = Entity3D(name: 'SpinningCube');
    
    // 2. Le damos una posición en el mundo (Z = -5 para que la cámara lo vea)
    cubeEntity.position = Vector3(0, 0, -5);

    // 3. Creamos el material y configuramos la textura
    final material = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    material.setTexture('tex', getCubeTexture());

    // 4. Creamos el componente de renderizado y se lo añadimos
    rendererComponent = MeshRenderer(mesh: getCubeMesh(), material: material);
    cubeEntity.addComponent(rendererComponent);

    // 5. Le añadimos un comportamiento (rotar con el tiempo)
    rotator = RotatorComponent()
      ..speedX = -0.5
      ..speedY = 0.5;
    cubeEntity.addComponent(rotator);

    // Añadimos la entidad a la escena
    addEntity(cubeEntity);
  }

  @override
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {
    // Calculamos la cámara (proyección) basándonos en el tamaño actual de la pantalla
    final aspect = size.width / size.height;
    final projection = Matrix4.identity();
    setPerspectiveMatrix(projection, radians(60), aspect, 0.01, 100);

    // Le pasamos la matriz de la cámara al componente de renderizado antes de que se dibuje
    rendererComponent.viewProjectionMatrix = projection;

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
      appBar: AppBar(title: const Text('ECS Cube Engine Demo')),
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
