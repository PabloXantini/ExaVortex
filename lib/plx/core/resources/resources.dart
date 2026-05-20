import 'package:exa_vortex/plx/graphics/texture.dart';
import 'loader.dart';
import 'references.dart';

class PlxAssetManager {
  final Map<String, TextureReference> _textureReferences = {};

  /// Gets a cached texture.
  PlxTexture? getTexture(String name) => _textureReferences[name]?.texture;
  
  /// Loads a texture from an asset path and caches it.
  Future<PlxTexture> loadTexture(String name, String path) async {
    if (_textureReferences.containsKey(name)) {
      _textureReferences[name]!.add();
      return _textureReferences[name]!.texture;
    }
    final texture = await AssetLoader.instance.loadTexture(path);
    _textureReferences[name] = TextureReference(texture: texture);
    return texture;
  }

  ///Release a texture reference.
  void releaseTexture(String name) {
    if (_textureReferences.containsKey(name)) {
      _textureReferences[name]!.release();
      if (_textureReferences[name]!.isEmpty) {
        _textureReferences.remove(name);
      }
    }
  }

  /// Clears the cache.
  void dispose() {
    _textureReferences.clear();
  }
}
