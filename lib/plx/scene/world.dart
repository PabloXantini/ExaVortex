import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/scene/view.dart';

class World extends Entity {
  late TransformUser transform;
  PlxView? view;

  World({super.name = 'World'}){
    transform = TransformUser();
    addComponent(transform);
  }

  @override
  void dispose() {
    view = null;
    super.dispose();
  }

  @override
  void draw(PlxRenderer renderer) {
    if (view == null) return;
    final vp = view!.getResult(renderer.size.width, renderer.size.height);
    renderer.viewProjectionMatrix = vp;
    super.draw(renderer);
  }
}