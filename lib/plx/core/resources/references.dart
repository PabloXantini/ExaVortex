import 'package:exa_vortex/plx/graphics/material/texture.dart';

abstract class PlxResourceReference {
  int referenceCount = 0;
  bool get isEmpty => referenceCount <= 0;
  void add() => referenceCount++;
  void release() {
    if(referenceCount > 0) referenceCount--;
  }
}

class TextureReference extends PlxResourceReference {
  final PlxTexture texture;
  TextureReference({required this.texture});  
}