import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/logger.dart';
import 'package:exa_vortex/plx/graphics/texture.dart';
import 'package:exa_vortex/plx/graphics/graphics.dart';
import 'glyph.dart';

class FontAtlas {
  final PlxTexture texture;
  final Map<int, GlyphMetrics> glyphs;

  FontAtlas(this.texture, this.glyphs);
}

class FontAtlasBuilder {
  /// Generates a font atlas for the given [fontFamily], [fontWeight], [fontStyle], and [characters].
  /// Computes the exact grid cell size needed to prevent glyph bleeding.
  static Future<FontAtlas> generate(
    String fontFamily,
    FontWeight fontWeight,
    FontStyle fontStyle,
    String characters,
  ) async {
    const double renderFontSize = 48.0; 
    const int padding = 4; // Padding to ensure smoothstep edges are not clipped
    
    // 1. Measure all characters to find the max width and max height needed
    double maxCharW = 0;
    double maxCharH = 0;
    
    for (int i = 0; i < characters.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: characters[i],
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: renderFontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      if (textPainter.width > maxCharW) maxCharW = textPainter.width;
      if (textPainter.height > maxCharH) maxCharH = textPainter.height;
    }
    
    // Add default space width if not found
    if (maxCharW == 0) maxCharW = renderFontSize * 0.4;
    if (maxCharH == 0) maxCharH = renderFontSize;

    // 2. Calculate cell size (including padding on all sides)
    final int cellWidth = (maxCharW + padding * 2).ceil();
    final int cellHeight = (maxCharH + padding * 2).ceil();

    // 3. Calculate grid dimensions
    int cols = math.sqrt(characters.length).ceil();
    int rows = (characters.length / cols).ceil();
    
    int minWidth = cols * cellWidth;
    int minHeight = rows * cellHeight;
    
    int maxSize = 1;
    while (maxSize < minWidth || maxSize < minHeight) {
      maxSize *= 2;
    }
    
    PlxLogger.message('Generating atlas for font $fontFamily: $maxSize x $maxSize (Cell: $cellWidth x $cellHeight)', system: 'Graphics');

    final double scale = 1.0 / renderFontSize; // Normalize to 1.0 unit = font size

    // 4. Render atlas
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, maxSize.toDouble(), maxSize.toDouble()));
    // Solid black background for alpha/red channel SDF with zero alpha
    canvas.drawRect(Rect.fromLTWH(0, 0, maxSize.toDouble(), maxSize.toDouble()), Paint()..color = const Color(0x00000000));

    final Map<int, GlyphMetrics> glyphs = {};

    for (int i = 0; i < characters.length; i++) {
      final char = characters[i];
      final charCode = char.codeUnitAt(0);
      
      int col = i % cols;
      int row = i ~/ cols;

      double cellX = (col * cellWidth).toDouble();
      double cellY = (row * cellHeight).toDouble();
      
      final offset = Offset(cellX + padding, cellY + padding);

      final textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: renderFontSize,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            color: const Color(0xFFFFFFFF),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);

      double charW = textPainter.width;
      double charH = textPainter.height;
      if (charW == 0 && char == ' ') charW = renderFontSize * 0.4;

      final lineMetrics = textPainter.computeLineMetrics();
      double ascent = lineMetrics.isNotEmpty ? lineMetrics.first.ascent : renderFontSize;

      // Ensure UVs are bounded and include padding
      double u1 = (offset.dx - padding) / maxSize;
      double v1 = (offset.dy - padding) / maxSize;
      double u2 = (offset.dx + charW + padding) / maxSize;
      double v2 = (offset.dy + charH + padding) / maxSize;

      double width = (charW + padding * 2) * scale;
      double height = (charH + padding * 2) * scale;

      glyphs[charCode] = GlyphMetrics(
        uv1: Vector2(u1, v1),
        uv2: Vector2(u2, v2),
        size: Size(width, height),
        bearing: Offset(-padding * scale, -(ascent - padding) * scale),
        advance: width * 0.95,
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(maxSize, maxSize);
    picture.dispose();
    
    final texture = await PlxGraphics.instance.createTextureFromImage(image);
    image.dispose();

    return FontAtlas(texture, glyphs);
  }
}
