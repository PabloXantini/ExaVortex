import 'package:exa_vortex/plx/graphics/mesh_component.dart';
import 'package:exa_vortex/plx/graphics/mesh_renderer.dart';
import 'package:exa_vortex/plx/graphics/text/plx_font.dart';
import 'package:exa_vortex/plx/graphics/text/text_geometry_builder.dart';
import 'package:exa_vortex/plx/scene/2d/entity_2d.dart';
import 'package:vector_math/vector_math_64.dart';

class Text2D extends Entity2D {
  final String text;
  final PlxFont font;
  final double fontSize;
  final Vector4 color;

  Text2D({
    super.name = 'Text2D',
    required this.text,
    required this.font,
    this.fontSize = 1.0,
    Vector4? color,
  }) : 
    color = color ?? Vector4(1, 1, 1, 1) 
  {
    _build();
  }

  void _build() {
    final mesh = TextGeometryBuilder.buildMesh(
      text,
      font,
      fontSize: fontSize,
      color: color,
    );
    final renderer = MeshRenderer(material: font.defaultMaterial, opaque: false);
    addComponent(MeshComponent(mesh));
    addComponent(renderer);
  }
}
