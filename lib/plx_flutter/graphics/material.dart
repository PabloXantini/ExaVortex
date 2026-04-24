import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'shader_loader.dart' as sh;
import 'texture.dart';

class GfxMaterial {
  gpu.RenderPipeline? pipeline;
  final String vertexShaderName;
  final String fragmentShaderName;

  final Map<String, GfxTexture> _textures = {};
  final Map<String, gpu.BufferView> _uniforms = {};

  GfxMaterial({
    required this.vertexShaderName,
    required this.fragmentShaderName,
  }) {
    _initPipeline();
  }

  void _initPipeline() {
    try {
      final vertex = sh.baseShaderLibrary[vertexShaderName];
      final fragment = sh.baseShaderLibrary[fragmentShaderName];
      if (vertex != null && fragment != null) {
        pipeline = gpu.gpuContext.createRenderPipeline(vertex, fragment);
      } else {
        debugPrint('Warning: Shader not found in library: $vertexShaderName or $fragmentShaderName');
      }
    } catch (e) {
      debugPrint('Error initializing pipeline for Material: $e');
    }
  }

  /// Add a texture to the material.
  void setTexture(String name, GfxTexture texture) {
    _textures[name] = texture;
  }

  /// Add a uniform to the material.
  void setUniform(String name, gpu.BufferView bufferView) {
    _uniforms[name] = bufferView;
  }

  /// Bind pipeline, uniforms and textures to the render pass.
  void bind(gpu.RenderPass pass) {
    if (pipeline == null) return;
    pass.bindPipeline(pipeline!);
    // Bind uniforms safely
    _uniforms.forEach((name, view) {
      try {
        final slotVert = pipeline!.vertexShader.getUniformSlot(name);
        pass.bindUniform(slotVert, view);
      } catch (_) {
        try {
          final slotFrag = pipeline!.fragmentShader.getUniformSlot(name);
          pass.bindUniform(slotFrag, view);
        } catch (_) {}
      }
    });
    // Bind textures safely
    _textures.forEach((name, texture) {
      try {
        final slotFrag = pipeline!.fragmentShader.getUniformSlot(name);
        pass.bindTexture(slotFrag, texture.gpuTexture);
      } catch (_) {
        try {
          final slotVert = pipeline!.vertexShader.getUniformSlot(name);
          pass.bindTexture(slotVert, texture.gpuTexture);
        } catch (_) {}
      }
    });
  }
}

