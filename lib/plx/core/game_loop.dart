import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'game_scene.dart';
import 'scene_manager.dart';
import '../graphics/renderer.dart';
import '../input/input_manager.dart';

typedef PlxTransitionBuilder = Widget Function(
  BuildContext context, 
  double progress, 
  SceneTransitionState state
);

class PlxGame extends StatefulWidget {
  final GameScene initialScene;
  final PlxTransitionBuilder? transitionBuilder;

  const PlxGame({
    super.key,
    required this.initialScene,
    this.transitionBuilder,
  });

  @override
  State<PlxGame> createState() => _PlxGameState();
}

class _PlxGameState extends State<PlxGame> with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  double _lastTime = 0.0;
  final InputManager _inputManager = InputManager();
  late final SceneManager _manager = SceneManager(inputManager: _inputManager);
  final FocusNode _focusNode = FocusNode();

  InputManager get input => _inputManager;
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
    _manager.update(dt);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _focusNode.dispose();
    _manager.removeListener(_onManagerUpdate);
    _manager.activeScene?.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeScene = _manager.activeScene;
    if (activeScene == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        
        return TapRegion(
          onTapInside: (_) => _focusNode.requestFocus(),
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (node, event) {
              final handled = _inputManager.handleKeyEvent(event);
              return handled ? KeyEventResult.handled : KeyEventResult.ignored;
            },
            child: Listener(
              onPointerDown: (event) => _inputManager.handlePointerEvent(event),
              onPointerUp: (event) => _inputManager.handlePointerEvent(event),
              onPointerMove: (event) => _inputManager.handlePointerEvent(event),
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      painter: _GamePainter(activeScene, _manager.progress),
                    ),
                  ),
                  if (widget.transitionBuilder != null && _manager.state != SceneTransitionState.idle)
                    widget.transitionBuilder!(context, _manager.progress, _manager.state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GamePainter extends CustomPainter {
  final GameScene scene;
  final double transitionAlpha;

  _GamePainter(this.scene, this.transitionAlpha);

  @override
  void paint(Canvas canvas, Size size) {
    final renderer = PlxRenderer(canvas: canvas, size: size);
    renderer.beginFrame(size.width.toInt(), size.height.toInt());
    renderer.setDepthState(writeEnable: true, compareOp: gpu.CompareFunction.less);
    renderer.setBlendState(true);
    scene.draw(renderer);
    final image = renderer.endFrame();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
