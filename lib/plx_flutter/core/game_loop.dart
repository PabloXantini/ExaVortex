import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'game_scene.dart';
import '../graphics/renderer.dart';

class PlxGame extends StatefulWidget {
  final GameScene initialScene;
  final double depthClearValue;

  const PlxGame({
    super.key,
    required this.initialScene,
    this.depthClearValue = 1.0,
  });

  @override
  State<PlxGame> createState() => _PlxGameState();
}

class _PlxGameState extends State<PlxGame> with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  double _lastTime = 0.0;
  late GameScene _activeScene;

  @override
  void initState() {
    super.initState();
    _activeScene = widget.initialScene;
    _activeScene.onInit();
    //_activeScene.show();

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    double time = elapsed.inMicroseconds / 1000000.0;
    double dt = time - _lastTime;
    _lastTime = time;

    // Optional: cap dt to avoid huge jumps
    if (dt > 0.1) dt = 0.1;

    setState(() {
      _activeScene.update(dt);
    });
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _activeScene.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GamePainter(_activeScene, widget.depthClearValue),
    );
  }
}

class _GamePainter extends CustomPainter {
  final GameScene scene;
  final double depthClearValue;

  _GamePainter(this.scene, this.depthClearValue);

  @override
  void paint(Canvas canvas, Size size) {
    final renderer = PlxRenderer();
    renderer.beginFrame(size.width.toInt(), size.height.toInt(), depthClearValue: depthClearValue);

    // Default depth & blend state, can be customized by the scene if needed
    renderer.setDepthState(writeEnable: true, compareOp: gpu.CompareFunction.less);
    renderer.setBlendState(true);

    // Let the scene draw its entities
    scene.draw(renderer, canvas, size);

    final image = renderer.endFrame();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
