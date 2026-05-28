import 'package:flutter/material.dart';
import 'package:exa_vortex/app/scenes/background_scene.dart';
import 'package:exa_vortex/plx/plx.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final PlxGame _game = PlxGame(initialScene: BackgroundScene());
  
  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        PlxGameFrame(game: _game) 
    );
  }
}
