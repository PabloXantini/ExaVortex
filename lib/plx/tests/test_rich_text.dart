import 'package:flutter/material.dart';
import 'package:exa_vortex/plx/plx.dart' hide Colors;
import 'package:exa_vortex/plx/plx2d.dart';
import 'package:exa_vortex/plx/plx3d.dart';

class RichTextTestScene extends GameScene {
  late PlxFont fontRegular;
  late PlxFont fontBold;
  late PlxFont fontItalic;
  
  late World world;
  late Camera3D camera;
  late TextField2D textField;

  @override
  Future<void> onLoad() async {
    fontRegular = await PlxFont.load('Roboto');
    fontBold = await PlxFont.load('Roboto', fontWeight: FontWeight.bold);
    fontItalic = await PlxFont.load('Roboto', fontStyle: FontStyle.italic);
    return super.onLoad();
  }

  @override
  void dispose() {
    fontRegular.dispose();
    fontBold.dispose();
    fontItalic.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    world = World();
    camera = Camera3D(name: 'Camera', world: world);
    camera.position = Vector3(0, 0, 15);
    addEntity(camera);

    final composition = TextComposition(
      segments: [
        TextSegment(
          text: 'This is a test of ',
          font: fontRegular,
          fontSize: 1.0,
          color: Vector4(1, 1, 1, 1),
        ),
        TextSegment(
          text: 'RICH TEXT ',
          font: fontBold,
          fontSize: 1.2,
          color: Vector4(1, 0, 0, 1),
        ),
        TextSegment(
          text: 'capabilities!\n',
          font: fontRegular,
          fontSize: 1.0,
          color: Vector4(1, 1, 1, 1),
        ),
        TextSegment(
          text: 'Here is some italic text to show off the ',
          font: fontItalic,
          fontSize: 1.0,
          color: Vector4(0, 1, 0, 1),
        ),
        TextSegment(
          text: 'composition and wrapping.',
          font: fontRegular,
          fontSize: 1.0,
          color: Vector4(0.5, 0.5, 1, 1),
        ),
      ],
    );

    textField = TextField2D(
      composition: composition,
      bounds: const Size(20, 10), // Wrap at 10 units wide
      align: TextAlign.justified,
      anchor: TextAnchor.center,
    );
    
    textField.position = Vector2(0, 0);
    textField.rotation = radians(15);
    
    world.addChild(textField);
    addEntity(world);
  }
}

class TestRichTextGame extends StatefulWidget {
  const TestRichTextGame({super.key});

  @override
  State<TestRichTextGame> createState() => _TestRichTextGameState();
}

class _TestRichTextGameState extends State<TestRichTextGame> {
  late final RichTextTestScene _scene = RichTextTestScene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlxGame(
        initialScene: _scene,
      ),
    );
  }
}
