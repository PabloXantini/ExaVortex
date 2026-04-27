import 'package:exagon_plus/plx/plx.dart';
import 'package:exagon_plus/plx/scene/view.dart';

class World extends Entity {
  PlxView? view;
  World({super.name = 'World'});
  @override
  void draw(PlxRenderer renderer) {
    if(view==null) return;
    final res = view!.getResult(renderer.size.width, renderer.size.height);
    for (var e in children){
      final rendererComp = e.getComponent<MeshRenderer>();
      rendererComp?.viewProjectionMatrix = res;
    }
    super.draw(renderer);
  }
}