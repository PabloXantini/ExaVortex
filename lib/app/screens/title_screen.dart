import 'package:exa_vortex/app/scenes/background_scene.dart';
import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/tests/testinput.dart';
import 'package:exa_vortex/plx/tests/testscene2.dart';
import 'package:flutter/material.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        PlxGame(initialScene: BackgroundScene()) 
      //TestInputGame() 
      /*
      Row(
        children: [
          Expanded(
            child: PlxGame(initialScene: BackgroundScene())
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
