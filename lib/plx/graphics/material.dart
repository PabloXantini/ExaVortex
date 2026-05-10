import 'package:exa_vortex/plx/graphics/plx_rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math_64.dart';
import 'shader_loader.dart' as sh;
import 'dart:typed_data';

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

  gpu.BufferView _allocate(ByteData bytes){
    gpu.HostBuffer buffer = gpu.gpuContext.createHostBuffer();
    final view = buffer.emplace(bytes);
    return view;
  }

  /// Add a texture to the material.
  void setTexture(GfxMaterialLayer layer, String name, GfxTexture texture) {
    final serialize = '$layer.$name'; 
    _textures[serialize] = texture;
    _cacheSlot(layer, name);
  }

  /// Set a float uniform.
  void setFloat(GfxMaterialLayer layer, String name, double value) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(float32([value]));
    _cacheSlot(layer, name);
  }

  /// Set an int uniform.
  void setInt(GfxMaterialLayer layer, String name, int value) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(uint32([value]));
    _cacheSlot(layer, name);
  }

  /// Set a bool uniform.
  void setBool(GfxMaterialLayer layer, String name, bool value) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(boolean([value]));
    _cacheSlot(layer, name);
  }

  /// Set a Vector2 uniform.
  void setVector2(GfxMaterialLayer layer, String name, Vector2 vector) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(float32([vector.x, vector.y]));
    _cacheSlot(layer, name);
  }

  /// Set a Vector3 uniform.
  void setVector3(GfxMaterialLayer layer, String name, Vector3 vector) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(float32([vector.x, vector.y, vector.z]));
    _cacheSlot(layer, name);
  }

  /// Set a Vector4 uniform.
  void setVector4(GfxMaterialLayer layer, String name, Vector4 vector) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(float32([vector.x, vector.y, vector.z, vector.w]));
    _cacheSlot(layer, name);
  }

  /// Set a Matrix2 uniform.
  void setMatrix2(GfxMaterialLayer layer, String name, Matrix2 matrix) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(float32Mat2(matrix));
    _cacheSlot(layer, name);
  }

  /// Set a Matrix3 uniform.
  void setMatrix3(GfxMaterialLayer layer, String name, Matrix3 matrix) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(float32Mat3(matrix));
    _cacheSlot(layer, name);
  }

  /// Set a Matrix4 uniform.
  void setMatrix4(GfxMaterialLayer layer, String name, Matrix4 matrix) {
    final serialize = '$layer.$name';
    _uniforms[serialize] = _allocate(float32Mat4(matrix));
    _cacheSlot(layer, name);
  }

  /// Get a cached slot for a uniform.
  gpu.UniformSlot? getSlot(GfxMaterialLayer layer, String name) {
    final serialize = '$layer.$name';
    if (!_cachedSlots.containsKey(serialize)) {
      _cacheSlot(layer, name);
    }
    return _cachedSlots[serialize];
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

