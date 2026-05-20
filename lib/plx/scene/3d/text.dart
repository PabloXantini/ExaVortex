import 'package:exa_vortex/plx/graphics/mesh_component.dart';
import 'package:exa_vortex/plx/graphics/mesh_renderer.dart';
import 'package:exa_vortex/plx/graphics/text/plx_font.dart';
import 'package:exa_vortex/plx/graphics/text/text_geometry_builder.dart';
import 'package:exa_vortex/plx/scene/3d/entity_3d.dart';
import 'package:vector_math/vector_math_64.dart';

class Text3D extends Entity3D {
  final String text;
  final PlxFont font;
  final double fontSize;
  final double extrudeDepth;
  final Vector4 color;
  MeshRenderer? renderer;

  Text3D({
    super.name = 'Text3D',
    required this.text,
    required this.font,
    this.fontSize = 1.0,
    this.extrudeDepth = 0.1,
    Vector4? color,
    MeshRenderer? renderer
  }) : color = color ?? Vector4(1, 1, 1, 1) {
    _build();
  }

  void _build() {
    final mesh = TextGeometryBuilder.buildMesh(
      text,
      font,
      fontSize: fontSize,
      color: color,
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
