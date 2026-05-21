import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/logger.dart';
import 'package:exa_vortex/plx/graphics/texture.dart';
import 'package:exa_vortex/plx/graphics/material.dart';
import 'package:exa_vortex/plx/graphics/mesh_renderer.dart';
import 'glyph.dart';

class PlxFont {
  final String fontFamily;
  final Map<int, GlyphMetrics> glyphs = {};
  PlxTexture? atlasTexture;
  PlxMaterial? defaultMaterial;
  MeshRenderer? defaultRenderer;

  PlxFont._(this.fontFamily);

  static Future<PlxFont> load(
    String fontFamily,
    {
      String? assetPath, 
      String characters = " !\"#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~",
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
    final font = PlxFont._(fontFamily);
    await font._generateAtlas(characters);
    return font;
  }

  Future<void> _generateAtlas(String characters) async {
    const int glyphSize = 64; 
    const int padding = 4; // Padding to ensure smoothstep edges are not clipped
    
    int cols = math.sqrt(characters.length).ceil();
    int rows = (characters.length / cols).ceil();
    
    int minWidth = cols * glyphSize;
    int minHeight = rows * glyphSize;
    
    int maxSize = 1;
    while (maxSize < minWidth || maxSize < minHeight){
      maxSize *= 2;
    }
    
    PlxLogger.message('Generating SDF atlas for font $fontFamily: $maxSize x $maxSize', system: 'Graphics');

    final double renderFontSize = (glyphSize - padding * 2).toDouble();
    final double scale = 1.0 / renderFontSize; // Normalize to 1.0 unit = font size

    final image = await _createAtlasImage(characters, glyphSize, padding, maxSize, scale, renderFontSize, cols);
    atlasTexture = await PlxTexture.fromImage(image);
    image.dispose();
    //Initialize default text renderer components
    // Text Default Material
    defaultMaterial = PlxMaterial(
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

  Future<ui.Image> _createAtlasImage(String characters, int glyphSize, int padding, int maxSize, double scale, double renderFontSize, int cols) async {
    // Render everything to a single picture for massive performance gain
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, maxSize.toDouble(), maxSize.toDouble()));
    // Solid black background for alpha/red channel SDF
    canvas.drawRect(Rect.fromLTWH(0, 0, maxSize.toDouble(), maxSize.toDouble()), Paint()..color = const Color(0x00000000));

    for (int i = 0; i < characters.length; i++) {
      final char = characters[i];
      final charCode = char.codeUnitAt(0);
      
      int col = i % cols;
      int row = i ~/ cols;

      // We draw the character with padding inside its grid cell
      double cellX = (col * glyphSize).toDouble();
      double cellY = (row * glyphSize).toDouble();
      
      final offset = Offset(cellX + padding, cellY + padding);

      glyphs[charCode] = _convertCharToGlyph(canvas, char, offset, padding, renderFontSize, maxSize, scale);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(maxSize, maxSize);
    picture.dispose();
    return image;
  }

  GlyphMetrics _convertCharToGlyph(ui.Canvas canvas, String char, Offset offset, int padding, double renderFontSize, int maxSize, double scale) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: renderFontSize,
          color: const Color(0xFFFFFFFF),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);

    // Calculate tight bounding box for the mesh with padding included
    // This ensures the mesh is exactly the size of the glyph (plus padding for smoothing)
    double charW = textPainter.width;
    double charH = textPainter.height;
    
    // If char is empty space, give it a default advance
    if (charW == 0 && char == ' ') {
        charW = renderFontSize * 0.4; // standard space size
    }

    final lineMetrics = textPainter.computeLineMetrics();
    double ascent = lineMetrics.isNotEmpty ? lineMetrics.first.ascent : renderFontSize;

    // The UVs will cover exactly the drawn character + padding
    double u1 = (offset.dx - padding) / maxSize;
    double v1 = (offset.dy - padding) / maxSize;
    double u2 = (offset.dx + charW + padding) / maxSize;
    double v2 = (offset.dy + charH + padding) / maxSize;

    double width = (charW + padding * 2) * scale;
    double height = (charH + padding * 2) * scale;

    // Adjust metrics: 
    // left starts at -padding to align visual center with cursor
    // top moves up by ascent, offset by padding
    // advance is the actual width, tweaked slightly for better kerning visual
    return GlyphMetrics(
      uv1: Vector2(u1, v1),
      uv2: Vector2(u2, v2),
      size: Size(width, height),
      bearing: Offset(-padding * scale, -(ascent - padding) * scale),
      advance: width * 0.95, // 0.95 for slightly tighter inter-spacing
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