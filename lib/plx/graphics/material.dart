import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math_64.dart';
import 'shader_loader.dart' as sh;
import 'texture.dart';
import 'type_adapter.dart';
import 'dart:typed_data';

enum GfxShader { vertex, fragment }

class ShaderState {
  final String name;
  final gpu.Shader shader;
  final Map<String, ByteData> uniforms = {};
  final Map<String, GfxTexture> textures = {};
  ShaderState({required this.name, required this.shader});
}

class GfxMaterial {
  gpu.RenderPipeline? pipeline;
  gpu.HostBuffer? transientBuffer;

  final String vertexShaderName;
  final String fragmentShaderName;

  final Map<GfxShader, ShaderState> _shaders = {};

  GfxMaterial({
    required this.vertexShaderName,
    required this.fragmentShaderName,
  }) {
    _initPipeline();
  }

  void _initPipeline() {
    _shaders.clear();
    final vertex = sh.baseShaderLibrary[vertexShaderName];
    final fragment = sh.baseShaderLibrary[fragmentShaderName];
    if (vertex == null) {
      debugPrint(
        'Error: Vertex Shader not found in library: $vertexShaderName',
      );
      return;
    }
    if (fragment == null) {
      debugPrint(
        'Warning: Fragment Shader not found in library: $fragmentShaderName',
      );
      return;
    }
    // Create the pipeline and the host bufferon init
    pipeline = gpu.gpuContext.createRenderPipeline(vertex, fragment);
    // Create a single transient buffer.
    transientBuffer = gpu.gpuContext.createHostBuffer();

    _shaders[GfxShader.vertex] = ShaderState(
      name: vertexShaderName,
      shader: pipeline!.vertexShader,
    );
    _shaders[GfxShader.fragment] = ShaderState(
      name: fragmentShaderName,
      shader: pipeline!.fragmentShader,
    );
  }

  /// Add a texture to the material.
  GfxTexture setTexture(GfxShader shader, String name, GfxTexture texture) {
    _shaders[shader]!.textures[name] = texture;
    return texture;
  }

  void _setUniform(GfxShader shader, String name, ByteData data) {
    _shaders[shader]!.uniforms[name] = data;
  }

  /// Set a float uniform.
  ByteData setFloat(GfxShader shader, String name, double value) {
    final bin = float32([value]);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set an int uniform.
  ByteData setInt(GfxShader shader, String name, int value) {
    final bin = uint32([value]);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set a bool uniform.
  ByteData setBool(GfxShader shader, String name, bool value) {
    final bin = boolean([value]);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set a Vector2 uniform.
  ByteData setVector2(GfxShader shader, String name, Vector2 vector) {
    final bin = float32([vector.x, vector.y]);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set a Vector3 uniform.
  ByteData setVector3(GfxShader shader, String name, Vector3 vector) {
    final bin = float32([vector.x, vector.y, vector.z]);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set a Vector4 uniform.
  ByteData setVector4(GfxShader shader, String name, Vector4 vector) {
    final bin = float32([vector.x, vector.y, vector.z, vector.w]);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set a Matrix2 uniform.
  ByteData setMatrix2(GfxShader shader, String name, Matrix2 matrix) {
    final bin = float32Mat2(matrix);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set a Matrix3 uniform.
  ByteData setMatrix3(GfxShader shader, String name, Matrix3 matrix) {
    final bin = float32Mat3(matrix);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Set a Matrix4 uniform.
  ByteData setMatrix4(GfxShader shader, String name, Matrix4 matrix) {
    final bin = float32Mat4(matrix);
    _setUniform(shader, name, bin);
    return bin;
  }

  /// Get a cached slot for a uniform.
  gpu.UniformSlot? _getSlot(ShaderState state, String name) {
    return state.shader.getUniformSlot(name);
  }

  /// Bind pipeline, uniforms and textures to the render pass.
  void bind(gpu.RenderPass pass) {
    if (pipeline == null) return;
    // Reset the transient buffer for this draw call.
    transientBuffer!.reset();
    // Bind Pipeline
    pass.bindPipeline(pipeline!);
    // Bind Uniforms and Textures each shader
    for (var state in _shaders.values) {
      for (var name in state.uniforms.keys) {
        final slot = _getSlot(state, name);
        if (slot != null) {
          final data = state.uniforms[name]!;
          final bufferv = transientBuffer!.emplace(data);
          pass.bindUniform(slot, bufferv);
        }
      }
      for (var name in state.textures.keys) {
        final slot = _getSlot(state, name);
        if (slot != null) {
          final texture = state.textures[name]!;
          pass.bindTexture(slot, texture.gpuTexture);
        }
      }
    }
  }
}
