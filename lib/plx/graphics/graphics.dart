import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'primitives/mesh.dart';
import 'material/material.dart';
import 'material/texture.dart';
import 'renderer.dart';
import 'backend/flutter_gpu/gpu_graphics.dart';

abstract class PlxGraphics {
  static PlxGraphics? _instance;

  static PlxGraphics get instance {
    if (_instance == null) {
      if (kIsWeb) {
        throw UnimplementedError('Web graphics backend is not yet implemented.');
      } else {
        _instance = GpuGraphics();
      }
    }
    return _instance!;
  }

  /// Create a new renderer instance
  PlxRenderer createRenderer();

  /// Create a mesh from declarative vertex format and interleaved data
  PlxMesh createMesh(VertexFormat format, List<double> interleavedVertices, {List<int>? indices16, List<int>? indices32});

  /// Create a material
  PlxMaterial createMaterial({required String vertexShaderName, required String fragmentShaderName});

  /// Create a texture from raw RGBA bytes
  PlxTexture createTextureFromBytes(int width, int height, ByteData bytes);

  /// Create a texture from pixels 32 list
  PlxTexture createTextureFromPixels(int width, int height, List<int> pixels32);

  /// Create a texture from an asset path
  Future<PlxTexture> createTextureFromAsset(String path);

  /// Create a texture from a ui.Image
  Future<PlxTexture> createTextureFromImage(Image image);
}
