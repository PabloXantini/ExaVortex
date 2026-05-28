import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exa_vortex/plx/core/logger.dart';
import 'package:exa_vortex/plx/graphics/material/texture.dart';
import 'package:exa_vortex/plx/graphics/material/material.dart';
import 'package:exa_vortex/plx/graphics/graphics.dart';
import 'package:exa_vortex/plx/graphics/rendering/mesh/mesh_renderer.dart';
import 'glyph.dart';
import 'font_atlas_builder.dart';

class PlxFont {
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final Map<int, GlyphMetrics> glyphs = {};
  PlxTexture? atlasTexture;
  PlxMaterial? defaultMaterial;
  MeshRenderer? defaultRenderer;

  PlxFont._(this.fontFamily, this.fontWeight, this.fontStyle);

  static Future<PlxFont> load(
    String fontFamily,
    {
      String? assetPath, 
      String characters = " !\"#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~",
      FontWeight fontWeight = FontWeight.normal,
      FontStyle fontStyle = FontStyle.normal,
    }
  ) async {
    if (assetPath != null) { // if asset path is specified, then load dynamically the font
      final String name = assetPath.split('/').last.split('.').first;
      PlxLogger.message('Loading font $name ($fontFamily) from $assetPath', system: 'Graphics');
      try {
        final ByteData data = await rootBundle.load(assetPath);
        // Load font into Flutter's engine
        final loader = FontLoader(fontFamily);
        loader.addFont(Future.value(data));
        await loader.load();
      } catch (e) {
        PlxLogger.warning('Failed to load font to engine (may already be in pubspec.yaml): $e', system: 'Graphics');
      }
    }
    final font = PlxFont._(fontFamily, fontWeight, fontStyle);
    await font._generateAtlas(characters);
    return font;
  }

  Future<void> _generateAtlas(String characters) async {
    final atlas = await FontAtlasBuilder.generate(
      fontFamily, 
      fontWeight, 
      fontStyle, 
      characters
    );
    
    atlasTexture = atlas.texture;
    glyphs.addAll(atlas.glyphs);

    // Text Default Material
    defaultMaterial = PlxGraphics.instance.createMaterial(
      vertexShaderName: 'TextV',
      fragmentShaderName: 'TextF',
    );
    if (atlasTexture != null) {
      defaultMaterial!.setTexture(PlxShader.fragment, 'text_atlas', atlasTexture!);
    }
    // Text Default Renderer
    defaultRenderer = MeshRenderer(
      material: defaultMaterial!,
      opaque: false
    );
  }

  void dispose() {
    atlasTexture = null;
    defaultMaterial?.dispose();
    defaultRenderer?.dispose();
    defaultMaterial = null;
    defaultRenderer = null;
    glyphs.clear();
  }
}