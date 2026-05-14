import '../graphics/texture.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, PlxTexture> _textures = {};

  /// Loads a texture from an asset path and caches it.
  Future<PlxTexture> loadTexture(String path) async {
    if (_textures.containsKey(path)) {
      return _textures[path]!;
    }
    final texture = await PlxTexture.fromAsset(path);
    _textures[path] = texture;
    return texture;
  }

  /// Gets a cached texture.
  PlxTexture? getTexture(String path) => _textures[path];

  /// Clears the cache.
  void clear() {
    _textures.clear();
  }
}
