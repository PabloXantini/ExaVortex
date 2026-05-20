import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:exa_vortex/plx/graphics/renderer.dart';
import 'package:exa_vortex/plx/audio/plx_audio.dart';
import 'package:exa_vortex/plx/input/input_layer.dart';
import 'package:exa_vortex/plx/core/screen_layer.dart';
import 'scene/widgets.dart';
import 'scene/scene_manager.dart';
import 'scene/game_scene.dart';
import 'game_cache.dart';

class PlxGame extends StatefulWidget {
  final GameScene initialScene;
  final GameCache? cache;
  final PlxTransitionBuilder? transitionBuilder;
  final WidgetBuilder? loadingBuilder;

  const PlxGame({
    super.key,
    required this.initialScene,
    this.cache,
    this.transitionBuilder,
    this.loadingBuilder,
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
  final FocusNode _focusNode = FocusNode();
  //PlxGame most important dependencies
  late final PlxRenderer _renderer = PlxRenderer();
  late final SceneManager _manager = SceneManager(cache: widget.cache);

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioManager.instance.init();
    _manager.init(widget.initialScene);
    _manager.addListener(_onManagerUpdate);
    _ticker = createTicker(_onTick)..start();
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
    if (_manager.isLoading) {
      if (widget.loadingBuilder == null) return const ColoredBox(color: Color(0x00000000));
      return widget.loadingBuilder!(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return PlxInputLayer(
          focusNode: _focusNode,
          inputManager: activeScene!.input,
          child: Stack(
            children: [
              PlxScreenLayer(
                size: size,
                scene: activeScene,
                renderer: _renderer,
              ),
              if (widget.transitionBuilder != null && _manager.isTransitioning)
                widget.transitionBuilder!(context, _manager.progress, _manager.state),
            ],
          ),
        );
      },
    );
  }
}
