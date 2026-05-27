import 'package:exa_vortex/app/scenes/background_scene.dart';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/tests/test_rich_text.dart';
import 'package:exa_vortex/plx/tests/testinput.dart';
import 'package:exa_vortex/plx/tests/testscene2.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Use lazy instantiation to keep game logic out of build
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
      //  TestRichTextGame()
      /*
      Row(
        children: [
          Expanded(
            child: PlxGameFrame(game: PlxGame(initialScene: BackgroundScene()))
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(child: TestInputGame()),
                Expanded(child: TestScene2Game()),
              ],
            ),
          ),
        ],
      ),
      */
    );
  }
}
