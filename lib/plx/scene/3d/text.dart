import 'package:exa_vortex/plx/graphics/material.dart';
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

  Text3D({
    super.name = 'Text3D',
    required this.text,
    required this.font,
    this.fontSize = 1.0,
    this.extrudeDepth = 0.1,
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

    final renderer = MeshRenderer(mesh: mesh, opaque: false);
    final textMaterial = GfxMaterial(
      vertexShaderName: 'TextV',
      fragmentShaderName: 'TextF',
    );
    if (font.atlasTexture != null) {
      textMaterial.setTexture(GfxShader.fragment, 'font_atlas', font.atlasTexture!);
    }
    renderer.material = textMaterial;
    addComponent(renderer);
  }
}
