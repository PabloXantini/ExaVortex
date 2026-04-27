import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'mesh.dart';
import 'material.dart';

class PlxRenderer {
  Canvas canvas;
  Size size;
  gpu.CommandBuffer? _commandBuffer;
  gpu.RenderPass? _renderPass;
  gpu.Texture? _renderTexture;
  gpu.Texture? _depthTexture;

  PlxRenderer({
    required this.canvas,
    required this.size
  });

  /// Starts the rendering frame, creating textures for color and depth.
  void beginFrame(int width, int height, {double depthClearValue = 1.0}) {
    _renderTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.devicePrivate, width, height,
        enableRenderTargetUsage: true,
        enableShaderReadUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture);

    _depthTexture = gpu.gpuContext.createTexture(
        gpu.StorageMode.deviceTransient, width, height,
        format: gpu.gpuContext.defaultDepthStencilFormat,
        enableRenderTargetUsage: true,
        coordinateSystem: gpu.TextureCoordinateSystem.renderToTexture);

    _commandBuffer = gpu.gpuContext.createCommandBuffer();
    
    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(texture: _renderTexture!),
      depthStencilAttachment: gpu.DepthStencilAttachment(
          texture: _depthTexture!, depthClearValue: depthClearValue),
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
  ui.Image endFrame() {
    _commandBuffer?.submit();
    return _renderTexture!.asImage();
  }
}