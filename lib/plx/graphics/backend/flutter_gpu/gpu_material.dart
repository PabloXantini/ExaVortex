import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/logger.dart';
import 'package:exa_vortex/plx/graphics/utils/shader_loader.dart' as sh;
import 'package:exa_vortex/plx/graphics/material/texture.dart';
import 'package:exa_vortex/plx/graphics/material/material.dart';
import 'package:exa_vortex/plx/graphics/utils/type_adapter.dart';
import 'gpu_texture.dart';
import 'dart:typed_data';

class ShaderState {
  final String name;
  final gpu.Shader shader;
  final Map<String, ByteData> uniforms = {};
  final Map<String, GpuTexture> textures = {};
  ShaderState({required this.name, required this.shader});
}

class GpuMaterial implements PlxMaterial {
  gpu.RenderPipeline? pipeline;

  final String vertexShaderName;
  final String fragmentShaderName;

  final Map<PlxShader, ShaderState> _shaders = {};

  GpuMaterial({
    required this.vertexShaderName,
    required this.fragmentShaderName,
  }){
    initPipeline();
  }

  @override
  GpuMaterialInstance use(PlxShader stage) => GpuMaterialInstance(this, stage);

  @override
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
      PlxLogger.error(
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
  @override
  GpuTexture setTexture(PlxShader shader, String name, PlxTexture texture) {
    final gpuTex = texture as GpuTexture;
    _shaders[shader]!.textures[name] = gpuTex;
    return gpuTex;
  }
  @override
  ByteData setFloat(PlxShader shader, String name, double value) {
    final bin = float32([value]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
  ByteData setInt(PlxShader shader, String name, int value) {
    final bin = uint32([value]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
  ByteData setBool(PlxShader shader, String name, bool value) {
    final bin = boolean([value]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
  ByteData setVector2(PlxShader shader, String name, Vector2 vector) {
    final bin = float32([vector.x, vector.y]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
  ByteData setVector3(PlxShader shader, String name, Vector3 vector) {
    final bin = float32([vector.x, vector.y, vector.z]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
  ByteData setVector4(PlxShader shader, String name, Vector4 vector) {
    final bin = float32([vector.x, vector.y, vector.z, vector.w]);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
  ByteData setMatrix2(PlxShader shader, String name, Matrix2 matrix) {
    final bin = float32Mat2(matrix);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
  ByteData setMatrix3(PlxShader shader, String name, Matrix3 matrix) {
    final bin = float32Mat3(matrix);
    _shaders[shader]!.uniforms[name] = bin;
    return bin;
  }

  @override
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
    Map<String, GpuTexture> textures,
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
    GpuMaterialInstance instance,
    gpu.HostBuffer buffer,
  ) {
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

class GpuMaterialInstance implements MaterialInstance {
  final GpuMaterial material;
  PlxShader _stage;
  final Map<PlxShader, Map<String, ByteData>> uniforms = {};
  final Map<PlxShader, Map<String, GpuTexture>> textures = {};

  GpuMaterialInstance(this.material, this._stage);

  @override
  GpuMaterialInstance use(PlxShader stage) {
    _stage = stage;
    return this;
  }

  @override
  GpuMaterialInstance setFloat(String name, double value) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([value]);
    return this;
  }

  @override
  GpuMaterialInstance setInt(String name, int value) {
    uniforms.putIfAbsent(_stage, () => {})[name] = uint32([value]);
    return this;
  }

  @override
  GpuMaterialInstance setBool(String name, bool value) {
    uniforms.putIfAbsent(_stage, () => {})[name] = boolean([value]);
    return this;
  }

  @override
  GpuMaterialInstance setVector2(String name, Vector2 vector) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([vector.x, vector.y]);
    return this;
  }

  @override
  GpuMaterialInstance setVector3(String name, Vector3 vector) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([vector.x, vector.y, vector.z]);
    return this;
  }

  @override
  GpuMaterialInstance setVector4(String name, Vector4 vector) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32([vector.x, vector.y, vector.z, vector.w]);
    return this;
  }

  @override
  GpuMaterialInstance setMatrix2(String name, Matrix2 matrix) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32Mat2(matrix);
    return this;
  }

  @override
  GpuMaterialInstance setMatrix3(String name, Matrix3 matrix) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32Mat3(matrix);
    return this;
  }

  @override
  GpuMaterialInstance setMatrix4(String name, Matrix4 matrix) {
    uniforms.putIfAbsent(_stage, () => {})[name] = float32Mat4(matrix);
    return this;
  }

  @override
  GpuMaterialInstance setTexture(String name, PlxTexture texture) {
    textures.putIfAbsent(_stage, () => {})[name] = texture as GpuTexture;
    return this;
  }
}
