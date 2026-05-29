import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx2d.dart';

class ExaVortexTitle extends Entity2D {
  final double shadowOffsetRatio = 0.1;
  final PlxFont font;
  late Text2D brightTitle;
  late Text2D shadowTitle;
  String text;
  ExaVortexTitle({
    required this.text, 
    required this.font, 
    double? fontSize, 
    double shadowOffsetRatio = 0.01}
  ) : 
    super(name: 'Title') {
    brightTitle = Text2D(
      name: 'ExaTitleBright', 
      text: text, 
      font: font, 
      fontSize: fontSize ?? 1, 
      anchor: TextAnchor.center);
    shadowTitle = Text2D(
      name: 'ExaTitleShadow', 
      text: text, 
      font: font, 
      fontSize: fontSize ?? 1, 
      color: Vector4(0, 0, 0, 1), 
      anchor: TextAnchor.center);
      brightTitle.setZLayer(0.01);
      shadowTitle.setZLayer(0);
      addChild(brightTitle);
      addChild(shadowTitle);
  }

  @override
  set position(Vector2 value) {
    super.position = value;
    double shadowOffset = shadowOffsetRatio * brightTitle.fontSize;
    brightTitle.position = value;
    shadowTitle.position = value + Vector2(shadowOffset,-shadowOffset);
  }
}