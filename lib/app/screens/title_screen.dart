import 'package:exagon_plus/app/scenes/background_scene.dart';
import 'package:exagon_plus/plx/plx.dart';
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
      Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: PlxGame(initialScene: BackgroundScene())),
                Expanded(child: PlxGame(initialScene: BackgroundScene()))
              ],
            )
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: PlxGame(initialScene: BackgroundScene())),
                Expanded(child: PlxGame(initialScene: BackgroundScene()))
              ],
            ),
          )
        ],
      )
    );
  }
}