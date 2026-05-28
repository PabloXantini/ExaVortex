import 'package:flutter_gpu/gpu.dart' as gpu;
import '../../material/texture.dart';

class GpuTexture implements PlxTexture {
  final gpu.Texture gpuTexture;

  GpuTexture(this.gpuTexture);
}
