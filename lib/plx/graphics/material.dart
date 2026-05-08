import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'shader_loader.dart' as sh;
import 'texture.dart';

enum GfxMaterialLayer {
  vertex,
  fragment
}

class GfxMaterial {
  gpu.RenderPipeline? pipeline;
  final String vertexShaderName;
  final String fragmentShaderName;

  final Map<String, gpu.UniformSlot> _cachedSlots = {};
  final Map<String, GfxTexture> _textures = {};
  final Map<String, gpu.BufferView> _uniforms = {};

  GfxMaterial({
    required this.vertexShaderName,
    required this.fragmentShaderName,
  }) {
    _initPipeline();
  }

  gpu.Shader _getShader(GfxMaterialLayer layer){
    switch(layer){
      case GfxMaterialLayer.vertex: return pipeline!.vertexShader;
      case GfxMaterialLayer.fragment: return pipeline!.fragmentShader;
    }
  }

  void _initPipeline() {
    _cachedSlots.clear();
    final vertex = sh.baseShaderLibrary[vertexShaderName];
    final fragment = sh.baseShaderLibrary[fragmentShaderName];
    if (vertex == null || fragment == null){
      debugPrint('Warning: Shader not found in library: $vertexShaderName or $fragmentShaderName');
      return;
    }
    pipeline = gpu.gpuContext.createRenderPipeline(vertex, fragment);
    for (var name in _uniforms.keys){
      _cacheSlot(pipeline!.vertexShader, name);
      _cacheSlot(pipeline!.fragmentShader, name);
    }
    for (var name in _textures.keys){
      _cacheSlot(pipeline!.fragmentShader, name);
    }
  }

  void _cacheSlot(gpu.Shader shader, String name){
    if (pipeline == null) return;
    var slot = shader.getUniformSlot(name);
    _cachedSlots[name] = slot;
  }

  /// Add a texture to the material.
  void setTexture(GfxMaterialLayer layer, String name, GfxTexture texture) {
    final shader = _getShader(layer);
    _textures[name] = texture;
    _cacheSlot(shader, name);
  }

  /// Add a uniform to the material.
  void setUniform(GfxMaterialLayer layer, name, gpu.BufferView bufferView) {
    final shader = _getShader(layer);
    _uniforms[name] = bufferView;
    _cacheSlot(shader, name);
  }

  /// Bind pipeline, uniforms and textures to the render pass.
  void bind(gpu.RenderPass pass) {
    if (pipeline == null) return;
    pass.bindPipeline(pipeline!);
    _uniforms.forEach((name, view){
      final slot = _cachedSlots[name];
      if (slot != null) pass.bindUniform(slot, view);
    });
    _textures.forEach((name, texture){
      final slot = _cachedSlots[name];
      if (slot != null) pass.bindTexture(slot, texture.gpuTexture);
    });
  }
}

