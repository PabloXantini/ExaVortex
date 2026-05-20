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

class TestCacheGame extends StatelessWidget {
  const TestCacheGame({super.key});

  @override
  Widget build(BuildContext context) {
    return PlxGame(
      initialScene: CacheScene(),
      cache: MyGameCache(),
    );
  }
}
