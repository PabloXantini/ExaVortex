import 'package:exa_vortex/plx/graphics/texture.dart';

class AssetLoader {
  static AssetLoader? _instance;

  static AssetLoader get instance {
    _instance ??= AssetLoader._internal();
    return _instance!;
  }

  AssetLoader._internal();

  Future<PlxTexture> loadTexture(String path) async {
    return await PlxTexture.fromAsset(path);
  }
}