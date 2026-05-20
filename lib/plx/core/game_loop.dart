import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:exa_vortex/plx/graphics/renderer.dart';
import 'package:exa_vortex/plx/audio/plx_audio.dart';
import 'package:exa_vortex/plx/input/input_layer.dart';
import 'game_scene.dart';
import 'game_cache.dart';
import 'scene_manager.dart';

typedef PlxTransitionBuilder = Widget Function(
  BuildContext context, 
  double progress, 
  SceneTransitionState state
);

class PlxGame extends StatefulWidget {
  final GameScene initialScene;
  final GameCache? cache;
  final PlxTransitionBuilder? transitionBuilder;

  const PlxGame({
    super.key,
    required this.initialScene,
    this.cache,
    this.transitionBuilder,
  });

  @override
  State<PlxGame> createState() => _PlxGameState();
}

class _PlxGameState extends State<PlxGame> with 
  SingleTickerProviderStateMixin, 
  WidgetsBindingObserver 
{
  Ticker? _ticker;
  double _lastTime = 0.0;
  late final PlxRenderer _renderer = PlxRenderer();
  late final SceneManager _manager = SceneManager(cache: widget.cache);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioManager.instance.init();
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
    AudioManager.instance.update();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state){
      case AppLifecycleState.paused:
        _manager.activeScene?.onPause();
        break;
      case AppLifecycleState.resumed:
        _manager.activeScene?.onResume();
        break;
      case AppLifecycleState.inactive:
        _manager.activeScene?.onPause();
        break;
      case AppLifecycleState.detached:
        _manager.activeScene?.onPause();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _focusNode.dispose();
    _manager.removeListener(_onManagerUpdate);
    _manager.dispose();
    _renderer.dispose();
    AudioManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeScene = _manager.activeScene;
    //Thing i must change in the future
    // TODO: Make an elegant way to handle this. The idea is to show a loading screen 
    // TODO: until the scene is loaded.
    if (activeScene == null || _manager.state == SceneTransitionState.loading) {
      return const ColoredBox(color: Color(0xFF000000));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return PlxInputLayer(
          focusNode: _focusNode,
          inputManager: activeScene.input,
          child: Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: size,
                  painter: _GamePainter(_renderer, activeScene, _manager.progress),
                ),
              ),
              if (widget.transitionBuilder != null && _manager.state != SceneTransitionState.idle)
                widget.transitionBuilder!(context, _manager.progress, _manager.state),
            ],
          ),
        );
      },
    );
  }
}

class _GamePainter extends CustomPainter {
  final PlxRenderer renderer;
  final GameScene scene;
  final double progress;

  _GamePainter(this.renderer, this.scene, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    renderer.beginFrame(size);
    scene.draw(renderer);
    final image = renderer.endFrame();
    canvas.drawImage(image, Offset.zero, Paint());
    image.dispose();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
