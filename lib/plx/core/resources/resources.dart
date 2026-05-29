import 'package:exa_vortex/plx/graphics/material/texture.dart';
import 'package:exa_vortex/plx/graphics/rendering/text/font.dart';
import 'package:flutter/material.dart';
import 'loader.dart';
import 'references.dart';

class PlxAssetManager {
  final Map<String, TextureReference> _textureReferences = {};
  final Map<String, FontReference> _fontReferences = {};

  /// Gets a cached texture.
  PlxTexture? getTexture(String name){
    final ref = _textureReferences[name];
    ref?.active = true;
    return ref?.texture;
  }
  /// Gets a cached font.
  PlxFont? getFont(String name){
    final ref = _fontReferences[name];
    ref?.active = true;
    return ref?.font;
  }
  /// Loads a texture from an asset path and caches it.
  Future<PlxTexture> loadTexture(String name, String path) async {
    if (_textureReferences.containsKey(name)) {
      return getTexture(name)!;
    }
    final texture = await AssetLoader.instance.loadTexture(path);
    _textureReferences[name] = TextureReference(texture: texture);
    return texture;
  }
  /// Loads a font and caches it.
  Future<PlxFont> loadFont(
    String name,
    String fontFamily,
    {
      String? assetPath, 
      String characters = " !\"#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~",
      FontWeight fontWeight = FontWeight.normal,
      FontStyle fontStyle = FontStyle.normal,
    }
  ) async {
    if (_fontReferences.containsKey(name)) {
      return getFont(name)!;
    }
    final font = await PlxFont.load(fontFamily, assetPath: assetPath, characters: characters, fontWeight: fontWeight, fontStyle: fontStyle);
    _fontReferences[name] = FontReference(font: font);
    return font;
  }
  /// Marks all current resources as inactive, preparing for a transition sweep.
  void startTransition() {
    for (var ref in _textureReferences.values) {
      ref.active = false;
    }
    for (var ref in _fontReferences.values) {
      ref.active = false;
    }
  }

  /// Sweeps all resources that were not re-requested during the transition.
  void endTransition() {
    _textureReferences.removeWhere((name, ref) {
      return !ref.active;
    });
    _fontReferences.removeWhere((name, ref) {
      if (!ref.active) {
        ref.font.dispose();
        return true;
      }
      return false;
    });
  }

  /// Clears the cache.
  void dispose() {
    //Textures
    _textureReferences.clear();
    //Fonts
    for (var fontRef in _fontReferences.values) {
      fontRef.font.dispose();
    }
    _fontReferences.clear();
  }
}
