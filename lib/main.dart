import 'package:exagon_plus/exavortex_app/screens/demo_screen.dart';
import 'package:exagon_plus/exavortex_app/screens/title_screen.dart';
import 'package:exagon_plus/plx_flutter/tests/testgame.dart';
import 'package:exagon_plus/plx_flutter/tests/testinput.dart';
import 'package:exagon_plus/plx_flutter/tests/testscene.dart';
import 'package:exagon_plus/plx_flutter/tests/testscene2.dart';
//import 'package:exagon_plus/screens/title_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestScene2Game(),
    );
  }
}
