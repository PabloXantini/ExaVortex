import 'package:flutter/material.dart';
import 'package:exa_vortex/plx/plx.dart';

class MyGameCache extends GameCache {
  int score = 0;
  String playerName = 'Player 1';
}

class CacheScene extends GameScene {
  @override
  void onInit() {
    final myCache = cache as MyGameCache;
    PlxLogger.message('Current Score: ${myCache.score}', system: 'Cache');
    myCache.score += 10;
    PlxLogger.message('New Score: ${myCache.score}', system: 'Cache');
  }
}

class TestCacheGame extends StatefulWidget {
  const TestCacheGame({super.key});

  @override
  State<TestCacheGame> createState() => _TestCacheGameState();
}

class _TestCacheGameState extends State<TestCacheGame> {
  late final CacheScene _scene = CacheScene();
  late final PlxGame _game = PlxGame(
    initialScene: _scene,
    cache: MyGameCache(),
  );

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlxGameFrame(
      game: _game,
    );
  }
}
