import 'package:flutter/widgets.dart';
import 'game_scene.dart';

/// Renders the Flutter UI overlay for the active [GameScene].
///
/// Listens to [GameScene.uiNotifier] and rebuilds when [GameScene.refreshUI]
/// is called. The scene's [GameScene.buildUI] output is spread as children
/// into a full-screen [Stack], allowing multiple independent overlay layers.
///
/// Renders nothing (zero-size box) when [buildUI] returns an empty list.
class PlxUI extends StatelessWidget {
  final GameScene scene;

  const PlxUI({super.key, required this.scene});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scene.uiNotifier,
      builder: (context, _) {
        final layers = scene.buildUI(context);
        if (layers.isEmpty) return const SizedBox.shrink();
        return Stack(
          fit: StackFit.expand,
          children: layers,
        );
      },
    );
  }
}
