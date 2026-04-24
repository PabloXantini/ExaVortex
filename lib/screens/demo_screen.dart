import 'package:flutter/material.dart';

import '../plx_flutter/tests/test3d2.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
                child: Text(
              'GPU demo',
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Demo3D()),
        ],
      ),
    );
  }
}