import 'dart:ui';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math_64.dart';
import 'package:vector_math/vector_math.dart' as v32;
import 'mesh.dart';
import 'material.dart';

class _RenderCommand {
  final Mesh mesh;
  final PlxMaterial material;
  final bool opaque;
  final double depth;
  final MaterialInstance? instance;

  _RenderCommand(
    this.mesh,
    this.material,
    this.opaque,
    this.depth,
    this.instance,
  );
  void _setBlendState(gpu.RenderPass pass) {
    pass.setColorBlendEnable(!opaque);
    if (!opaque) {
      pass.setColorBlendEquation(
        gpu.ColorBlendEquation(
          colorBlendOperation: gpu.BlendOperation.add,
          sourceColorBlendFactor: gpu.BlendFactor.sourceAlpha,
          destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
          alphaBlendOperation: gpu.BlendOperation.add,
          sourceAlphaBlendFactor: gpu.BlendFactor.one,
          destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
        ),
      );
    }
  }

  void _setDepthState(gpu.RenderPass pass) {
    pass.setDepthWriteEnable(opaque);
    pass.setDepthCompareOperation(
      opaque ? gpu.CompareFunction.less : gpu.CompareFunction.lessEqual,
    );
  }

  void execute(gpu.RenderPass pass, gpu.HostBuffer buffer) {
    pass.clearBindings();
    // Apply depth and blend state per-command, before bindPipeline.
    _setDepthState(pass);
    _setBlendState(pass);
    // Bind de mesh buffers
    mesh.bind(pass);
    // Bind base material (shared state: pipeline, textures, base uniforms).
    material.bind(pass, buffer);
    // Apply per-draw-call instances
    if (instance != null) {
      material.applyInstance(pass, instance!, buffer);
    }
    pass.draw();
  }
}

class PlxRenderer {
  Size size = Size.zero;
  gpu.CommandBuffer? _commandBuffer;
  gpu.RenderPass? _renderPass;
  gpu.Texture? _renderTexture;
  gpu.Texture? _depthTexture;
  v32.Vector4? _backgroundColor = v32.Colors.black;
  final double _depthClearValue = 1.0;
  Matrix4 viewProjectionMatrix = Matrix4.identity();

  final gpu.HostBuffer _hostBuffer = gpu.gpuContext.createHostBuffer();
  final List<_RenderCommand> _opaqueQueue = [];
  final List<_RenderCommand> _transparentQueue = [];

  PlxRenderer();

  void setBackgroundColor(v32.Vector4 color) {
    _backgroundColor = color;
  }

  /// Starts the rendering frame, creating textures for color and depth.
  void beginFrame(Size size) {
    int w = size.width.toInt();
    int h = size.height.toInt();

    if (this.size != size || _renderTexture == null || _depthTexture == null) {
      this.size = size;
      _renderTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.devicePrivate,
        w,
        h,
        enableRenderTargetUsage: true,
        enableShaderReadUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture,
      );

      _depthTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.deviceTransient,
        w,
        h,
        format: gpu.gpuContext.defaultDepthStencilFormat,
        enableRenderTargetUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture,
      );
    }

    _commandBuffer = gpu.gpuContext.createCommandBuffer();

    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: _renderTexture!,
        clearValue: _backgroundColor,
      ),
      depthStencilAttachment: gpu.DepthStencilAttachment(
        texture: _depthTexture!,
        depthClearValue: _depthClearValue,
      ),
    );

    _renderPass = _commandBuffer!.createRenderPass(renderTarget);

    // Reset the global host buffer for the new frame.
    _hostBuffer.reset();
  }

  /// Submits a mesh to the render queue.
  /// [instance] carries per-entity uniform snapshots.
  /// materials are never mutated between the submit and flush steps.
  void submit(
    Mesh mesh,
    PlxMaterial material, {
    bool opaque = true,
    double depth = 0.0,
    MaterialInstance? instance,
  }) {
    final cmd = _RenderCommand(mesh, material, opaque, depth, instance);
    if (!opaque) {
      _transparentQueue.add(cmd);
    } else {
      _opaqueQueue.add(cmd);
    }
  }

  void _flush() {
    if (_renderPass == null) return;
    // Opaque pass — each command sets its own state before binding.
    for (var cmd in _opaqueQueue) {
      cmd.execute(_renderPass!, _hostBuffer);
    }
    // Transparent pass — sorted back-to-front; each command sets its own state.
    _transparentQueue.sort((a, b) => b.depth.compareTo(a.depth));
    for (var cmd in _transparentQueue) {
      cmd.execute(_renderPass!, _hostBuffer);
    }
    _opaqueQueue.clear();
    _transparentQueue.clear();
  }

  /// Submits the command buffer and returns the rendered image.
  Image endFrame() {
    _flush();
    _commandBuffer?.submit();
    return _renderTexture!.asImage();
  }

  void dispose() {
    _renderTexture = null;
    _depthTexture = null;
    _commandBuffer = null;
    _renderPass = null;
  }
}
