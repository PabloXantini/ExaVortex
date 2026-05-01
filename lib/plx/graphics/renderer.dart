import 'dart:ui';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart';
import 'mesh.dart';
import 'material.dart';

class PlxRenderer {
  Size size = Size.zero;
  gpu.CommandBuffer? _commandBuffer;
  gpu.RenderPass? _renderPass;
  gpu.Texture? _renderTexture;
  gpu.Texture? _depthTexture;
  Vector4 _backgroundColor = Colors.black;
  final double _depthClearValue = 1.0;

  PlxRenderer();

  void setBackgroundColor(Vector4 color){
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
        sourceColorBlendFactor: gpu.BlendFactor.one,
        destinationColorBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
        alphaBlendOperation: gpu.BlendOperation.add,
        sourceAlphaBlendFactor: gpu.BlendFactor.one,
        destinationAlphaBlendFactor: gpu.BlendFactor.oneMinusSourceAlpha,
      ));
    }
  }

  /// Draw a mesh using the provided material.
  void drawMesh(Mesh mesh, GfxMaterial material) {
    if (_renderPass == null) return;
    material.bind(_renderPass!);
    mesh.bindAndDraw(_renderPass!);
  }

  /// Submits the command buffer and returns the rendered image.
  Image endFrame() {
    _commandBuffer?.submit();
    return _renderTexture!.asImage();
  }
}