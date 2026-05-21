import 'package:exa_vortex/plx/geometry/2d/rect.dart';
import 'package:exa_vortex/plx/graphics/sprite/quad.dart';
import 'package:exa_vortex/plx/graphics/text/geometry.dart';
import 'package:exa_vortex/plx/graphics/text/glyph.dart';
import 'rich_text.dart';

class TextLayout {
  /// The final quads sorted by font, so they can be batched easily.
  final Map<int, List<SpriteQuad>> quadsByFontId;
  final BoundRect bounds;

  TextLayout({required this.quadsByFontId, required this.bounds});
}

class TextLayoutBuilder {
  /// Lays out a composition within a [maxWidth]. 
  /// Wraps at spaces or breaks words if they are too long.
  /// Applies [align] and [lineSpacing].
  static TextLayout layout(
    TextComposition composition, {
    required double maxWidth,
    TextAlign align = TextAlign.left,
    TextAnchor anchor = TextAnchor.topLeft,
    double lineSpacing = 0.0,
  }) {
    // 1. Break text into words/tokens
    final List<_LayoutToken> tokens = _TextTokenizer.tokenize(composition);

    // 2. Wrap into lines
    final List<_LayoutLine> lines = _TextTokenizer.wrapLines(tokens, maxWidth);

    // 3. Compute alignment and generate quads
    final Map<int, List<SpriteQuad>> quadsByFontId = {};
    double cursorY = 0.0;
    int zIndex = 0;

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      double cursorX = 0.0;

      // Apply alignment
      if (align == TextAlign.center) {
        cursorX = (maxWidth - line.width) / 2.0;
      } else if (align == TextAlign.right) {
        cursorX = maxWidth - line.width;
      } else if (align == TextAlign.justified && lineIndex < lines.length - 1 && line.tokens.length > 1) {
        // Justified spacing
        // We calculate extra space to distribute among gaps (which are typically space tokens)
        int gapCount = 0;
        for (var t in line.tokens) {
          if (t.isSpace) {
            gapCount++;
          }
        }
        
        if (gapCount > 0) {
          double extraSpace = maxWidth - line.width;
          double extraPerGap = extraSpace / gapCount;
          for (var t in line.tokens) {
            if (t.isSpace) {
              t.width += extraPerGap;
            }
          }
        }
      }

      double maxLineHeight = 0.0;
      double maxLineAscent = 0.0; // The distance from baseline to top

      // Find line height
      for (var token in line.tokens) {
        if (token.height > maxLineHeight) maxLineHeight = token.height;
        if (token.ascent > maxLineAscent) maxLineAscent = token.ascent;
      }
      
      // Default line height if empty
      if (maxLineHeight == 0) maxLineHeight = 1.0;

      // Layout tokens in the line
      for (var token in line.tokens) {
        if (!token.isSpace) {
          int fontId = token.segment.font.hashCode;
          quadsByFontId.putIfAbsent(fontId, () => []);

          double localCursorX = cursorX;
          for (var charInfo in token.chars) {
            final glyph = charInfo.glyph;
            final fontSize = token.segment.fontSize;
            
            quadsByFontId[fontId]!.add(toSpriteQuad(
              glyph,
              cursorX: localCursorX,
              baselineY: cursorY + maxLineAscent,
              fontSize: fontSize,
              z: zIndex * 0.0001,
            ));
            zIndex++;
            
            localCursorX += (glyph.advance * fontSize) + token.segment.letterSpacing;
          }
        }
        cursorX += token.width;
      }
      
      cursorY += maxLineHeight + lineSpacing;
    }

    final rawBounds = calculateBounds(quadsByFontId.values.expand((element) => element));

    // 4. Apply anchor offset
    final offset = getLayoutPosition(anchor, rawBounds);
    final finalBounds = BoundRect(
      left: rawBounds.left + offset.x,
      right: rawBounds.right + offset.x,
      top: rawBounds.top + offset.y,
      bottom: rawBounds.bottom + offset.y,
    );

    for (var quadList in quadsByFontId.values) {
      for (var q in quadList) {
        q.tlPosition.add(offset);
        q.brPosition.add(offset);
      }
    }

    return TextLayout(quadsByFontId: quadsByFontId, bounds: finalBounds);
  }
}

class _TextTokenizer {
  static List<_LayoutToken> tokenize(TextComposition composition) {
    final List<_LayoutToken> tokens = [];
    for (var segment in composition.segments) {
      List<_CharInfo> wordChars = [];
      double wordWidth = 0;
      double maxHeight = 0;
      double maxAscent = 0;

      for (int i = 0; i < segment.text.length; i++) {
        final char = segment.text[i];
        final charCode = segment.text.codeUnitAt(i);
        
        if (char == ' ' || char == '\n') {
          if (wordChars.isNotEmpty) {
            tokens.add(_LayoutToken(
              segment: segment,
              chars: wordChars,
              width: wordWidth,
              height: maxHeight,
              ascent: maxAscent,
              isSpace: false,
            ));
            wordChars = [];
            wordWidth = 0;
            maxHeight = 0;
            maxAscent = 0;
          }
          
          if (char == ' ') {
            double spaceWidth = segment.fontSize * 0.3; // Default space
            final glyph = segment.font.glyphs[charCode];
            if (glyph != null) {
              spaceWidth = glyph.advance * segment.fontSize;
            }
            tokens.add(_LayoutToken.space(segment, spaceWidth));
          } else if (char == '\n') {
            tokens.add(_LayoutToken.newline(segment));
          }
        } else {
          final glyph = segment.font.glyphs[charCode];
          if (glyph != null) {
            wordChars.add(_CharInfo(char, glyph));
            wordWidth += (glyph.advance * segment.fontSize) + segment.letterSpacing;
            final h = glyph.size.height * segment.fontSize;
            if (h > maxHeight) maxHeight = h;
            // Negative bearing.dy is the ascent above baseline
            final a = -glyph.bearing.dy * segment.fontSize;
            if (a > maxAscent) maxAscent = a;
          }
        }
      }
      if (wordChars.isNotEmpty) {
        tokens.add(_LayoutToken(
          segment: segment,
          chars: wordChars,
          width: wordWidth,
          height: maxHeight,
          ascent: maxAscent,
          isSpace: false,
        ));
      }
    }
    return tokens;
  }

  static List<_LayoutLine> wrapLines(List<_LayoutToken> tokens, double maxWidth) {
    final List<_LayoutLine> lines = [];
    _LayoutLine currentLine = _LayoutLine();

    for (var token in tokens) {
      if (token.isNewline) {
        lines.add(currentLine);
        currentLine = _LayoutLine();
        continue;
      }

      if (token.isSpace) {
        // Only add space if line is not empty (trim leading spaces)
        if (currentLine.tokens.isNotEmpty) {
          currentLine.add(token);
        }
        continue;
      }

      // It's a word token
      if (currentLine.width + token.width <= maxWidth) {
        currentLine.add(token);
      } else {
        // Word exceeds remaining width.
        // If line is empty, word is longer than maxWidth. We must break the word or just put it.
        // The user said: "wrap when reach to space, or the word is so long for fit in edge of bounding box"
        if (currentLine.tokens.isEmpty) {
          // Break the word token manually
          var subTokens = _breakWord(token, maxWidth);
          for (int i = 0; i < subTokens.length; i++) {
            currentLine.add(subTokens[i]);
            if (i < subTokens.length - 1) {
              lines.add(currentLine);
              currentLine = _LayoutLine();
            }
          }
        } else {
          // Remove trailing spaces from current line before finishing
          while (currentLine.tokens.isNotEmpty && currentLine.tokens.last.isSpace) {
            currentLine.removeLast();
          }
          lines.add(currentLine);
          currentLine = _LayoutLine();
          
          // Now check if token fits in the new line
          if (token.width <= maxWidth) {
            currentLine.add(token);
          } else {
            // Even on a new line it doesn't fit, break it
            var subTokens = _breakWord(token, maxWidth);
            for (int i = 0; i < subTokens.length; i++) {
              currentLine.add(subTokens[i]);
              if (i < subTokens.length - 1) {
                lines.add(currentLine);
                currentLine = _LayoutLine();
              }
            }
          }
        }
      }
    }
    
    // Add final line
    if (currentLine.tokens.isNotEmpty) {
      while (currentLine.tokens.isNotEmpty && currentLine.tokens.last.isSpace) {
        currentLine.removeLast();
      }
      lines.add(currentLine);
    }

    return lines;
  }

  static List<_LayoutToken> _breakWord(_LayoutToken token, double maxWidth) {
    final List<_LayoutToken> parts = [];
    List<_CharInfo> currentChars = [];
    double currentWidth = 0;
    
    for (var c in token.chars) {
      double cWidth = (c.glyph.advance * token.segment.fontSize) + token.segment.letterSpacing;
      if (currentWidth + cWidth > maxWidth && currentChars.isNotEmpty) {
        parts.add(_LayoutToken(
          segment: token.segment,
          chars: currentChars,
          width: currentWidth,
          height: token.height,
          ascent: token.ascent,
          isSpace: false,
        ));
        currentChars = [c];
        currentWidth = cWidth;
      } else {
        currentChars.add(c);
        currentWidth += cWidth;
      }
    }
    
    if (currentChars.isNotEmpty) {
      parts.add(_LayoutToken(
        segment: token.segment,
        chars: currentChars,
        width: currentWidth,
        height: token.height,
        ascent: token.ascent,
        isSpace: false,
      ));
    }
    return parts;
  }
}

class _CharInfo {
  final String char;
  final GlyphMetrics glyph;
  _CharInfo(this.char, this.glyph);
}

class _LayoutToken {
  final TextSegment segment;
  final List<_CharInfo> chars;
  double width;
  final double height;
  final double ascent;
  final bool isSpace;
  final bool isNewline;

  _LayoutToken({
    required this.segment,
    required this.chars,
    required this.width,
    required this.height,
    required this.ascent,
    required this.isSpace,
    this.isNewline = false,
  });

  factory _LayoutToken.space(TextSegment segment, double width) {
    return _LayoutToken(
      segment: segment,
      chars: [],
      width: width,
      height: segment.fontSize,
      ascent: segment.fontSize,
      isSpace: true,
    );
  }

  factory _LayoutToken.newline(TextSegment segment) {
    return _LayoutToken(
      segment: segment,
      chars: [],
      width: 0,
      height: segment.fontSize,
      ascent: segment.fontSize,
      isSpace: false,
      isNewline: true,
    );
  }
}

class _LayoutLine {
  final List<_LayoutToken> tokens = [];
  double width = 0;

  void add(_LayoutToken token) {
    tokens.add(token);
    width += token.width;
  }

  void removeLast() {
    if (tokens.isNotEmpty) {
      width -= tokens.last.width;
      tokens.removeLast();
    }
  }
}
