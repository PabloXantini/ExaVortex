import 'package:flutter/material.dart';
import '../plx.dart';

class MyGameCache extends GameCache {
  int score = 0;
  String playerName = 'Player 1';
}

class CacheScene extends GameScene {
  @override
  void onInit() {
    final myCache = cache as MyGameCache;
    debugPrint('Current Score: ${myCache.score}');
    myCache.score += 10;
    debugPrint('New Score: ${myCache.score}');
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
