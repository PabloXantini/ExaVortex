import 'package:exa_vortex/app/screens/game_screen.dart';
import 'package:flutter/material.dart';
// TEST
import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

void main() {
  FlutterMemoryAllocations.instance.addListener(
    (ObjectEvent event) => LeakTracking.dispatchObjectEvent(event.toMap()),
  );
  LeakTracking.start();
  runApp(const MainApp());
  LeakTracking.stop();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
