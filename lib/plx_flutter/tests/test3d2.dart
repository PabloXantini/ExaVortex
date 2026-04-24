import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

import '../graphics/api.dart';

Mesh? _cubeMesh;
GfxTexture? _cubeTexture;

Mesh getCubeMesh() {
  if (_cubeMesh != null) return _cubeMesh!;
  
  final format = VertexFormat('CubeFormat', const [
    VertexAttribute(AttributeUsage.position, 3),
    VertexAttribute(AttributeUsage.uv, 2),
    VertexAttribute(AttributeUsage.color, 4),
  ]);

  final vertices = [
    CustomVertex()..set(AttributeUsage.position, [-1, -1, -1])..set(AttributeUsage.uv, [0, 0])..set(AttributeUsage.color, [1, 0, 0, 1]),
    CustomVertex()..set(AttributeUsage.position, [1, -1, -1])..set(AttributeUsage.uv, [1, 0])..set(AttributeUsage.color, [0, 1, 0, 1]),
    CustomVertex()..set(AttributeUsage.position, [1, 1, -1])..set(AttributeUsage.uv, [1, 1])..set(AttributeUsage.color, [0, 0, 1, 1]),
    CustomVertex()..set(AttributeUsage.position, [-1, 1, -1])..set(AttributeUsage.uv, [0, 1])..set(AttributeUsage.color, [0, 0, 0, 1]),
    CustomVertex()..set(AttributeUsage.position, [-1, -1, 1])..set(AttributeUsage.uv, [0, 0])..set(AttributeUsage.color, [0, 1, 1, 1]),
    CustomVertex()..set(AttributeUsage.position, [1, -1, 1])..set(AttributeUsage.uv, [1, 0])..set(AttributeUsage.color, [1, 0, 1, 1]),
    CustomVertex()..set(AttributeUsage.position, [1, 1, 1])..set(AttributeUsage.uv, [1, 1])..set(AttributeUsage.color, [1, 1, 0, 1]),
    CustomVertex()..set(AttributeUsage.position, [-1, 1, 1])..set(AttributeUsage.uv, [0, 1])..set(AttributeUsage.color, [1, 1, 1, 1]),
  ];

  _cubeMesh = Mesh.create(format, vertices, indices16: [
    0, 1, 3, 3, 1, 2, // Frontal
    1, 5, 2, 2, 5, 6, // Derecha
    5, 4, 6, 6, 4, 7, // Trasera
    4, 0, 7, 7, 0, 3, // Izquierda
    3, 2, 7, 7, 2, 6, // Arriba
    4, 5, 0, 0, 5, 1, // Abajo
  ]);

  return _cubeMesh!;
}

GfxTexture getCubeTexture() {
  if (_cubeTexture != null) return _cubeTexture!;
  
  _cubeTexture = GfxTexture.fromPixels(5, 5, [
    0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, //
    0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, //
    0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, //
    0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, //
    0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, //
  ]);
  return _cubeTexture!;
}

class Canvas3D extends CustomPainter {
  Canvas3D(this.time, this.seedX, this.seedY, this.scale, this.depthClearValue);

  double time;
  double seedX;
  double seedY;
  double scale;
  double depthClearValue;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. We instanciate the renderer facade and start the frame
    final renderer = PlxRenderer();
    renderer.beginFrame(size.width.toInt(), size.height.toInt(), depthClearValue: depthClearValue);
    renderer.setDepthState(writeEnable: true, compareOp: gpu.CompareFunction.less);
    renderer.setBlendState(true);

    // 2. Material
    final material = GfxMaterial(vertexShaderName: 'tvtest', fragmentShaderName: 'tftest');
    
    // Calculamos el aspect ratio para que el cubo no se deforme
    final aspect = size.width / size.height;
    
    final mvpMatrix = Matrix4(
          0.5 / aspect, 0, 0, 0, // X se escala según el aspect ratio
          0, 0.5, 0, 0, //
          0, 0, 0.2, 0, //
          0, 0, 0.5, 1, //
        ) *
        Matrix4.rotationX(time) *
        Matrix4.rotationY(time * seedX) *
        Matrix4.rotationZ(time * seedY) *
        Matrix4.diagonal3(Vector3(scale, scale, scale));
        
    final transients = gpu.gpuContext.createHostBuffer();
    final mvpView = transients.emplace(float32Mat(mvpMatrix));
    
    // Vinculamos uniformes y texturas usando nuestro helper
    material.setUniform('FrameInfo', mvpView);
    material.setTexture('tex', getCubeTexture());

    // 3. Dibujamos la malla
    renderer.drawMesh(getCubeMesh(), material);

    // 4. Finalizamos el frame y lo pintamos en el canvas desde (0,0)
    final image = renderer.endFrame();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Demo3D extends StatefulWidget {
  const Demo3D({super.key});

  @override
  State<Demo3D> createState() => _Demo3DState();
}

class _Demo3DState extends State<Demo3D> {
  Ticker? tick;
  double time = 0;
  double deltaSeconds = 0;
  double seedX = -0.512511498387847167;
  double seedY = 0.521295573094847167;
  double scale = 1.0;
  double depthClearValue = 1.0;

  @override
  void initState() {
    tick = Ticker(
      (elapsed) {
        setState(() {
          double previousTime = time;
          time = elapsed.inMilliseconds / 1000.0;
          deltaSeconds = previousTime > 0 ? time - previousTime : 0;
        });
      },
    );
    tick!.start();
    super.initState();
  }

  @override
  void dispose() {
    tick?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
          painter: Canvas3D(time, seedX, seedY, scale, depthClearValue),
        ),
        Column(
          children: [
            Slider(
              value: seedX,
              max: 1,
              min: -1,
              onChanged: (value) => setState(() => seedX = value)
            ),
            Slider(
              value: seedY,
              max: 1,
              min: -1,
              onChanged: (value) => setState(() => seedY = value)
            ),
            Slider(
              value: scale,
              max: 3,
              min: 0.1,
              onChanged: (value) => setState(() => scale = value)
            ),
            Slider(
              value: depthClearValue,
              max: 1,
              min: 0,
              onChanged: (value) => setState(() => depthClearValue = value)
            ),
          ],
        ),
      ],
    );
  }
}
