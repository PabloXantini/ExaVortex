import 'dart:ui';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart' as v32;
import 'mesh.dart';
import 'material.dart';

class _RenderCommand {
  final Mesh mesh;
  final GfxMaterial material;
  final double depth;
  _RenderCommand(this.mesh, this.material, this.depth);
}

class PlxRenderer {
  Size size = Size.zero;
  gpu.CommandBuffer? _commandBuffer;
  gpu.RenderPass? _renderPass;
  gpu.Texture? _renderTexture;
  gpu.Texture? _depthTexture;
  v32.Vector4? _backgroundColor = v32.Colors.black;
  final double _depthClearValue = 1.0;

  final List<_RenderCommand> _opaqueQueue = [];
  final List<_RenderCommand> _transparentQueue = [];

  PlxRenderer();

  void setBackgroundColor(v32.Vector4 color){
    _backgroundColor = color;
  }

  /// Starts the rendering frame, creating textures for color and depth.
  void beginFrame(Size size) {
    this.size = size; 
    int w = this.size.width.toInt();
    int h = this.size.height.toInt();
    
    _renderTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.devicePrivate, w, h,
        enableRenderTargetUsage: true,
        enableShaderReadUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture);

    _depthTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.deviceTransient, w, h,
        format: gpu.gpuContext.defaultDepthStencilFormat,
        enableRenderTargetUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture);

    _commandBuffer = gpu.gpuContext.createCommandBuffer();
    
    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(
        texture: _renderTexture!,
        clearValue: _backgroundColor,
      ),
      depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: _depthTexture!, depthClearValue: _depthClearValue),
    );
    
    _renderPass = _commandBuffer!.createRenderPass(renderTarget);
  }

  /// Configures depth state for 3D rendering.
  void setDepthState({bool writeEnable = true, gpu.CompareFunction compareOp = gpu.CompareFunction.less}) {
    _renderPass?.setDepthWriteEnable(writeEnable);
    _renderPass?.setDepthCompareOperation(compareOp);
  }

  /// Configures color blending for transparency support.
  void setBlendState(bool enable) {
    _renderPass?.setColorBlendEnable(enable);
    if (enable) {
      _renderPass?.setColorBlendEquation(gpu.ColorBlendEquation(
        colorBlendOperation: gpu.BlendOperation.add,
        sourceColorBlendFactor: gpu.BlendFactor.sourceAlpha,
        destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
        alphaBlendOperation: gpu.BlendOperation.add,
        sourceAlphaBlendFactor: gpu.BlendFactor.one,
        destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
      ));
    }
  }

  /// Submits a mesh to the render queue.
  void submitMesh(Mesh mesh, GfxMaterial material, {bool opaque = true, double depth = 0.0}) {
    if (!opaque) {
      _transparentQueue.add(_RenderCommand(mesh, material, depth));
    } else {
      _opaqueQueue.add(_RenderCommand(mesh, material, depth));
    }
  }

  void _bindCommand(gpu.RenderPass pass, _RenderCommand cmd) {
    cmd.mesh.bind(pass);
    cmd.material.bind(pass);
    pass.draw();
  }

  void _flush() {
    if (_renderPass == null) return;
    // Opaque Pass
    setBlendState(false);
    setDepthState(writeEnable: true, compareOp: gpu.CompareFunction.less);
    for (var cmd in _opaqueQueue) {
      _bindCommand(_renderPass!, cmd);
    }
    // Transparent Pass
    setBlendState(true);
    setDepthState(writeEnable: false, compareOp: gpu.CompareFunction.lessEqual);
    _transparentQueue.sort((a, b) => b.depth.compareTo(a.depth));
    for (var cmd in _transparentQueue) {
      _bindCommand(_renderPass!, cmd);
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
}