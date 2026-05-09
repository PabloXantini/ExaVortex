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

  final Set<String> _slotsToCache = {};

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

  GfxMaterialLayer stringToLayer(String layer){
    switch(layer){
      case 'vertex': return GfxMaterialLayer.vertex;
      case 'fragment': return GfxMaterialLayer.fragment;
      default: throw Exception('Invalid layer: $layer');
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
    
    // Process all pending slots that were requested before pipeline was ready
    final pending = _slotsToCache.toList();
    _slotsToCache.clear();
    for (var item in pending) {
      final parts = item.split(':');
      final layer = stringToLayer(parts[0]);
      final name = parts[1];
      _cacheSlot(layer, name);
    }
  }

  void _cacheSlot(GfxMaterialLayer layer, String name){
    final serialize = '$layer.$name';
    if (pipeline == null) {
      _slotsToCache.add('${layer.name}:$name');
      return;
    }
    final shader = _getShader(layer);
    var slot = shader.getUniformSlot(name);
    _cachedSlots[serialize] = slot;
  }

  /// Add a texture to the material.
  void setTexture(GfxMaterialLayer layer, String name, GfxTexture texture) {
    final serialize = '$layer.$name'; 
    _textures[serialize] = texture;
    _cacheSlot(layer, name);
  }

  /// Add a uniform to the material.
  void setUniform(GfxMaterialLayer layer, name, gpu.BufferView bufferView) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = bufferView;
    _cacheSlot(layer, name);
  }

  /// Bind pipeline, uniforms and textures to the render pass.
  void bind(gpu.RenderPass pass) {
    if (pipeline == null) {
      _initPipeline();
      if (pipeline == null) return;
    }
    pass.bindPipeline(pipeline!);
    _uniforms.forEach((s, view){
      final slot = _cachedSlots[s];
      if (slot != null) pass.bindUniform(slot, view);
    });
    _textures.forEach((s, texture){
      final slot = _cachedSlots[s];
      if (slot != null) pass.bindTexture(slot, texture.gpuTexture);
    });
  }
}

