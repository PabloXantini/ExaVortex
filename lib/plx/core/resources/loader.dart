import 'package:exa_vortex/plx/graphics/material/texture.dart';
import 'package:exa_vortex/plx/graphics/graphics.dart';

class AssetLoader {
  static AssetLoader? _instance;

  static AssetLoader get instance {
    _instance ??= AssetLoader._internal();
    return _instance!;
  }

  AssetLoader._internal();

  Future<PlxTexture> loadTexture(String path) async {
    return await PlxGraphics.instance.createTextureFromAsset(path);
  }
}