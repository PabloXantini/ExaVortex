import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'game_scene.dart';
import 'scene_manager.dart';
import '../graphics/renderer.dart';

typedef PlxTransitionBuilder = Widget Function(
  BuildContext context, 
  double alpha, 
  SceneTransitionState state
);

class PlxGame extends StatefulWidget {
  final GameScene initialScene;
  final double depthClearValue;
  final PlxTransitionBuilder? transitionBuilder;

  const PlxGame({
    super.key,
    required this.initialScene,
    this.depthClearValue = 1.0,
    this.transitionBuilder,
  });

  @override
  State<PlxGame> createState() => _PlxGameState();
}

class _PlxGameState extends State<PlxGame> with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  double _lastTime = 0.0;
  final SceneManager _manager = SceneManager();

  @override
  void initState() {
    super.initState();
    _manager.init(widget.initialScene);
    _manager.addListener(_onManagerUpdate);
    _ticker = createTicker(_onTick)..start();
  }

  void _onManagerUpdate() {
    setState(() {});
  }

  void _onTick(Duration elapsed) {
    double time = elapsed.inMicroseconds / 1000000.0;
    double dt = time - _lastTime;
    _lastTime = time;

    if (dt > 0.1) dt = 0.1;

    // Delegate update to manager
    _manager.update(dt);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _manager.removeListener(_onManagerUpdate);
    _manager.activeScene?.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeScene = _manager.activeScene;
    if (activeScene == null) return const SizedBox.shrink();

    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _GamePainter(activeScene, widget.depthClearValue, _manager.alpha),
        ),
        if (widget.transitionBuilder != null && _manager.state != SceneTransitionState.none)
          widget.transitionBuilder!(context, _manager.alpha, _manager.state),
      ],
    );
  }
}

class _GamePainter extends CustomPainter {
  final GameScene scene;
  final double depthClearValue;
  final double transitionAlpha;

  _GamePainter(this.scene, this.depthClearValue, this.transitionAlpha);

  @override
  void paint(Canvas canvas, Size size) {
    final renderer = PlxRenderer();
    renderer.beginFrame(size.width.toInt(), size.height.toInt(), depthClearValue: depthClearValue);

    renderer.setDepthState(writeEnable: true, compareOp: gpu.CompareFunction.less);
    renderer.setBlendState(true);

    scene.draw(renderer, canvas, size);

    final image = renderer.endFrame();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
