import 'package:exa_vortex/plx/core/plx_core.dart';
import 'package:exa_vortex/plx/graphics/material/material.dart';

class Renderer extends Component{
  PlxMaterial? material;
  Renderer({this.material});

  @override
  void dispose() {
    material = null;
    super.dispose();
  }
}