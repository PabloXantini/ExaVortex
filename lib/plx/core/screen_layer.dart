import 'package:exa_vortex/plx/core/scene/game_scene.dart';
import 'package:exa_vortex/plx/graphics/renderer.dart';
import 'package:flutter/material.dart';

class PlxScreenLayer extends StatelessWidget {
  final Size size;
  final GameScene scene;
  final PlxRenderer renderer;
  const PlxScreenLayer(
    {super.key,
    required this.size, 
    required this.scene, 
    required this.renderer}
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: CustomPaint(
            size: size,
            painter: _GamePainter(renderer, scene)
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
