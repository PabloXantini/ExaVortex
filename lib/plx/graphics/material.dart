import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/logger.dart';
import 'shader_loader.dart' as sh;
import 'texture.dart';
import 'type_adapter.dart';
import 'dart:typed_data';

enum PlxShader { vertex, fragment }

class ShaderState {
  final String name;
  final gpu.Shader shader;
  final Map<String, ByteData> uniforms = {};
  final Map<String, PlxTexture> textures = {};
  ShaderState({required this.name, required this.shader});
}

class PlxMaterial {
  gpu.RenderPipeline? pipeline;

  final String vertexShaderName;
  final String fragmentShaderName;

  final Map<PlxShader, ShaderState> _shaders = {};

  PlxMaterial({
    required this.vertexShaderName,
    required this.fragmentShaderName,
  }){
    initPipeline();
  }

  /// Start a new material instance for a specific shader stage.
  MaterialInstance use(PlxShader stage) => MaterialInstance(this, stage);

  void dispose() {
    _shaders.forEach((_, state) {
      state.uniforms.clear();
      state.textures.clear();
    });
    _shaders.clear();
    pipeline = null;
  }

  void initPipeline() {
    _shaders.clear();
    final vertex = sh.baseShaderLibrary[vertexShaderName];
    final fragment = sh.baseShaderLibrary[fragmentShaderName];
    if (vertex == null) {
      PlxLogger.error(
        'Vertex Shader not found in library: $vertexShaderName', system: 'Graphics'
      );
      return;
    }
    if (fragment == null) {
      PlxLogger.warning(
        'Fragment Shader not found in library: $fragmentShaderName', system: 'Graphics'
      );
      return;
    }
    // Create the pipeline on init
    pipeline = gpu.gpuContext.createRenderPipeline(vertex, fragment);

    _shaders[PlxShader.vertex] = ShaderState(
      name: vertexShaderName,
      shader: pipeline!.vertexShader,
    );
    _shaders[PlxShader.fragment] = ShaderState(
      name: fragmentShaderName,
      shader: pipeline!.fragmentShader,
    );
  }

  /// Get a cached slot for a uniform.
  gpu.UniformSlot? _getSlot(ShaderState state, String name) {
    return state.shader.getUniformSlot(name);
  }

  /// Add a texture to the material.
  PlxTexture setTexture(PlxShader shader, String name, PlxTexture texture) {
    _shaders[shader]!.textures[name] = texture;
    return texture;
  }

  /// Set a float uniform.
  ByteData setFloat(PlxShader shader, String name, double value) {
    final bin = float32([value]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set an int uniform.
  ByteData setInt(PlxShader shader, String name, int value) {
    final bin = uint32([value]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set a bool uniform.
  ByteData setBool(PlxShader shader, String name, bool value) {
    final bin = boolean([value]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set a Vector2 uniform.
  ByteData setVector2(PlxShader shader, String name, Vector2 vector) {
    final bin = float32([vector.x, vector.y]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set a Vector3 uniform.
  ByteData setVector3(PlxShader shader, String name, Vector3 vector) {
    final bin = float32([vector.x, vector.y, vector.z]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set a Vector4 uniform.
  ByteData setVector4(PlxShader shader, String name, Vector4 vector) {
    final bin = float32([vector.x, vector.y, vector.z, vector.w]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set a Matrix2 uniform.
  ByteData setMatrix2(PlxShader shader, String name, Matrix2 matrix) {
    final bin = float32Mat2(matrix);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set a Matrix3 uniform.
  ByteData setMatrix3(PlxShader shader, String name, Matrix3 matrix) {
    final bin = float32Mat3(matrix);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Set a Matrix4 uniform.
  ByteData setMatrix4(PlxShader shader, String name, Matrix4 matrix) {
    final bin = float32Mat4(matrix);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  /// Bind pipeline, uniforms and textures to the render pass.
  void bind(gpu.RenderPass pass, gpu.HostBuffer buffer) {
    //if (pipeline == null) return;
    // Bind Pipeline
    pass.bindPipeline(pipeline!);
    // Bind Uniforms and Textures for each shader stage
    _shaders.forEach((stage, state) {
      _bindShaderResources(
        pass,
        state,
        buffer,
        state.uniforms,
        state.textures,
      );
    });
  }

  /// Internal helper to bind uniforms and textures to a specific shader state.
  void _bindShaderResources(
    gpu.RenderPass pass,
    ShaderState state,
    gpu.HostBuffer buffer,
    Map<String, ByteData> uniforms,
    Map<String, PlxTexture> textures,
  ) {
    uniforms.forEach((name, data) {
      final slot = _getSlot(state, name);
      if (slot != null) {
        pass.bindUniform(slot, buffer.emplace(data));
      }
    });

    textures.forEach((name, texture) {
      final slot = _getSlot(state, name);
      if (slot != null) {
        pass.bindTexture(slot, texture.gpuTexture);
      }
    });
  }

  /// Apply per-draw-call overrides from a MaterialInstance.
  /// Must be called AFTER bind() so the instance values win over shared material state.
  void applyInstance(
    gpu.RenderPass pass,
    MaterialInstance instance,
    gpu.HostBuffer buffer,
  ) {
    //if (pipeline == null) return;
    // Union of all stages that have overrides to process them efficiently.
    final stages = {...instance.uniforms.keys, ...instance.textures.keys};
    for (final stage in stages) {
      final state = _shaders[stage];
      if (state == null) continue;
      _bindShaderResources(
        pass,
        state,
        buffer,
        instance.uniforms[stage] ?? {},
        instance.textures[stage] ?? {},
      );
    }
  }
}

/// A short-lived container for per-draw-call uniform and texture overrides.
class MaterialInstance {
  final PlxMaterial material;
  PlxShader _stage;
  final Map<PlxShader, Map<String, ByteData>> uniforms = {};
  final Map<PlxShader, Map<String, PlxTexture>> textures = {};

  MaterialInstance(this.material, this._stage);

  /// Switch the current target shader stage for subsequent setter calls.
  MaterialInstance use(PlxShader stage) {
    _stage = stage;
    return this;
  }

  MaterialInstance setFloat(String name, double value) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([value]);
    return this;
  }

  MaterialInstance setInt(String name, int value) {
    uniforms.putIfAbsent(_stage, () => {})[name] = uint32([value]);
    return this;
  }

  MaterialInstance setBool(String name, bool value) {
    uniforms.putIfAbsent(_stage, () => {})[name] = boolean([value]);
    return this;
  }

  MaterialInstance setVector2(String name, Vector2 vector) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([
      vector.x,
      vector.y,
    ]);
    return this;
  }

  MaterialInstance setVector3(String name, Vector3 vector) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([
      vector.x,
      vector.y,
      vector.z,
    ]);
    return this;
  }

  MaterialInstance setVector4(String name, Vector4 vector) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([
      vector.x,
      vector.y,
      vector.z,
      vector.w,
    ]);
    return this;
  }

  MaterialInstance setMatrix2(String name, Matrix2 matrix) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32Mat2(matrix);
    return this;
  }

  MaterialInstance setMatrix3(String name, Matrix3 matrix) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32Mat3(matrix);
    return this;
  }

  MaterialInstance setMatrix4(String name, Matrix4 matrix) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32Mat4(matrix);
    return this;
  }

  MaterialInstance setTexture(String name, PlxTexture texture) {
    textures.putIfAbsent(_stage, () => {})[name] = texture;
    return this;
  }
}
