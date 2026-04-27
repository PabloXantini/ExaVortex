import 'package:exagon_plus/app/screens/title_screen.dart';
import 'package:exagon_plus/plx/tests/testgame.dart';
import 'package:exagon_plus/plx/tests/testgame2.dart';
import 'package:exagon_plus/plx/tests/testinput.dart';
import 'package:exagon_plus/plx/tests/testscene.dart';
import 'package:exagon_plus/plx/tests/testscene2.dart';
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
      home: TitleScreen(),
    );
  }
}
