import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../texture.dart';

class GlyphInfo {
  final double u1, v1, u2, v2;
  final double width, height;
  final double left, top;
  final double advance;

  GlyphInfo({
    required this.u1,
    required this.v1,
    required this.u2,
    required this.v2,
    required this.width,
    required this.height,
    required this.left,
    required this.top,
    required this.advance,
  });
}

class PlxFont {
  final String name;
  final String fontFamily;
  final Map<int, GlyphInfo> glyphs = {};
  GfxTexture? atlasTexture;

  PlxFont._(this.name, this.fontFamily);

  static Future<PlxFont> load(
    String assetPath, 
    {
      String? fontFamily, 
      String characters = " !\"#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
    }
  ) async {
    final ByteData data = await rootBundle.load(assetPath);
    final String family = fontFamily ?? assetPath.split('/').last.split('.').first;
    final String name = assetPath.split('/').last.split('.').first;
    debugPrint('Loading font $name ($family) from $assetPath');
    // Load font into Flutter's engine
    final loader = FontLoader(family);
    loader.addFont(Future.value(data));
    await loader.load();

    final font = PlxFont._(name, family);
    await font._generateAtlas(characters);
    return font;
  }

  Future<void> _generateAtlas(String characters) async {
    const int glyphSize = 64; // High-res size for SDF calculation
    const int sdfSize = 32;   // Size in the atlas
    const int padding = 8;    // Padding around glyph to avoid clipping SDF
    
    int cols = math.sqrt(characters.length).ceil();
    int rows = (characters.length / cols).ceil();
    
    int atlasWidth = cols * sdfSize;
    int atlasHeight = rows * sdfSize;
    
    // We'll compute SDF on the CPU for each glyph
    // This is slower but more flexible than doing it in a shader at runtime
    final Uint8List atlasPixels = Uint8List(atlasWidth * atlasHeight * 4);

    for (int i = 0; i < characters.length; i++) {
      final char = characters[i];
      final charCode = char.codeUnitAt(0);
      
      int col = i % cols;
      int row = i ~/ cols;
      
      // Render glyph to a temporary high-res image
      final highResImage = await _renderGlyphToImage(char, glyphSize, padding);
      final ByteData? byteData = await highResImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      
      if (byteData != null) {
        final Uint8List pixels = byteData.buffer.asUint8List();
        
        final sdfData = _computeSDF(pixels, glyphSize, sdfSize, padding);
        
        // Copy SDF data to atlas pixels
        for (int y = 0; y < sdfSize; y++) {
          for (int x = 0; x < sdfSize; x++) {
            int atlasIdx = ((row * sdfSize + y) * atlasWidth + (col * sdfSize + x)) * 4;
            int val = sdfData[y * sdfSize + x];
            atlasPixels[atlasIdx] = val;     // R
            atlasPixels[atlasIdx + 1] = val; // G
            atlasPixels[atlasIdx + 2] = val; // B
            atlasPixels[atlasIdx + 3] = 255; // A
          }
        }
      }

      // Store metrics
      final metrics = _getCharMetrics(char);
      glyphs[charCode] = GlyphInfo(
        u1: (col * sdfSize) / atlasWidth,
        v1: (row * sdfSize) / atlasHeight,
        u2: ((col + 1) * sdfSize) / atlasWidth,
        v2: ((row + 1) * sdfSize) / atlasHeight,
        width: metrics.width,
        height: metrics.height,
        left: metrics.left,
        top: metrics.top,
        advance: metrics.advance,
      );
    }

    atlasTexture = GfxTexture.fromPixels(atlasWidth, atlasHeight, atlasPixels.buffer.asInt32List());
  }

  Future<ui.Image> _renderGlyphToImage(String char, int size, int padding) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: (size - padding * 2).toDouble(),
          color: const Color(0xFFFFFFFF),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Center it
    double x = padding.toDouble();
    double y = padding.toDouble();
    textPainter.paint(canvas, Offset(x, y));
    
    final picture = recorder.endRecording();
    return await picture.toImage(size, size);
  }

  Uint8List _computeSDF(Uint8List pixels, int srcSize, int dstSize, int padding) {
    final result = Uint8List(dstSize * dstSize);
    double scale = srcSize / dstSize;
    
    // Brute force SDF for now. Optimized for 64x64 -> 32x32
    for (int y = 0; y < dstSize; y++) {
      for (int x = 0; x < dstSize; x++) {
        double centerX = x * scale + scale / 2;
        double centerY = y * scale + scale / 2;
        
        bool isInside = _isInside(pixels, centerX.toInt(), centerY.toInt(), srcSize);
        double minDist = 1000.0;
        
        // Search in a radius
        int searchRadius = (padding * 1.5).toInt();
        for (int sy = -searchRadius; sy <= searchRadius; sy++) {
          for (int sx = -searchRadius; sx <= searchRadius; sx++) {
            int px = centerX.toInt() + sx;
            int py = centerY.toInt() + sy;
            
            if (px < 0 || px >= srcSize || py < 0 || py >= srcSize) continue;
            
            bool otherInside = _isInside(pixels, px, py, srcSize);
            if (isInside != otherInside) {
              double dist = math.sqrt((sx * sx + sy * sy).toDouble());
              if (dist < minDist) minDist = dist;
            }
          }
        }
        
        // Normalize minDist to 0..1 (0.5 is edge)
        // inside is > 0.5, outside is < 0.5
        double val = isInside ? (0.5 + minDist / (padding * 2)) : (0.5 - minDist / (padding * 2));
        val = val.clamp(0.0, 1.0);
        result[y * dstSize + x] = (val * 255).toInt();
      }
    }
    return result;
  }

  bool _isInside(Uint8List pixels, int x, int y, int size) {
    int idx = (y * size + x) * 4;
    return pixels[idx + 3] > 128; // Check alpha channel
  }

  _CharMetrics _getCharMetrics(String char) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 32.0, // Base size for metrics
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // We use a base size of 1.0 in our 3D world, so normalize metrics
    double scale = 1.0 / 32.0;
    final lineMetrics = textPainter.computeLineMetrics().first;
    
    return _CharMetrics(
      width: textPainter.width * scale,
      height: textPainter.height * scale,
      left: 0.0, // TextPainter usually starts at 0,0
      top: -lineMetrics.ascent * scale,
      advance: textPainter.width * scale,
    );
  }
}

class _CharMetrics {
  final double width, height, left, top, advance;
  _CharMetrics({required this.width, required this.height, required this.left, required this.top, required this.advance});
}
