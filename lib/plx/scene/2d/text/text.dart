import 'package:exa_vortex/plx/graphics/mesh_component.dart';
import 'package:exa_vortex/plx/graphics/mesh_renderer.dart';
import 'package:exa_vortex/plx/graphics/text/font.dart';
import 'package:exa_vortex/plx/graphics/text/builder.dart';
import 'package:exa_vortex/plx/graphics/text/geometry.dart';
import 'package:exa_vortex/plx/scene/2d/entity_2d.dart';
import 'package:vector_math/vector_math_64.dart';

class Text2D extends Entity2D {
  final String text;
  final PlxFont font;
  final double fontSize;
  final Vector4 color;
  final TextAnchor anchor;
  MeshRenderer? renderer;

  Text2D({
    super.name = 'Text2D',
    required this.text,
    required this.font,
    this.fontSize = 1.0,
    Vector4? color,
    this.anchor = TextAnchor.bottomLeft,
    MeshRenderer? renderer,
  }) : 
    color = color ?? Vector4(1, 1, 1, 1) 
  {
    _build();
  }

  void _build() {
    final mesh = TextBuilder.buildMesh(
      text,
      font,
      fontSize: fontSize,
      color: color,
      anchor: anchor,
    );
    addComponent(MeshComponent(mesh));
    //Fallback renderer if not specified
    if(renderer==null){
      addComponent(font.defaultRenderer!);
    }else{
      addComponent(renderer!);
    }
  }
}
