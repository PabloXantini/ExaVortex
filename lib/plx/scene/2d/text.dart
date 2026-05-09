import 'package:exa_vortex/plx/graphics/material.dart';
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
    super.name = 'TextEntity2D',
    required this.text,
    required this.font,
    this.fontSize = 1.0,
    Vector4? color,
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
    final textMaterial = GfxMaterial(
      vertexShaderName: 'sdf_text_v',
      fragmentShaderName: 'sdf_text_f',
    );
    if (font.atlasTexture != null) {
      textMaterial.setTexture(GfxMaterialLayer.fragment, 'char_text', font.atlasTexture!);
    }
    final renderer = MeshRenderer(mesh: mesh, material: textMaterial, opaque: false);
    addComponent(renderer);
  }
}
