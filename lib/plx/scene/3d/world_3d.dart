import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/plx3d.dart';
import 'package:exa_vortex/plx/scene/view.dart';

class World3D extends Entity3D {
  PlxView? view;
  World3D({super.name = 'World3D'});
  @override
  void draw(PlxRenderer renderer) {
    if(view==null) return;
    final res = view!.getResult(renderer.size.width, renderer.size.height);
    for (var e in children){
      final rendererComp = e.getComponent<MeshRenderer>();
      rendererComp?.viewProjectionMatrix = res * transform.modelMatrix;
    }
    super.draw(renderer);
  }
}