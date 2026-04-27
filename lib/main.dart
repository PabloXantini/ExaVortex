import 'package:exa_vortex/app/screens/title_screen.dart';
import 'package:exa_vortex/plx/tests/testgame.dart';
import 'package:exa_vortex/plx/tests/testgame2.dart';
import 'package:exa_vortex/plx/tests/testinput.dart';
import 'package:exa_vortex/plx/tests/testscene.dart';
import 'package:exa_vortex/plx/tests/testscene2.dart';
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
