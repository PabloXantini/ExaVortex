import 'package:exa_vortex/plx/plx.dart';
import 'package:exa_vortex/plx/scene/view.dart';

class World extends Entity {
  late TransformUser transform;
  PlxView? view;
  Matrix4? _lastVP;

  World({super.name = 'World'}){
    transform = TransformUser();
    addComponent(transform);
  }

  @override
  void dispose() {
    view = null;
    super.dispose();
  }

  void _propagateViewProjection(Entity entity, Matrix4 vp) {
    for (var child in entity.children) {
      child.getComponent<MeshRenderer>()?.viewProjectionMatrix = vp;
      _propagateViewProjection(child, vp);
    }
  }

  @override
  void draw(PlxRenderer renderer) {
    if (view == null) return;
    final vp = view!.getResult(renderer.size.width, renderer.size.height);
    if (_lastVP == null || _lastVP != vp) {
      _propagateViewProjection(this, vp);
      _lastVP = vp;
    }
    super.draw(renderer);
  }
}