import 'package:flutter/material.dart';
import 'package:exa_vortex/plx/core/game/game.dart';
import 'package:exa_vortex/plx/core/scene/game_scene.dart';
import 'package:exa_vortex/plx/graphics/renderer.dart';

class PlxRenderScreen extends StatelessWidget {
  final Size size;
  final PlxGame game;
  
  const PlxRenderScreen(
    {super.key,
    required this.size, 
    required this.game}
  );

  @override
  Widget build(BuildContext context) {
    final activeScene = game.sceneManager.activeScene;
    if (activeScene == null) return const SizedBox.shrink();

    return Stack(
      children: [
        RepaintBoundary(
          child: CustomPaint(
            size: size,
            painter: _GamePainter(game.renderer, activeScene)
          ),
        ),
      ],
    );
  }
}

class _GamePainter extends CustomPainter {
  final PlxRenderer renderer;
  final GameScene scene;

  _GamePainter(this.renderer, this.scene);

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
