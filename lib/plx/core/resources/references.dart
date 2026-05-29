import 'package:exa_vortex/plx/graphics/material/texture.dart';
import 'package:exa_vortex/plx/graphics/rendering/text/font.dart';

abstract class PlxResourceReference {
  bool active = true;
}

class TextureReference extends PlxResourceReference {
  final PlxTexture texture;
  TextureReference({required this.texture});  
}

class FontReference extends PlxResourceReference {
  final PlxFont font;
  FontReference({required this.font});  
}