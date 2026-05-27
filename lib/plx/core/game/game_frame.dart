import 'package:flutter/material.dart';
import 'package:exa_vortex/plx/core/game/game.dart';
import 'package:exa_vortex/plx/core/game/game_loop.dart';
import 'package:exa_vortex/plx/core/render_screen.dart';
import 'package:exa_vortex/plx/input/input_layer.dart';
import 'package:exa_vortex/plx/core/scene/widgets.dart';

class PlxGameFrame<T extends PlxGame> extends StatefulWidget {
  final T game;
  final PlxTransitionBuilder? transitionBuilder;
  final WidgetBuilder? loadingBuilder;

  const PlxGameFrame({
    super.key,
    required this.game,
    this.transitionBuilder,
    this.loadingBuilder,
  });

  @override
  State<PlxGameFrame<T>> createState() => _PlxGameFrameState<T>();
}

class _PlxGameFrameState<T extends PlxGame> extends State<PlxGameFrame<T>>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final PlxGameLoop _gameLoop;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize game
    widget.game.init();
    
    // Listen for scene manager changes to trigger rebuilds
    widget.game.sceneManager.addListener(_onManagerUpdate);

    _gameLoop = PlxGameLoop(
      onTick: widget.game.onTick,
      vsync: this,
    )..start();
  }

  void _onManagerUpdate() {
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.game.onLifecycleStateChange(state);
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    _focusNode.dispose();
    widget.game.sceneManager.removeListener(_onManagerUpdate);
    widget.game.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.game.sceneManager;
    final activeScene = manager.activeScene;

    if (manager.isLoading || activeScene == null) {
      if (widget.loadingBuilder == null) return const ColoredBox(color: Color(0x00000000));
      return widget.loadingBuilder!(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        
        return PlxInputLayer(
          focusNode: _focusNode,
          inputManagers: [widget.game.input, activeScene.input],
          child: Stack(
            children: [
              PlxRenderScreen(
                size: size,
                game: widget.game,
              ),
              if (widget.transitionBuilder != null && manager.isTransitioning)
                widget.transitionBuilder!(context, manager.progress, manager.state),
            ],
          ),
        );
      },
    );
  }
}
